<?php

namespace Database\Seeders;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Seeder;

class AppointmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $doctor = User::where('role', 'doctor')->first()
            ?? User::factory()->create([
                'name' => 'Dr. Arvind Sharma',
                'email' => 'doctor@medflow.local',
                'role' => 'doctor',
                'department' => 'Cardiology',
                'specialization' => 'Cardiologist',
            ]);

        $creator = User::whereIn('role', ['duty_desk', 'admin'])->first()
            ?? User::factory()->create([
                'name' => 'Reception Duty Desk',
                'email' => 'desk@medflow.local',
                'role' => 'duty_desk',
            ]);

        $patients = Patient::take(5)->get();
        if ($patients->isEmpty()) {
            $this->call(PatientSeeder::class);
            $patients = Patient::take(5)->get();
        }

        $today = now()->format('Y-m-d');

        $schedule = [
            ['time' => '09:00:00', 'status' => Appointment::STATUS_COMPLETED, 'token' => 1, 'reason' => 'Post Angioplasty Follow-up', 'notes' => 'Patient vitals stable. Continued existing medication.'],
            ['time' => '09:30:00', 'status' => Appointment::STATUS_IN_CONSULTATION, 'token' => 2, 'reason' => 'Chest Discomfort & ECG Review', 'notes' => null],
            ['time' => '10:00:00', 'status' => Appointment::STATUS_CHECKED_IN, 'token' => 3, 'reason' => 'Routine Cardiology Review & Lipid Check', 'notes' => null],
            ['time' => '10:30:00', 'status' => Appointment::STATUS_SCHEDULED, 'token' => null, 'reason' => 'Hypertension Medication Adjustment', 'notes' => null],
            ['time' => '11:00:00', 'status' => Appointment::STATUS_SCHEDULED, 'token' => null, 'reason' => 'Palpitations & Holter Monitoring', 'notes' => null],
        ];

        foreach ($schedule as $idx => $slot) {
            $patient = $patients[$idx % $patients->count()];
            $scheduledAt = "{$today} {$slot['time']}";

            Appointment::updateOrCreate(
                [
                    'doctor_id' => $doctor->id,
                    'scheduled_at' => $scheduledAt,
                ],
                [
                    'patient_id' => $patient->id,
                    'status' => $slot['status'],
                    'token_number' => $slot['token'],
                    'reason' => $slot['reason'],
                    'notes' => $slot['notes'],
                    'created_by' => $creator->id,
                ]
            );
        }
    }
}

