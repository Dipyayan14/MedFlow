<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAppointmentRequest;
use App\Http\Requests\UpdateAppointmentRequest;
use App\Models\Appointment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    /**
     * Display a listing of appointments with filters and pagination.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Appointment::query()->with([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);

        // Role scoping: A doctor sees only their own appointments unless they are admin
        if ($user->role === 'doctor') {
            $query->where('doctor_id', $user->id);
        } elseif ($doctorId = $request->query('doctor_id')) {
            $query->where('doctor_id', $doctorId);
        }

        // Filter by date (YYYY-MM-DD)
        if ($date = $request->query('date')) {
            $query->whereDate('scheduled_at', $date);
        }

        // Filter by patient_id
        if ($patientId = $request->query('patient_id')) {
            $query->where('patient_id', $patientId);
        }

        // Filter by status
        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $perPage = max(1, min((int) $request->query('per_page', 15), 100));
        $appointments = $query->orderBy('scheduled_at', 'asc')->paginate($perPage);
        $appointments->getCollection()->each(fn ($a) => $a->sanitizeForUser($user));

        return response()->json($appointments);
    }

    /**
     * Store a newly created appointment in storage.
     */
    public function store(StoreAppointmentRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $validated['created_by'] = $request->user()->id;
        $validated['status'] = Appointment::STATUS_SCHEDULED;

        $appointment = Appointment::create($validated);
        $appointment->load([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);
        $appointment->sanitizeForUser($request->user());

        return response()->json([
            'message' => 'Appointment booked successfully',
            'appointment' => $appointment,
        ], 201);
    }

    /**
     * Display the specified appointment.
     */
    public function show(Request $request, Appointment $appointment): JsonResponse
    {
        $user = $request->user();

        // A doctor sees only their own appointments unless they are admin
        if ($user->role === 'doctor' && $appointment->doctor_id !== $user->id) {
            abort(403, 'Forbidden: You are not authorized to view another doctor\'s appointment.');
        }

        $appointment->load([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);
        $appointment->sanitizeForUser($user);

        return response()->json([
            'appointment' => $appointment,
        ]);
    }

    /**
     * Update the specified appointment in storage.
     */
    public function update(UpdateAppointmentRequest $request, Appointment $appointment): JsonResponse
    {
        $validated = $request->validated();

        if (isset($validated['status']) && $validated['status'] === Appointment::STATUS_CHECKED_IN) {
            $appointment->checkIn();
            unset($validated['status']);
        }

        if (! empty($validated)) {
            $appointment->update($validated);
        }

        $appointment->load([
            'patient:id,mrn,first_name,last_name,phone,gender,date_of_birth,blood_group',
            'doctor:id,name,department,specialization',
            'creator:id,name,role',
        ]);
        $appointment->sanitizeForUser($request->user());

        return response()->json([
            'message' => 'Appointment updated successfully',
            'appointment' => $appointment,
        ]);
    }

    /**
     * Remove the specified appointment from storage (soft delete).
     */
    public function destroy(Request $request, Appointment $appointment): JsonResponse
    {
        if ($request->user()->role !== 'admin') {
            abort(403, 'Forbidden: Only admin can delete appointments.');
        }

        $appointment->delete();

        return response()->json([
            'message' => 'Appointment deleted successfully',
        ]);
    }
}

