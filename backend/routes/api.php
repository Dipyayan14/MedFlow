<?php

use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\OpdQueueController;
use App\Http\Controllers\PatientController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:5,1');
Route::post('/verify-otp', [AuthController::class, 'verifyOtp'])->middleware('throttle:5,1');
Route::post('/reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:5,1');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/biometric/enable', [AuthController::class, 'enableBiometric']);
    Route::post('/biometric/login', [AuthController::class, 'biometricLogin']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Doctors listing for appointment booking
    Route::get('/doctors', function () {
        return response()->json([
            'data' => \App\Models\User::where('role', 'doctor')
                ->get(['id', 'name', 'department', 'specialization']),
        ]);
    })->middleware('role:doctor,nurse,duty_desk,admin');

    // Patients module
    // View: doctor, nurse, duty_desk, admin
    Route::get('/patients', [PatientController::class, 'index'])
        ->middleware('role:doctor,nurse,duty_desk,admin');
    Route::get('/patients/{patient}', [PatientController::class, 'show'])
        ->middleware('role:doctor,nurse,duty_desk,admin');

    // Create & Update: duty_desk, admin
    Route::post('/patients', [PatientController::class, 'store'])
        ->middleware('role:duty_desk,admin');
    Route::match(['put', 'patch'], '/patients/{patient}', [PatientController::class, 'update'])
        ->middleware('role:duty_desk,admin');

    // Delete: admin only
    Route::delete('/patients/{patient}', [PatientController::class, 'destroy'])
        ->middleware('role:admin');

    // Appointments module
    // View: doctor, nurse, duty_desk, admin
    Route::get('/appointments', [AppointmentController::class, 'index'])
        ->middleware('role:doctor,nurse,duty_desk,admin');
    Route::get('/appointments/{appointment}', [AppointmentController::class, 'show'])
        ->middleware('role:doctor,nurse,duty_desk,admin');

    // Create: duty_desk, admin
    Route::post('/appointments', [AppointmentController::class, 'store'])
        ->middleware('role:duty_desk,admin');

    // Update / Reschedule / Status / Notes: doctor, nurse, duty_desk, admin (granular checks in UpdateAppointmentRequest)
    Route::match(['put', 'patch'], '/appointments/{appointment}', [AppointmentController::class, 'update'])
        ->middleware('role:doctor,nurse,duty_desk,admin');

    // Delete: admin only
    Route::delete('/appointments/{appointment}', [AppointmentController::class, 'destroy'])
        ->middleware('role:admin');

    // OPD Queue module
    // 1. GET /api/opd/queue?date=YYYY-MM-DD&doctor_id=...
    Route::get('/opd/queue', [OpdQueueController::class, 'queue'])
        ->middleware('role:doctor,nurse,duty_desk,admin');

    // 2. Check-in patient (issues token number). Role: duty_desk, nurse, admin
    Route::post('/opd/check-in', [OpdQueueController::class, 'checkIn'])
        ->middleware('role:duty_desk,nurse,admin');
    Route::post('/appointments/{appointment}/check-in', [OpdQueueController::class, 'checkIn'])
        ->middleware('role:duty_desk,nurse,admin');

    // 3. Call-next and Complete: Role: assigned doctor only
    Route::post('/opd/call-next', [OpdQueueController::class, 'callNext'])
        ->middleware('role:doctor');
    Route::post('/appointments/{appointment}/call-next', [OpdQueueController::class, 'callNext'])
        ->middleware('role:doctor');

    Route::post('/opd/complete', [OpdQueueController::class, 'complete'])
        ->middleware('role:doctor');
    Route::post('/appointments/{appointment}/complete', [OpdQueueController::class, 'complete'])
        ->middleware('role:doctor');

    // Admin-only routes
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', function () {
            return response()->json([
                'message' => 'Admin dashboard access granted',
            ]);
        });
    });
});
