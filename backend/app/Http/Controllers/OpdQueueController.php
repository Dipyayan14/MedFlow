<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OpdQueueController extends Controller
{
    /**
     * Get OPD queue for a given date and doctor.
     * Ordered by status (in_consultation -> checked_in -> scheduled -> completed -> cancelled -> no_show),
     * then token_number asc, then scheduled_at asc.
     */
    public function queue(Request $request): JsonResponse
    {
        $user = $request->user();
        $date = $request->query('date', Carbon::now('Asia/Kolkata')->format('Y-m-d'));

        $query = Appointment::query()
            ->with([
                'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
                'doctor:id,name,department,specialization',
                'creator:id,name,role',
            ])
            ->whereDate('scheduled_at', $date);

        // Role scoping for doctors
        if ($user->role === 'doctor') {
            if ($request->filled('doctor_id') && (int) $request->query('doctor_id') !== $user->id) {
                abort(403, 'Forbidden: Doctors can only view their own OPD queue.');
            }
            $query->where('doctor_id', $user->id);
            $doctorId = $user->id;
        } else {
            $doctorId = $request->query('doctor_id');
            if ($doctorId) {
                $query->where('doctor_id', $doctorId);
            }
        }

        $statusOrderSql = "CASE status " .
            "WHEN 'in_consultation' THEN 1 " .
            "WHEN 'checked_in' THEN 2 " .
            "WHEN 'scheduled' THEN 3 " .
            "WHEN 'completed' THEN 4 " .
            "WHEN 'cancelled' THEN 5 " .
            "WHEN 'no_show' THEN 6 " .
            "ELSE 7 END";

        $appointments = $query
            ->orderByRaw($statusOrderSql)
            ->orderByRaw("CASE WHEN token_number IS NULL THEN 1 ELSE 0 END, token_number ASC")
            ->orderBy('scheduled_at', 'asc')
            ->get();

        $appointments->each(fn ($a) => $a->sanitizeForUser($user));

        $inConsultationCount = $appointments->where('status', Appointment::STATUS_IN_CONSULTATION)->count();
        $waitingCount = $appointments->where('status', Appointment::STATUS_CHECKED_IN)->count();
        $scheduledCount = $appointments->where('status', Appointment::STATUS_SCHEDULED)->count();
        $completedCount = $appointments->where('status', Appointment::STATUS_COMPLETED)->count();

        return response()->json([
            'date' => $date,
            'doctor_id' => $doctorId ? (int) $doctorId : null,
            'total' => $appointments->count(),
            'counts' => [
                'in_consultation' => $inConsultationCount,
                'waiting' => $waitingCount,
                'scheduled' => $scheduledCount,
                'completed' => $completedCount,
            ],
            'data' => $appointments,
        ]);
    }

    /**
     * Check in a patient for their appointment, issuing a token number.
     * Allowed roles: duty_desk, nurse, admin.
     */
    public function checkIn(Request $request, ?Appointment $appointment = null): JsonResponse
    {
        if (! $appointment) {
            $validated = $request->validate([
                'appointment_id' => 'required|integer|exists:appointments,id',
            ]);
            $appointment = Appointment::findOrFail($validated['appointment_id']);
        }

        $appointment->checkIn();

        $appointment->load([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);
        $appointment->sanitizeForUser($request->user());

        return response()->json([
            'message' => 'Patient checked in successfully',
            'token_number' => $appointment->token_number,
            'appointment' => $appointment,
        ]);
    }

    /**
     * Call the next patient into consultation.
     * Allowed role: Assigned doctor only.
     */
    public function callNext(Request $request, ?Appointment $appointment = null): JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'doctor') {
            abort(403, 'Forbidden: Only doctors can call patients for consultation.');
        }

        if (! $appointment && $request->filled('appointment_id')) {
            $appointment = Appointment::findOrFail($request->input('appointment_id'));
        }

        if ($appointment) {
            if ($appointment->doctor_id !== $user->id) {
                abort(403, 'Forbidden: You can only call patients assigned to you.');
            }
            if ($appointment->status === Appointment::STATUS_CANCELLED) {
                return response()->json(['message' => 'Cannot call a cancelled appointment.'], 422);
            }
            if ($appointment->status === Appointment::STATUS_COMPLETED) {
                return response()->json(['message' => 'Appointment is already completed.'], 422);
            }
        } else {
            $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

            // Find next waiting patient for this doctor today
            $appointment = Appointment::where('doctor_id', $user->id)
                ->whereDate('scheduled_at', $today)
                ->where('status', Appointment::STATUS_CHECKED_IN)
                ->orderByRaw("CASE WHEN token_number IS NULL THEN 1 ELSE 0 END, token_number ASC")
                ->orderBy('scheduled_at', 'asc')
                ->first();

            if (! $appointment) {
                // Fallback to scheduled if none checked in yet
                $appointment = Appointment::where('doctor_id', $user->id)
                    ->whereDate('scheduled_at', $today)
                    ->where('status', Appointment::STATUS_SCHEDULED)
                    ->orderBy('scheduled_at', 'asc')
                    ->first();
            }

            if (! $appointment) {
                return response()->json([
                    'message' => 'No patients waiting in queue for consultation.',
                    'appointment' => null,
                ], 404);
            }
        }

        $appointment->status = Appointment::STATUS_IN_CONSULTATION;
        $appointment->save();

        $appointment->load([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);
        $appointment->sanitizeForUser($user);

        return response()->json([
            'message' => 'Patient called for consultation',
            'appointment' => $appointment,
        ]);
    }

    /**
     * Complete consultation for an appointment.
     * Allowed role: Assigned doctor only.
     * Rule: Cannot complete before status is in_consultation.
     */
    public function complete(Request $request, ?Appointment $appointment = null): JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'doctor') {
            abort(403, 'Forbidden: Only doctors can complete consultations.');
        }

        if (! $appointment) {
            $validated = $request->validate([
                'appointment_id' => 'required|integer|exists:appointments,id',
                'notes' => 'nullable|string|max:2000',
            ]);
            $appointment = Appointment::findOrFail($validated['appointment_id']);
        } else {
            $request->validate([
                'notes' => 'nullable|string|max:2000',
            ]);
        }

        if ($appointment->doctor_id !== $user->id) {
            abort(403, 'Forbidden: You can only complete consultations for your own appointments.');
        }

        // Status order enforcement: Cannot complete before in_consultation
        if ($appointment->status !== Appointment::STATUS_IN_CONSULTATION) {
            return response()->json([
                'message' => 'Status order violation: Cannot complete an appointment that is not currently in consultation.',
                'current_status' => $appointment->status,
            ], 422);
        }

        $appointment->status = Appointment::STATUS_COMPLETED;
        if ($request->has('notes')) {
            $appointment->notes = $request->input('notes');
        }
        $appointment->save();

        $appointment->load([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);
        $appointment->sanitizeForUser($user);

        return response()->json([
            'message' => 'Consultation completed successfully',
            'appointment' => $appointment,
        ]);
    }
}

