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

        $requestedFields = array_keys($this->except(['_method', '_token']));

        if (empty($requestedFields)) {
            return true;
        }

        $allowedFields = [];
        if ($isAdmin || $isDutyDesk) {
            $allowedFields = ['scheduled_at', 'reason', 'status'];
        } elseif ($isNurse) {
            $allowedFields = ['status'];
        } elseif ($isAssignedDoctor) {
            $allowedFields = ['notes', 'status'];
        }

        // Reject if any field is not allowed for this role, or if user has no update permissions
        foreach ($requestedFields as $field) {
            if (! in_array($field, $allowedFields, true)) {
                throw new AuthorizationException("Forbidden: You are not authorized to modify the '{$field}' field.");
            }
        }

        // Validate permitted status values per role
        if ($this->has('status')) {
            $status = $this->input('status');

            if ($isAssignedDoctor) {
                if (! in_array($status, [Appointment::STATUS_IN_CONSULTATION, Appointment::STATUS_COMPLETED], true)) {
                    throw new AuthorizationException("Forbidden: Assigned doctor cannot transition status to '{$status}'.");
                }
            } elseif ($isAdmin || $isDutyDesk) {
                if (! in_array($status, [Appointment::STATUS_CANCELLED, Appointment::STATUS_CHECKED_IN], true)) {
                    throw new AuthorizationException("Forbidden: Duty desk and admin cannot transition status to '{$status}'.");
                }
            } elseif ($isNurse) {
                if ($status !== Appointment::STATUS_CHECKED_IN) {
                    throw new AuthorizationException("Forbidden: Nurses can only transition status to 'checked_in'.");
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
            $appointment = $this->route('appointment');
            if (! $appointment instanceof Appointment) {
                $appointment = Appointment::find($appointment);
            }

            if ($appointment) {
                if ($this->input('status') === Appointment::STATUS_COMPLETED && $appointment->status !== Appointment::STATUS_IN_CONSULTATION) {
                    $validator->errors()->add(
                        'status',
                        'Status order violation: Cannot complete an appointment before it is in consultation.'
                    );
                }

                if ($this->filled('scheduled_at') && ! $validator->errors()->has('scheduled_at')) {
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
