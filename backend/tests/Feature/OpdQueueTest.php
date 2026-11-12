<?php

namespace Tests\Feature;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OpdQueueTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private User $dutyDesk;
    private User $nurse;
    private User $doctorA;
    private User $doctorB;
    private User $staff;
    private Patient $patientA;
    private Patient $patientB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::factory()->create(['role' => 'admin']);
        $this->dutyDesk = User::factory()->create(['role' => 'duty_desk']);
        $this->nurse = User::factory()->create(['role' => 'nurse']);
        $this->doctorA = User::factory()->create(['role' => 'doctor']);
        $this->doctorB = User::factory()->create(['role' => 'doctor']);
        $this->staff = User::factory()->create(['role' => 'staff']);

        $this->patientA = Patient::factory()->create(['created_by' => $this->dutyDesk->id]);
        $this->patientB = Patient::factory()->create(['created_by' => $this->dutyDesk->id]);
    }

    public function test_unauthenticated_requests_are_rejected_with_401(): void
    {
        $this->getJson('/api/opd/queue')->assertStatus(401);
        $this->postJson('/api/opd/check-in', [])->assertStatus(401);
        $this->postJson('/api/opd/call-next', [])->assertStatus(401);
        $this->postJson('/api/opd/complete', [])->assertStatus(401);
    }

    public function test_staff_role_cannot_access_any_opd_queue_endpoints(): void
    {
        $this->actingAs($this->staff, 'sanctum')->getJson('/api/opd/queue')->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->postJson('/api/opd/check-in', [])->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->postJson('/api/opd/call-next', [])->assertStatus(403);
        $this->actingAs($this->staff, 'sanctum')->postJson('/api/opd/complete', [])->assertStatus(403);
    }

    public function test_opd_queue_orders_by_status_and_time(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        // 1. Scheduled at 11:00
        $apptScheduled = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 11:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        // 2. Checked-in at 10:00 (token 1)
        $apptCheckedIn = Appointment::factory()->create([
            'patient_id' => $this->patientB->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 10:00:00",
            'status' => Appointment::STATUS_CHECKED_IN,
            'token_number' => 1,
            'created_by' => $this->dutyDesk->id,
        ]);

        // 3. Completed at 09:00 (token 2)
        $apptCompleted = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 09:00:00",
            'status' => Appointment::STATUS_COMPLETED,
            'token_number' => 2,
            'created_by' => $this->dutyDesk->id,
        ]);

        // 4. In consultation at 12:00 (token 3)
        $apptInConsultation = Appointment::factory()->create([
            'patient_id' => $this->patientB->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 12:00:00",
            'status' => Appointment::STATUS_IN_CONSULTATION,
            'token_number' => 3,
            'created_by' => $this->dutyDesk->id,
        ]);

        $response = $this->actingAs($this->doctorA, 'sanctum')
            ->getJson("/api/opd/queue?date={$today}")
            ->assertStatus(200);

        $data = $response->json('data');
        $this->assertCount(4, $data);

        // Expectation: in_consultation (index 0) -> checked_in (index 1) -> scheduled (index 2) -> completed (index 3)
        $this->assertEquals($apptInConsultation->id, $data[0]['id']);
        $this->assertEquals(Appointment::STATUS_IN_CONSULTATION, $data[0]['status']);

        $this->assertEquals($apptCheckedIn->id, $data[1]['id']);
        $this->assertEquals(Appointment::STATUS_CHECKED_IN, $data[1]['status']);

        $this->assertEquals($apptScheduled->id, $data[2]['id']);
        $this->assertEquals(Appointment::STATUS_SCHEDULED, $data[2]['status']);

        $this->assertEquals($apptCompleted->id, $data[3]['id']);
        $this->assertEquals(Appointment::STATUS_COMPLETED, $data[3]['status']);

        // Check counts
        $this->assertEquals(1, $response->json('counts.in_consultation'));
        $this->assertEquals(1, $response->json('counts.waiting'));
        $this->assertEquals(1, $response->json('counts.scheduled'));
        $this->assertEquals(1, $response->json('counts.completed'));
    }

    public function test_doctor_cannot_view_another_doctors_opd_queue(): void
    {
        $this->actingAs($this->doctorA, 'sanctum')
            ->getJson("/api/opd/queue?doctor_id={$this->doctorB->id}")
            ->assertStatus(403);
    }

    public function test_duty_desk_nurse_and_admin_can_view_opd_queue(): void
    {
        $this->actingAs($this->dutyDesk, 'sanctum')->getJson('/api/opd/queue')->assertStatus(200);
        $this->actingAs($this->nurse, 'sanctum')->getJson('/api/opd/queue')->assertStatus(200);
        $this->actingAs($this->admin, 'sanctum')->getJson('/api/opd/queue')->assertStatus(200);
    }

    public function test_all_three_check_in_paths_issue_server_generated_token_and_status(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        $appt1 = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 09:30:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        $appt2 = Appointment::factory()->create([
            'patient_id' => $this->patientB->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 10:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        $appt3 = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 10:30:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Path 1: POST /api/opd/check-in (duty_desk) -> token 1
        $res1 = $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $appt1->id])
            ->assertStatus(200)
            ->assertJsonPath('token_number', 1)
            ->assertJsonPath('appointment.status', Appointment::STATUS_CHECKED_IN);
        $this->assertEquals(1, $appt1->fresh()->token_number);
        $this->assertEquals(Appointment::STATUS_CHECKED_IN, $appt1->fresh()->status);

        // Path 2: POST /api/appointments/{id}/check-in (nurse) -> token 2
        $res2 = $this->actingAs($this->nurse, 'sanctum')
            ->postJson("/api/appointments/{$appt2->id}/check-in")
            ->assertStatus(200)
            ->assertJsonPath('token_number', 2)
            ->assertJsonPath('appointment.status', Appointment::STATUS_CHECKED_IN);
        $this->assertEquals(2, $appt2->fresh()->token_number);
        $this->assertEquals(Appointment::STATUS_CHECKED_IN, $appt2->fresh()->status);

        // Path 3: PATCH /api/appointments/{id} with status->checked_in (admin) -> token 3
        $res3 = $this->actingAs($this->admin, 'sanctum')
            ->patchJson("/api/appointments/{$appt3->id}", ['status' => Appointment::STATUS_CHECKED_IN])
            ->assertStatus(200)
            ->assertJsonPath('appointment.token_number', 3)
            ->assertJsonPath('appointment.status', Appointment::STATUS_CHECKED_IN);
        $this->assertEquals(3, $appt3->fresh()->token_number);
        $this->assertEquals(Appointment::STATUS_CHECKED_IN, $appt3->fresh()->status);
    }

    public function test_token_numbering_is_sequential_per_doctor_per_day(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        // 2 appointments for Doctor A today
        $apptA1 = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 09:30:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        $apptA2 = Appointment::factory()->create([
            'patient_id' => $this->patientB->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 10:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        // 1 appointment for Doctor B today
        $apptB1 = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorB->id,
            'scheduled_at' => "{$today} 09:30:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'token_number' => null,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Check in Doctor A appt 1 -> token 1
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $apptA1->id])
            ->assertStatus(200)
            ->assertJsonPath('token_number', 1);

        // Check in Doctor A appt 2 -> token 2
        $this->actingAs($this->nurse, 'sanctum')
            ->postJson("/api/appointments/{$apptA2->id}/check-in")
            ->assertStatus(200)
            ->assertJsonPath('token_number', 2);

        // Check in Doctor B appt 1 today -> token 1 (independent of Doctor A)
        $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $apptB1->id])
            ->assertStatus(200)
            ->assertJsonPath('token_number', 1);
    }

    public function test_check_in_is_refused_with_422_unless_scheduled_at_is_today_in_asia_kolkata(): void
    {
        $tomorrowKolkata = Carbon::now('Asia/Kolkata')->addDays(1)->format('Y-m-d');
        $yesterdayKolkata = Carbon::now('Asia/Kolkata')->subDays(1)->format('Y-m-d');

        $apptTomorrow = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$tomorrowKolkata} 10:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        $apptYesterday = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$yesterdayKolkata} 10:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Path 1 fails for tomorrow
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $apptTomorrow->id])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['appointment']);

        // Path 2 fails for yesterday
        $this->actingAs($this->nurse, 'sanctum')
            ->postJson("/api/appointments/{$apptYesterday->id}/check-in")
            ->assertStatus(422)
            ->assertJsonValidationErrors(['appointment']);

        // Path 3 (PATCH update) fails for tomorrow
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->patchJson("/api/appointments/{$apptTomorrow->id}", ['status' => Appointment::STATUS_CHECKED_IN])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['appointment']);
    }

    public function test_check_in_role_rules_and_invalid_state_rejection(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        $appt = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 14:00:00",
            'status' => Appointment::STATUS_SCHEDULED,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Doctor cannot check in
        $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $appt->id])
            ->assertStatus(403);

        // Cancelled appointment cannot be checked in
        $cancelledAppt = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 15:00:00",
            'status' => Appointment::STATUS_CANCELLED,
            'created_by' => $this->dutyDesk->id,
        ]);
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $cancelledAppt->id])
            ->assertStatus(422);

        // Completed appointment cannot be checked in
        $completedAppt = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 16:00:00",
            'status' => Appointment::STATUS_COMPLETED,
            'created_by' => $this->dutyDesk->id,
        ]);
        $this->actingAs($this->nurse, 'sanctum')
            ->postJson('/api/opd/check-in', ['appointment_id' => $completedAppt->id])
            ->assertStatus(422);
    }

    public function test_call_next_role_rules_and_automatic_queue_selection(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        $appt1 = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 09:00:00",
            'status' => Appointment::STATUS_CHECKED_IN,
            'token_number' => 1,
            'created_by' => $this->dutyDesk->id,
        ]);

        $appt2 = Appointment::factory()->create([
            'patient_id' => $this->patientB->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 09:30:00",
            'status' => Appointment::STATUS_CHECKED_IN,
            'token_number' => 2,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Duty desk and nurse cannot call next -> 403
        $this->actingAs($this->dutyDesk, 'sanctum')->postJson('/api/opd/call-next')->assertStatus(403);
        $this->actingAs($this->nurse, 'sanctum')->postJson('/api/opd/call-next')->assertStatus(403);

        // Doctor B cannot call Doctor A's patient
        $this->actingAs($this->doctorB, 'sanctum')
            ->postJson('/api/opd/call-next', ['appointment_id' => $appt1->id])
            ->assertStatus(403);

        // Assigned doctor A automatically calls next patient -> picks appt1 (token 1)
        $res = $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/call-next')
            ->assertStatus(200);

        $this->assertEquals($appt1->id, $res->json('appointment.id'));
        $this->assertEquals(Appointment::STATUS_IN_CONSULTATION, $res->json('appointment.status'));

        // Calling next again picks appt2 (token 2)
        $res2 = $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/call-next')
            ->assertStatus(200);

        $this->assertEquals($appt2->id, $res2->json('appointment.id'));
        $this->assertEquals(Appointment::STATUS_IN_CONSULTATION, $res2->json('appointment.status'));

        // Calling next with empty queue returns 404
        $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/call-next')
            ->assertStatus(404);
    }

    public function test_status_order_rule_cannot_complete_before_in_consultation(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        $appt = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 10:00:00",
            'status' => Appointment::STATUS_CHECKED_IN,
            'token_number' => 1,
            'created_by' => $this->dutyDesk->id,
        ]);

        // Non-assigned doctor or duty desk cannot complete
        $this->actingAs($this->dutyDesk, 'sanctum')
            ->postJson('/api/opd/complete', ['appointment_id' => $appt->id])
            ->assertStatus(403);

        $this->actingAs($this->doctorB, 'sanctum')
            ->postJson('/api/opd/complete', ['appointment_id' => $appt->id])
            ->assertStatus(403);

        // Doctor A attempts to complete while status is checked_in -> 422 Status order violation
        $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/complete', [
                'appointment_id' => $appt->id,
                'notes' => 'Early notes',
            ])
            ->assertStatus(422)
            ->assertJsonPath('current_status', Appointment::STATUS_CHECKED_IN);

        // Doctor A calls patient -> in_consultation
        $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/call-next', ['appointment_id' => $appt->id])
            ->assertStatus(200);

        // Now Doctor A can complete
        $resComplete = $this->actingAs($this->doctorA, 'sanctum')
            ->postJson('/api/opd/complete', [
                'appointment_id' => $appt->id,
                'notes' => 'Prescribed paracetamol 500mg TDS for 3 days.',
            ])
            ->assertStatus(200)
            ->assertJsonPath('appointment.status', Appointment::STATUS_COMPLETED)
            ->assertJsonPath('appointment.notes', 'Prescribed paracetamol 500mg TDS for 3 days.');

        $this->assertEquals(Appointment::STATUS_COMPLETED, $appt->fresh()->status);
        $this->assertEquals('Prescribed paracetamol 500mg TDS for 3 days.', $appt->fresh()->notes);
    }

    public function test_notes_field_sanitized_in_opd_queue(): void
    {
        $today = Carbon::now('Asia/Kolkata')->format('Y-m-d');

        $appt = Appointment::factory()->create([
            'patient_id' => $this->patientA->id,
            'doctor_id' => $this->doctorA->id,
            'scheduled_at' => "{$today} 10:00:00",
            'status' => Appointment::STATUS_COMPLETED,
            'notes' => 'Confidential diagnosis notes.',
            'created_by' => $this->dutyDesk->id,
        ]);

        // Duty desk and nurse cannot see notes
        $dutyRes = $this->actingAs($this->dutyDesk, 'sanctum')
            ->getJson("/api/opd/queue?date={$today}&doctor_id={$this->doctorA->id}")
            ->assertStatus(200);
        $this->assertArrayNotHasKey('notes', $dutyRes->json('data.0'));

        $nurseRes = $this->actingAs($this->nurse, 'sanctum')
            ->getJson("/api/opd/queue?date={$today}&doctor_id={$this->doctorA->id}")
            ->assertStatus(200);
        $this->assertArrayNotHasKey('notes', $nurseRes->json('data.0'));

        // Assigned doctor CAN see notes
        $docRes = $this->actingAs($this->doctorA, 'sanctum')
            ->getJson("/api/opd/queue?date={$today}")
            ->assertStatus(200);
        $this->assertArrayHasKey('notes', $docRes->json('data.0'));
        $this->assertEquals('Confidential diagnosis notes.', $docRes->json('data.0.notes'));
    }
}

