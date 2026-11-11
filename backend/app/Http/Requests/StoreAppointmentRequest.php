<?php

namespace App\Http\Requests;

use App\Models\Appointment;
use Carbon\Carbon;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAppointmentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     * Duty desk and admin can create appointments.
     */
    public function authorize(): bool
    {
        $user = $this->user();

        return $user && in_array($user->role, ['duty_desk', 'admin'], true);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'patient_id' => [
                'required',
                'integer',
                Rule::exists('patients', 'id')->whereNull('deleted_at'),
            ],
            'doctor_id' => [
                'required',
                'integer',
                Rule::exists('users', 'id')->where(fn ($query) => $query->where('role', 'doctor')),
            ],
            'scheduled_at' => [
                'required',
                'date',
                'after:now',
            ],
            'reason' => [
                'nullable',
                'string',
                'max:500',
            ],
        ];
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($this->filled(['doctor_id', 'scheduled_at']) && ! $validator->errors()->has('scheduled_at') && ! $validator->errors()->has('doctor_id')) {
                $scheduledAt = Carbon::parse($this->input('scheduled_at'))->toDateTimeString();

                $conflictExists = Appointment::where('doctor_id', $this->input('doctor_id'))
                    ->where('scheduled_at', $scheduledAt)
                    ->where('status', '!=', Appointment::STATUS_CANCELLED)
                    ->exists();

                if ($conflictExists) {
                    $validator->errors()->add(
                        'scheduled_at',
                        'The selected doctor already has an appointment scheduled at this time.'
                    );
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
            'doctor_id.exists' => 'The selected doctor must be a valid user with the doctor role.',
            'scheduled_at.after' => 'Appointments cannot be scheduled in the past.',
        ];
    }
}

