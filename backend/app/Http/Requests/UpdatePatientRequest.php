<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdatePatientRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $patientId = $this->route('patient') instanceof \App\Models\Patient
            ? $this->route('patient')->id
            : $this->route('patient');

        return [
            'mrn' => ['sometimes', 'required', 'string', 'max:50', Rule::unique('patients', 'mrn')->ignore($patientId)],
            'first_name' => ['sometimes', 'required', 'string', 'max:255'],
            'last_name' => ['sometimes', 'required', 'string', 'max:255'],
            'date_of_birth' => ['sometimes', 'required', 'date', 'before_or_equal:today'],
            'gender' => ['sometimes', 'required', 'string', 'in:male,female,other'],
            'phone' => ['sometimes', 'required', 'string', 'max:20'],
            'address' => ['sometimes', 'required', 'string', 'max:500'],
            'emergency_contact_name' => ['sometimes', 'required', 'string', 'max:255'],
            'emergency_contact_phone' => ['sometimes', 'required', 'string', 'max:20'],
            'blood_group' => ['nullable', 'string', 'in:A+,A-,B+,B-,AB+,AB-,O+,O-'],
        ];
    }
}

