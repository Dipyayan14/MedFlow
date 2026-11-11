<?php

namespace Database\Seeders;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Seeder;

class PatientSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $creator = User::whereIn('role', ['admin', 'duty_desk'])->first()
            ?? User::first()
            ?? User::factory()->create([
                'name' => 'Reception Duty Desk',
                'email' => 'desk@medflow.local',
                'role' => 'duty_desk',
            ]);

        $samplePatients = [
            [
                'mrn' => 'MRN-2026-10001',
                'first_name' => 'Rajesh',
                'last_name' => 'Gupta',
                'date_of_birth' => '1978-04-12',
                'gender' => 'male',
                'phone' => '+91 98765 43210',
                'address' => 'Flat 402, Shanti Vihar, Civil Lines, New Delhi',
                'emergency_contact_name' => 'Sunita Gupta',
                'emergency_contact_phone' => '+91 98765 43211',
                'blood_group' => 'B+',
                'created_by' => $creator->id,
            ],
            [
                'mrn' => 'MRN-2026-10002',
                'first_name' => 'Priya',
                'last_name' => 'Sharma',
                'date_of_birth' => '1992-09-23',
                'gender' => 'female',
                'phone' => '+91 98123 45678',
                'address' => 'B-12 Sector 15, Noida, UP',
                'emergency_contact_name' => 'Amit Sharma',
                'emergency_contact_phone' => '+91 98123 45679',
                'blood_group' => 'O+',
                'created_by' => $creator->id,
            ],
            [
                'mrn' => 'MRN-2026-10003',
                'first_name' => 'Mohammed',
                'last_name' => 'Ali',
                'date_of_birth' => '1965-11-05',
                'gender' => 'male',
                'phone' => '+91 97654 32109',
                'address' => 'House 44, Jamia Enclave, Okhla, New Delhi',
                'emergency_contact_name' => 'Fatima Ali',
                'emergency_contact_phone' => '+91 97654 32110',
                'blood_group' => 'A+',
                'created_by' => $creator->id,
            ],
            [
                'mrn' => 'MRN-2026-10004',
                'first_name' => 'Ananya',
                'last_name' => 'Deshmukh',
                'date_of_birth' => '2001-02-18',
                'gender' => 'female',
                'phone' => '+91 96543 21098',
                'address' => 'Tower 3 Apt 9B, Green Glen Layout, Bangalore',
                'emergency_contact_name' => 'Vikram Deshmukh',
                'emergency_contact_phone' => '+91 96543 21099',
                'blood_group' => 'AB+',
                'created_by' => $creator->id,
            ],
            [
                'mrn' => 'MRN-2026-10005',
                'first_name' => 'Gurpreet',
                'last_name' => 'Singh',
                'date_of_birth' => '1984-07-30',
                'gender' => 'male',
                'phone' => '+91 95432 10987',
                'address' => '78 Model Town, Ludhiana, Punjab',
                'emergency_contact_name' => 'Harpreet Kaur',
                'emergency_contact_phone' => '+91 95432 10988',
                'blood_group' => 'O-',
                'created_by' => $creator->id,
            ],
            [
                'mrn' => 'MRN-2026-10006',
                'first_name' => 'Sneha',
                'last_name' => 'Rao',
                'date_of_birth' => '1995-12-14',
                'gender' => 'female',
                'phone' => '+91 94321 09876',
                'address' => 'Plot 29, Banjara Hills Road No 10, Hyderabad',
                'emergency_contact_name' => 'Kishore Rao',
                'emergency_contact_phone' => '+91 94321 09877',
                'blood_group' => 'A-',
                'created_by' => $creator->id,
            ],
        ];

        foreach ($samplePatients as $data) {
            Patient::updateOrCreate(
                ['mrn' => $data['mrn']],
                $data
            );
        }
    }
}

