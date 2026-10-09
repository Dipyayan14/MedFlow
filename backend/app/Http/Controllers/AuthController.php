<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public const BIOMETRIC_TOKEN_EXPIRY_DAYS = 30;

    // Sign up a new staff member
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'role' => 'required|string|in:staff,doctor,nurse,duty_desk,admin',
            'phone_number' => 'nullable|string|max:20',
            'employee_id' => 'nullable|string|unique:users',
            'department' => 'nullable|string|max:255',
            'specialization' => 'nullable|string|max:255',
            'qualification' => 'nullable|string|max:255',
            'years_of_experience' => 'nullable|integer',
            'ward_assigned' => 'nullable|string|max:255',
            'shift_timing' => 'nullable|string|max:255',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'phone_number' => $request->phone_number,
            'employee_id' => $request->employee_id,
            'department' => $request->department,
            'specialization' => $request->specialization,
            'qualification' => $request->qualification,
            'years_of_experience' => $request->years_of_experience,
            'ward_assigned' => $request->ward_assigned,
            'shift_timing' => $request->shift_timing,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registered successfully',
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    // Log in an existing staff member
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['These credentials do not match our records.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token,
        ]);
    }

    // Log out (destroy current badge/token)
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Enable biometric authentication for the current user and issue a device pass token.
     */
    public function enableBiometric(Request $request): JsonResponse
    {
        $user = $request->user();
        $currentToken = $user->currentAccessToken();

        if ($currentToken && $currentToken->name === 'biometric_device') {
            return response()->json([
                'message' => 'A device pass cannot be used to create another device pass.',
            ], 403);
        }

        $user->tokens()->where('name', 'biometric_device')->delete();

        $token = $user->createToken(
            'biometric_device',
            ['biometric-login'],
            now()->addDays(self::BIOMETRIC_TOKEN_EXPIRY_DAYS)
        )->plainTextToken;

        return response()->json([
            'biometric_token' => $token,
        ]);
    }

    /**
     * Authenticate using a biometric device pass to issue a regular auth session token.
     */
    public function biometricLogin(Request $request): JsonResponse
    {
        $user = $request->user();
        $currentToken = $user->currentAccessToken();

        if (! $currentToken || $currentToken->name !== 'biometric_device' || ! $currentToken->can('biometric-login')) {
            return response()->json([
                'message' => 'Invalid device pass.',
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token,
        ]);
    }

    // Step 1: Send a password reset OTP
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json([
                'message' => 'No account found with that email address.',
            ], 404);
        }

        // Generate a 6-digit OTP
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Remove any old reset tokens for this email
        \DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        // Store the new OTP
        \DB::table('password_reset_tokens')->insert([
            'email' => $request->email,
            'token' => \Hash::make($otp),
            'created_at' => now(),
        ]);

        // Production must send the OTP by email instead
        if (app()->environment('local')) {
            \Log::info("Password reset OTP for {$request->email}: {$otp}");
        }

        return response()->json([
            'message' => 'A verification code has been sent to your email.',
        ]);
    }

    // Step 2: Verify the OTP
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'otp' => 'required|string',
        ]);

        $record = \DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (! $record || ! \Hash::check($request->otp, $record->token)) {
            return response()->json([
                'message' => 'Invalid or expired verification code.',
            ], 422);
        }

        // Check it's not older than 10 minutes
        if (now()->diffInMinutes($record->created_at) > 10) {
            return response()->json([
                'message' => 'This code has expired. Please request a new one.',
            ], 422);
        }

        return response()->json([
            'message' => 'Code verified successfully.',
        ]);
    }

    // Step 3: Actually reset the password
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'otp' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $record = \DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (! $record || ! \Hash::check($request->otp, $record->token)) {
            return response()->json([
                'message' => 'Invalid or expired verification code.',
            ], 422);
        }

        $user = User::where('email', $request->email)->first();
        $user->password = \Hash::make($request->password);
        $user->save();

        // Clean up the used token
        \DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        return response()->json([
            'message' => 'Password reset successfully.',
        ]);
    }
}
