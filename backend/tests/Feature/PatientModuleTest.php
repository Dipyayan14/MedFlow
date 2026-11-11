<?php

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PatientModuleTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private User $dutyDesk;
    private User $doctor;
    private User $nurse;
    private User $staff;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->create(['role' => 'admin']);
        $this->dutyDesk = User::factory()->create(['role' => 'duty_desk']);
        $this->doctor = User::factory()->create(['role' => 'doctor']);
        $this->nurse = User::factory()->create(['role' => 'nurse']);
        $this->staff = User::factory()->create(['role' => 'staff']);
    }

    public function test_unauthenticated_request_is_rejected_with_401(): void
    {
        $this->getJson('/api/patients')->assertStatus(401);
        $this->postJson('/api/patients', [])->assertStatus(401);
    }

    public function test_staff_role_cannot_access_any_patient_endpoints(): void
    {
        $patient = Patient::factory()->create(['created_by' => $this->admin->id]);

        $this->actingAs($this->staff, 'sanctum')->getJson('/api/patients')->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->getJson("/api/patients/{$patient->id}")->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->postJson('/api/patients', [])->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->putJson("/api/patients/{$patient->id}", [])->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->deleteJson("/api/patients/{$patient->id}")->assertStatus(403);
    }

    public function test_doctor_and_nurse_can_view_patients_but_cannot_create_update_or_delete(): void
    {
        $patient = Patient::factory()->create(['created_by' => $this->admin->id]);

        $payload = [
            'first_name' => 'Kavita',
            'last_name' => 'Mehta',
            'date_of_birth' => '1990-05-10',
            'gender' => 'female',
            'phone' => '+91 99999 11111',
            'address' => 'Sample Address',
            'emergency_contact_name' => 'Emergency Name',
            'emergency_contact_phone' => '+91 99999 22222',
            'blood_group' => 'A+',
        ];

        foreach ([$this->doctor, $this->nurse] as $clinician) {
            // View list: allowed (200)
            $this->actingAs($clinician, 'sanctum')
                ->getJson('/api/patients')
                ->assertStatus(200);

            // View single: allowed (200)
            $this->actingAs($clinician, 'sanctum')
                ->getJson("/api/patients/{$patient->id}")
                ->assertStatus(200)
                ->assertJsonPath('patient.id', $patient->id);

            // Create: forbidden (403)
            $this->actingAs($clinician, 'sanctum')
                ->postJson('/api/patients', $payload)
                ->assertStatus(403);

            // Update: forbidden (403)
            $this->actingAs($clinician, 'sanctum')
                ->putJson("/api/patients/{$patient->id}", ['first_name' => 'Updated'])
                ->assertStatus(403);

            // Delete: forbidden (403)
            $this->actingAs($clinician, 'sanctum')
                ->deleteJson("/api/patients/{$patient->id}")
                ->assertStatus(403);
        }
    }

    public function test_duty_desk_can_view_create_and_update_but_cannot_delete(): void
    {
        $patient = Patient::factory()->create(['created_by' => $this->dutyDesk->id]);

        // View: allowed
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->getJson('/api/patients')
            ->assertStatus(200);

        // Create: allowed
        $createResponse = $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/patients', [
                'first_name' => 'Aman',
                'last_name' => 'Verma',
                'date_of_birth' => '1985-01-15',
                'gender' => 'male',
                'phone' => '+91 98888 77777',
                'address' => '22 MG Road, Delhi',
                'emergency_contact_name' => 'Pooja Verma',
                'emergency_contact_phone' => '+91 98888 66666',
                'blood_group' => 'B+',
            ]);

        $createResponse->assertStatus(201)
            ->assertJsonPath('patient.first_name', 'Aman')
            ->assertJsonPath('patient.created_by', $this->dutyDesk->id);

        $newPatientId = $createResponse->json('patient.id');

        // Update: allowed
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->putJson("/api/patients/{$newPatientId}", [
                'phone' => '+91 98888 00000',
            ])
            ->assertStatus(200)
            ->assertJsonPath('patient.phone', '+91 98888 00000');

        // Delete: forbidden
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->deleteJson("/api/patients/{$newPatientId}")
            ->assertStatus(403);
    }

    public function test_admin_can_perform_all_operations_including_delete(): void
    {
        $patient = Patient::factory()->create(['created_by' => $this->admin->id]);

        // Index
        $this->actingAs($this->admin, 'sanctum')
            ->getJson('/api/patients')
            ->assertStatus(200);

        // Show
        $this->actingAs($this->admin, 'sanctum')
            ->getJson("/api/patients/{$patient->id}")
            ->assertStatus(200);

        // Update
        $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/patients/{$patient->id}", [
                'first_name' => 'AdminUpdated',
            ])
            ->assertStatus(200)
            ->assertJsonPath('patient.first_name', 'AdminUpdated');

        // Delete (soft delete)
        $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("/api/patients/{$patient->id}")
            ->assertStatus(200)
            ->assertJson(['message' => 'Patient deleted successfully']);

        // Verify patient is soft deleted
        $this->assertSoftDeleted('patients', ['id' => $patient->id]);
    }

    public function test_patient_search_by_name_phone_and_mrn(): void
    {
        Patient::factory()->create([
            'first_name' => 'Rohan',
            'last_name' => 'Kapoor',
            'phone' => '+91 91111 22222',
            'mrn' => 'MRN-2026-99991',
            'created_by' => $this->admin->id,
        ]);

        Patient::factory()->create([
            'first_name' => 'Sunil',
            'last_name' => 'Narang',
            'phone' => '+91 93333 44444',
            'mrn' => 'MRN-2026-99992',
            'created_by' => $this->admin->id,
        ]);

        // Search by first name
        $res = $this->actingAs($this->doctor, 'sanctum')
            ->getJson('/api/patients?search=Rohan')
            ->assertStatus(200);
        $this->assertCount(1, $res->json('data'));
        $this->assertEquals('Rohan', $res->json('data.0.first_name'));

        // Search by phone
        $res = $this->actingAs($this->doctor, 'sanctum')
            ->getJson('/api/patients?search=93333')
            ->assertStatus(200);
        $this->assertCount(1, $res->json('data'));
        $this->assertEquals('Sunil', $res->json('data.0.first_name'));

        // Search by MRN
        $res = $this->actingAs($this->doctor, 'sanctum')
            ->getJson('/api/patients?search=99991')
            ->assertStatus(200);
        $this->assertCount(1, $res->json('data'));
        $this->assertEquals('MRN-2026-99991', $res->json('data.0.mrn'));
    }

    public function test_patient_pagination(): void
    {
        Patient::factory()->count(25)->create(['created_by' => $this->admin->id]);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson('/api/patients?per_page=10&page=1')
            ->assertStatus(200);

        $this->assertCount(10, $response->json('data'));
        $this->assertEquals(25, $response->json('total'));
        $this->assertEquals(1, $response->json('current_page'));
        $this->assertEquals(3, $response->json('last_page'));
    }

    public function test_auto_generates_mrn_if_empty_on_create(): void
    {
        $response = $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/patients', [
                'first_name' => 'Auto',
                'last_name' => 'MRNTest',
                'date_of_birth' => '1995-03-20',
                'gender' => 'other',
                'phone' => '+91 97777 88888',
                'address' => 'Test Address',
                'emergency_contact_name' => 'Contact',
                'emergency_contact_phone' => '+91 97777 99999',
            ]);

        $response->assertStatus(201);
        $mrn = $response->json('patient.mrn');
        $this->assertNotEmpty($mrn);
        $this->assertStringStartsWith('MRN-', $mrn);
    }
}

