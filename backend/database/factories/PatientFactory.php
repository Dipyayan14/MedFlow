<?php

namespace Database\Factories;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Patient>
 */
class PatientFactory extends Factory
{
    protected $model = Patient::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'mrn' => 'MRN-2026-' . fake()->unique()->numerify('#####'),
            'first_name' => fake()->firstName(),
            'last_name' => fake()->lastName(),
            'date_of_birth' => fake()->dateTimeBetween('-80 years', '-1 year')->format('Y-m-d'),
            'gender' => fake()->randomElement(['male', 'female', 'other']),
            'phone' => '+91 ' . fake()->numerify('9#########'),
            'address' => fake()->streetAddress() . ', ' . fake()->city(),
            'emergency_contact_name' => fake()->name(),
            'emergency_contact_phone' => '+91 ' . fake()->numerify('9#########'),
            'blood_group' => fake()->randomElement(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
            'created_by' => User::factory(),
        ];
    }
}

