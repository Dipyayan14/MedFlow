<?php

namespace Tests\Feature;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AppointmentModuleTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private User $dutyDesk;
    private User $nurse;
    private User $doctorA;
    private User $doctorB;
    private User $staff;
    private Patient $patient;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->create(['role' => 'admin']);
        $this->dutyDesk = User::factory()->create(['role' => 'duty_desk']);
        $this->nurse = User::factory()->create(['role' => 'nurse']);
        $this->doctorA = User::factory()->create(['role' => 'doctor']);
        $this->doctorB = User::factory()->create(['role' => 'doctor']);
        $this->staff = User::factory()->create(['role' => 'staff']);

        $this->patient = Patient::factory()->create(['created_by' => $this->dutyDesk->id]);
    }

    public function test_unauthenticated_request_is_rejected_with_401(): void
    {
        $this->getJson('/api/appointments')->assertStatus(401);
        $this->postJson('/api/appointments', [])->assertStatus(401);
    }

    public function test_staff_role_cannot_access_any_appointment_endpoints(): void
    {
        $appointment = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'created_by' => $this->dutyDesk->id,
        ]);

        $this->actingAs($this->staff, 'sanctum')->getJson('/api/appointments')->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->getJson("/api/appointments/{$appointment->id}")->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->postJson('/api/appointments', [])->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->putJson("/api/appointments/{$appointment->id}", [])->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->deleteJson("/api/appointments/{$appointment->id}")->assertStatus(403);
    }

    public function test_duty_desk_and_admin_can_create_appointments(): void
    {
        $futureTime = now()->addDays(2)->setHour(10)->setMinute(0)->setSecond(0)->toDateTimeString();

        $payload = [
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => $futureTime,
            'reason' => 'Routine cardiology consultation',
        ];

        // Duty desk can create
        $response = $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/appointments', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('appointment.status', Appointment::STATUS_SCHEDULED)
            ->assertJsonPath('appointment.doctor_id', $this->doctorA->id)
            ->assertJsonPath('appointment.created_by', $this->dutyDesk->id);

        // Admin can create
        $futureTime2 = now()->addDays(2)->setHour(11)->setMinute(0)->setSecond(0)->toDateTimeString();
        $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/appointments', [
                'patient_id' => $this->patient->id,
                'doctor_id' => $this->doctorA->id,
                'scheduled_at' => $futureTime2,
                'reason' => 'Admin scheduled consultation',
            ])
            ->assertStatus(201);
    }

    public function test_doctor_and_nurse_cannot_create_appointments(): void
    {
        $futureTime = now()->addDays(2)->setHour(10)->setMinute(0)->setSecond(0)->toDateTimeString();

        $payload = [
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => $futureTime,
        ];

        $this->actingAs($this->doctorA, 'sanctum')->postJson('/api/appointments', $payload)->assertStatus(403);
        $this->actingAs($this->nurse, 'sanctum')->postJson('/api/appointments', $payload)->assertStatus(403);
    }

    public function test_validation_rejects_non_doctor_user_as_doctor_id(): void
    {
        $futureTime = now()->addDays(2)->setHour(10)->setMinute(0)->setSecond(0)->toDateTimeString();

        $response = $this->actingAs($this->dutyDesk, 'sanctum')->postJson('/api/appointments', [
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->nurse->id, // Nurse ID, not doctor
            'scheduled_at' => $futureTime,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['doctor_id']);
    }

    public function test_validation_rejects_past_scheduled_at_on_create(): void
    {
        $pastTime = now()->subHours(2)->toDateTimeString();

        $response = $this->actingAs($this->dutyDesk, 'sanctum')->postJson('/api/appointments', [
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => $pastTime,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['scheduled_at']);
    }

    public function test_validation_rejects_double_booking_for_same_doctor_at_same_time(): void
    {
        $scheduledTime = now()->addDays(3)->setHour(14)->setMinute(0)->setSecond(0)->toDateTimeString();

        // Create first appointment
        Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => $scheduledTime,
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Attempt second appointment with same doctor at same time -> 422
        $response = $this->actingAs($this->dutyDesk, 'sanctum')->postJson('/api/appointments', [
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => $scheduledTime,
            'reason' => 'Conflicting booking',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['scheduled_at']);

        // Booking the same time with a DIFFERENT doctor is allowed
        $this->actingAs($this->dutyDesk, 'sanctum')->postJson('/api/appointments', [
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorB->id,
            'scheduled_at' => $scheduledTime,
            'reason' => 'Different doctor booking',
        ])->assertStatus(201);
    }

    public function test_doctor_sees_only_own_appointments_and_cannot_read_another_doctors_appointment(): void
    {
        $apptA = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => now()->addDay()->toDateTimeString(),
            'created_by' => $this->dutyDesk->id,
        ]);

        $apptB = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorB->id,
            'scheduled_at' => now()->addDay()->toDateTimeString(),
            'created_by' => $this->dutyDesk->id,
        ]);

        // Doctor A viewing index sees only apptA
        $indexResponse = $this->actingAs($this->doctorA, 'sanctum')->getJson('/api/appointments');
        $indexResponse->assertStatus(200);
        $ids = collect($indexResponse->json('data'))->pluck('id')->all();
        $this->assertContains($apptA->id, $ids);
        $this->assertNotContains($apptB->id, $ids);

        // Doctor A reading own appointment gets 200
        $this->actingAs($this->doctorA, 'sanctum')
            ->getJson("/api/appointments/{$apptA->id}")
            ->assertStatus(200)
            ->assertJsonPath('appointment.id', $apptA->id);

        // Doctor A reading Doctor B's appointment gets 403
        $this->actingAs($this->doctorA, 'sanctum')
            ->getJson("/api/appointments/{$apptB->id}")
            ->assertStatus(403);
    }

    public function test_nurse_duty_desk_and_admin_can_view_any_appointment(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'created_by' => $this->dutyDesk->id,
        ]);

        $this->actingAs($this->nurse, 'sanctum')->getJson("/api/appointments/{$appt->id}")->assertStatus(200);
        $this->actingAs($this->dutyDesk, 'sanctum')->getJson("/api/appointments/{$appt->id}")->assertStatus(200);
        $this->actingAs($this->admin, 'sanctum')->getJson("/api/appointments/{$appt->id}")->assertStatus(200);
    }

    public function test_rescheduling_rules(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => now()->addDays(2)->toDateTimeString(),
            'created_by' => $this->dutyDesk->id,
        ]);

        $newTime = now()->addDays(5)->setHour(12)->setMinute(0)->setSecond(0)->toDateTimeString();

        // Duty desk can reschedule
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", ['scheduled_at' => $newTime])
            ->assertStatus(200)
            ->assertJsonPath('appointment.scheduled_at', Carbon::parse($newTime)->toISOString());

        // Doctor and nurse cannot reschedule
        $this->actingAs($this->doctorA, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", ['scheduled_at' => now()->addDays(6)->toDateTimeString()])
            ->assertStatus(403);

        $this->actingAs($this->nurse, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", ['scheduled_at' => now()->addDays(6)->toDateTimeString()])
            ->assertStatus(403);
    }

    public function test_cancel_rules(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Duty desk and admin can cancel
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", ['status' => Appointment::STATUS_CANCELLED])
            ->assertStatus(200)
            ->assertJsonPath('appointment.status', Appointment::STATUS_CANCELLED);

        // Doctor and nurse cannot cancel
        $appt2 = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'created_by' => $this->dutyDesk->id,
        ]);

        $this->actingAs($this->doctorA, 'sanctum')
            ->putJson("/api/appointments/{$appt2->id}", ['status' => Appointment::STATUS_CANCELLED])
            ->assertStatus(403);

        $this->actingAs($this->nurse, 'sanctum')
            ->putJson("/api/appointments/{$appt2->id}", ['status' => Appointment::STATUS_CANCELLED])
            ->assertStatus(403);
    }

    public function test_check_in_rules(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 11:30:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Nurse can check in
        $this->actingAs($this->nurse, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", ['status' => Appointment::STATUS_CHECKED_IN])
            ->assertStatus(200)
            ->assertJsonPath('appointment.status', Appointment::STATUS_CHECKED_IN)
            ->assertJsonPath('appointment.token_number', 1);

        // Reset
        $appt->update(['status' => Appointment::STATUS_SCHEDULED, 'token_number' => null]);

        // Duty desk can check in
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", ['status' => Appointment::STATUS_CHECKED_IN])
            ->assertStatus(200)
            ->assertJsonPath('appointment.status', Appointment::STATUS_CHECKED_IN)
            ->assertJsonPath('appointment.token_number', 1);
    }

    public function test_consultation_status_and_notes_restricted_to_assigned_doctor_only(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'status' => Appointment::STATUS_CHECKED_IN,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Assigned doctor A can start consultation and write notes
        $this->actingAs($this->doctorA, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'status' => Appointment::STATUS_IN_CONSULTATION,
            ])
            ->assertStatus(200)
            ->assertJsonPath('appointment.status', Appointment::STATUS_IN_CONSULTATION);

        $this->actingAs($this->doctorA, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'status' => Appointment::STATUS_COMPLETED,
                'notes' => 'Patient advised rest and ECG review in 7 days.',
            ])
            ->assertStatus(200)
            ->assertJsonPath('appointment.status', Appointment::STATUS_COMPLETED)
            ->assertJsonPath('appointment.notes', 'Patient advised rest and ECG review in 7 days.');

        // Another doctor B cannot update status or write notes for Doctor A's appointment
        $this->actingAs($this->doctorB, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'notes' => 'Unauthorized notes by Doctor B',
            ])
            ->assertStatus(403);

        $this->actingAs($this->doctorB, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'status' => Appointment::STATUS_COMPLETED,
            ])
            ->assertStatus(403);

        // Duty desk and nurse cannot start consultation or write notes
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'notes' => 'Notes by duty desk',
            ])
            ->assertStatus(403);

        $this->actingAs($this->nurse, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'status' => Appointment::STATUS_IN_CONSULTATION,
            ])
            ->assertStatus(403);
    }

    public function test_delete_restricted_to_admin_only_and_soft_deletes(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Doctor, nurse, and duty desk cannot delete
        $this->actingAs($this->doctorA, 'sanctum')->deleteJson("/api/appointments/{$appt->id}")->assertStatus(403);
        $this->actingAs($this->nurse, 'sanctum')->deleteJson("/api/appointments/{$appt->id}")->assertStatus(403);
        $this->actingAs($this->dutyDesk, 'sanctum')->deleteJson("/api/appointments/{$appt->id}")->assertStatus(403);

        // Admin can delete
        $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("/api/appointments/{$appt->id}")
            ->assertStatus(200)
            ->assertJson(['message' => 'Appointment deleted successfully']);

        // Verify soft deleted
        $this->assertSoftDeleted('appointments', ['id' => $appt->id]);
    }

    public function test_appointment_filters_and_pagination(): void
    {
        $targetDate = now()->addDays(4)->format('Y-m-d');

        Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$targetDate} 09:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$targetDate} 10:00:00",
            'status' => Appointment::STATUS_COMPLETED,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Filter by date
        $res = $this->actingAs($this->admin, 'sanctum')
            ->getJson("/api/appointments?date={$targetDate}")
            ->assertStatus(200);
        $this->assertCount(2, $res->json('data'));

        // Filter by status
        $resStatus = $this->actingAs($this->admin, 'sanctum')
            ->getJson("/api/appointments?date={$targetDate}&status=completed")
            ->assertStatus(200);
        $this->assertCount(1, $resStatus->json('data'));
        $this->assertEquals(Appointment::STATUS_COMPLETED, $resStatus->json('data.0.status'));
    }

    public function test_notes_field_is_hidden_from_unauthorized_roles_in_show_and_index(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'notes' => 'Highly confidential doctor assessment and prescription.',
            'created_by' => $this->dutyDesk->id,
        ]);

        // Assigned doctor A sees notes in show
        $this->actingAs($this->doctorA, 'sanctum')
            ->getJson("/api/appointments/{$appt->id}")
            ->assertStatus(200)
            ->assertJsonPath('appointment.notes', 'Highly confidential doctor assessment and prescription.');

        // Admin sees notes in show
        $this->actingAs($this->admin, 'sanctum')
            ->getJson("/api/appointments/{$appt->id}")
            ->assertStatus(200)
            ->assertJsonPath('appointment.notes', 'Highly confidential doctor assessment and prescription.');

        // Nurse DOES NOT see notes in show
        $nurseShow = $this->actingAs($this->nurse, 'sanctum')
            ->getJson("/api/appointments/{$appt->id}")
            ->assertStatus(200);
        $this->assertArrayNotHasKey('notes', $nurseShow->json('appointment'));

        // Duty desk DOES NOT see notes in show
        $dutyShow = $this->actingAs($this->dutyDesk, 'sanctum')
            ->getJson("/api/appointments/{$appt->id}")
            ->assertStatus(200);
        $this->assertArrayNotHasKey('notes', $dutyShow->json('appointment'));

        // In index:
        // Duty desk index response does not have notes
        $dutyIndex = $this->actingAs($this->dutyDesk, 'sanctum')
            ->getJson('/api/appointments')
            ->assertStatus(200);
        $this->assertArrayNotHasKey('notes', $dutyIndex->json('data.0'));

        // Nurse index response does not have notes
        $nurseIndex = $this->actingAs($this->nurse, 'sanctum')
            ->getJson('/api/appointments')
            ->assertStatus(200);
        $this->assertArrayNotHasKey('notes', $nurseIndex->json('data.0'));

        // Assigned doctor A index response DOES have notes
        $docIndex = $this->actingAs($this->doctorA, 'sanctum')
            ->getJson('/api/appointments')
            ->assertStatus(200);
        $this->assertArrayHasKey('notes', $docIndex->json('data.0'));
        $this->assertEquals('Highly confidential doctor assessment and prescription.', $docIndex->json('data.0.notes'));
    }

    public function test_update_rejects_mixed_or_unauthorized_fields_with_403(): void
    {
        $appt = Appointment::factory()->create([
            'patient_id' => $this->patient->id,
            'doctor_id' => $this->doctorA->id,
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        $futureTime = now()->addDays(2)->setHour(14)->setMinute(0)->toDateTimeString();

        // Duty desk attempting to update scheduled_at AND sneak in notes -> 403 Forbidden
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'scheduled_at' => $futureTime,
                'notes' => 'Tampered notes',
            ])
            ->assertStatus(403);

        // Nurse attempting to update status AND sneak in reason or scheduled_at -> 403 Forbidden
        $this->actingAs($this->nurse, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'status' => Appointment::STATUS_CHECKED_IN,
                'reason' => 'Changed reason',
            ])
            ->assertStatus(403);

        // Doctor attempting to change scheduled_at -> 403 Forbidden
        $this->actingAs($this->doctorA, 'sanctum')
            ->putJson("/api/appointments/{$appt->id}", [
                'scheduled_at' => $futureTime,
                'notes' => 'Some doctor notes',
            ])
            ->assertStatus(403);
    }
}
