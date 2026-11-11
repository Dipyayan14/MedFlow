<?php

namespace Database\Factories;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Appointment>
 */
class AppointmentFactory extends Factory
{
    protected $model = Appointment::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'doctor_id' => User::factory()->state(['role' => 'doctor']),
            'scheduled_at' => now()->addDays(fake()->numberBetween(1, 14))->setHour(fake()->numberBetween(9, 16))->setMinute(fake()->randomElement([0, 15, 30, 45]))->setSecond(0),
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'reason' => fake()->randomElement([
                'Routine Consultation',
                'Follow-up Review',
                'Chest Pain Evaluation',
                'Blood Pressure Check',
                'Post-Op Dressing',
                'Joint Pain Assessment',
            ]),
            'notes' => null,
            'created_by' => User::factory()->state(['role' => 'duty_desk']),
        ];
    }

    /**
     * Set status to checked in.
     */
    public function checkedIn(): static
    {
        return $this->state(fn () => [
            'status' => Appointment::STATUS_CHECKED_IN,
            'token_number' => fake()->numberBetween(1, 50),
        ]);
    }

    /**
     * Set status to completed.
     */
    public function completed(): static
    {
        return $this->state(fn () => [
            'status' => Appointment::STATUS_COMPLETED,
            'token_number' => fake()->numberBetween(1, 50),
            'notes' => 'Patient advised follow-up in 2 weeks with lab results.',
        ]);
    }
}

