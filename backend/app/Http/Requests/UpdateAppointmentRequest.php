<?php

namespace App\Http\Requests;

use App\Models\Appointment;
use Carbon\Carbon;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateAppointmentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();
        if (! $user) {
            return false;
        }

        $appointment = $this->route('appointment');
        if (! $appointment instanceof Appointment) {
            $appointment = Appointment::findOrFail($appointment);
        }

        $isAssignedDoctor = ($user->role === 'doctor' && $appointment->doctor_id === $user->id);
        $isAdmin = ($user->role === 'admin');
        $isDutyDesk = ($user->role === 'duty_desk');
        $isNurse = ($user->role === 'nurse');

        // Rule: Reschedule (duty_desk and admin only)
        if ($this->has('scheduled_at')) {
            if (! ($isDutyDesk || $isAdmin)) {
                throw new AuthorizationException('Only duty desk and admin can reschedule appointments.');
            }
        }

        // Rule: Reason (duty_desk and admin only)
        if ($this->has('reason')) {
            if (! ($isDutyDesk || $isAdmin)) {
                throw new AuthorizationException('Only duty desk and admin can update appointment reasons.');
            }
        }

        // Rule: Notes (assigned doctor only)
        if ($this->has('notes')) {
            if (! $isAssignedDoctor) {
                throw new AuthorizationException('Only the assigned doctor can write appointment notes.');
            }
        }

        // Rule: Status transitions
        if ($this->has('status')) {
            $status = $this->input('status');

            if ($status === Appointment::STATUS_CANCELLED) {
                if (! ($isDutyDesk || $isAdmin)) {
                    throw new AuthorizationException('Only duty desk and admin can cancel appointments.');
                }
            } elseif ($status === Appointment::STATUS_CHECKED_IN) {
                if (! ($isDutyDesk || $isNurse || $isAdmin)) {
                    throw new AuthorizationException('Only duty desk, nurse, and admin can check in patients.');
                }
            } elseif (in_array($status, [Appointment::STATUS_IN_CONSULTATION, Appointment::STATUS_COMPLETED], true)) {
                if (! $isAssignedDoctor) {
                    throw new AuthorizationException('Only the assigned doctor can start or complete consultations.');
                }
            } else {
                // Any other status change requires duty_desk or admin
                if (! ($isDutyDesk || $isAdmin)) {
                    throw new AuthorizationException('You are not authorized to update this appointment status.');
                }
            }
        }

        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'scheduled_at' => [
                'sometimes',
                'required',
                'date',
                'after:now',
            ],
            'status' => [
                'sometimes',
                'required',
                'string',
                Rule::in(Appointment::VALID_STATUSES),
            ],
            'reason' => [
                'nullable',
                'string',
                'max:500',
            ],
            'notes' => [
                'nullable',
                'string',
                'max:2000',
            ],
        ];
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($this->filled('scheduled_at') && ! $validator->errors()->has('scheduled_at')) {
                $appointment = $this->route('appointment');
                if (! $appointment instanceof Appointment) {
                    $appointment = Appointment::find($appointment);
                }

                if ($appointment) {
                    $scheduledAt = Carbon::parse($this->input('scheduled_at'))->toDateTimeString();

                    $conflictExists = Appointment::where('doctor_id', $appointment->doctor_id)
                        ->where('scheduled_at', $scheduledAt)
                        ->where('id', '!=', $appointment->id)
                        ->where('status', '!=', Appointment::STATUS_CANCELLED)
                        ->exists();

                    if ($conflictExists) {
                        $validator->errors()->add(
                            'scheduled_at',
                            'The selected doctor already has an appointment scheduled at this time.'
                        );
                    }
                }
            }
        });
    }

    /**
     * Custom messages for validation errors.
     */
    public function messages(): array
    {
        return [
            'scheduled_at.after' => 'Appointments cannot be rescheduled to a past time.',
            'status.in' => 'Invalid appointment status provided.',
        ];
    }
}

