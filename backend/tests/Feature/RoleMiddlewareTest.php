<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class RoleMiddlewareTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Register a multi-role route to test comma-separated roles parameter (e.g. role:doctor,nurse)
        Route::middleware(['auth:sanctum', 'role:doctor,nurse'])->get('/api/test/clinical', function () {
            return response()->json(['message' => 'Clinical access granted']);
        });
    }

    public function test_unauthenticated_user_gets_401(): void
    {
        $response = $this->getJson('/api/admin/dashboard');

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }

    public function test_user_with_wrong_role_gets_403(): void
    {
        $doctor = User::factory()->create([
            'role' => 'doctor',
        ]);

        $response = $this->actingAs($doctor, 'sanctum')
            ->getJson('/api/admin/dashboard');

        $response->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden: You do not have the required role to access this resource.',
            ]);
    }

    public function test_user_with_allowed_role_gets_200(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        $response = $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/dashboard');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Admin dashboard access granted',
            ]);
    }

    public function test_multi_role_parameter_allows_each_allowed_role(): void
    {
        $doctor = User::factory()->create(['role' => 'doctor']);
        $nurse = User::factory()->create(['role' => 'nurse']);
        $staff = User::factory()->create(['role' => 'staff']);

        // Doctor is allowed -> 200
        $this->actingAs($doctor, 'sanctum')
            ->getJson('/api/test/clinical')
            ->assertStatus(200)
            ->assertJson(['message' => 'Clinical access granted']);

        // Nurse is allowed -> 200
        $this->actingAs($nurse, 'sanctum')
            ->getJson('/api/test/clinical')
            ->assertStatus(200)
            ->assertJson(['message' => 'Clinical access granted']);

        // Staff is not allowed -> 403
        $this->actingAs($staff, 'sanctum')
            ->getJson('/api/test/clinical')
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden: You do not have the required role to access this resource.',
            ]);
    }
}

