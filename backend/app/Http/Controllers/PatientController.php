<?php

namespace App\Http\Controllers;

use App\Http\Requests\StorePatientRequest;
use App\Http\Requests\UpdatePatientRequest;
use App\Models\Patient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PatientController extends Controller
{
    /**
     * Display a listing of patients with search and pagination.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Patient::query()->with('creator:id,name,role');

        if ($search = $request->query('search')) {
            $search = trim($search);
            $query->where(function ($q) use ($search) {
                $driver = DB::connection()->getDriverName();
                $concatExpression = $driver === 'sqlite'
                    ? "(first_name || ' ' || last_name)"
                    : "CONCAT(first_name, ' ', last_name)";

                $q->where('first_name', 'like', "%{$search}%")
                    ->orWhere('last_name', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%")
                    ->orWhere('mrn', 'like', "%{$search}%")
                    ->orWhereRaw("{$concatExpression} LIKE ?", ["%{$search}%"]);
            });
        }

        $perPage = max(1, min((int) $request->query('per_page', 15), 100));
        $patients = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json($patients);
    }

    /**
     * Store a newly created patient in storage.
     */
    public function store(StorePatientRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $validated['created_by'] = $request->user()->id;

        $patient = Patient::create($validated);

        return response()->json([
            'message' => 'Patient registered successfully',
            'patient' => $patient->load('creator:id,name,role'),
        ], 201);
    }

    /**
     * Display the specified patient.
     */
    public function show(Patient $patient): JsonResponse
    {
        return response()->json([
            'patient' => $patient->load('creator:id,name,role'),
        ]);
    }

    /**
     * Update the specified patient in storage.
     */
    public function update(UpdatePatientRequest $request, Patient $patient): JsonResponse
    {
        $patient->update($request->validated());

        return response()->json([
            'message' => 'Patient updated successfully',
            'patient' => $patient->load('creator:id,name,role'),
        ]);
    }

    /**
     * Remove the specified patient from storage (soft delete).
     */
    public function destroy(Patient $patient): JsonResponse
    {
        $patient->delete();

        return response()->json([
            'message' => 'Patient deleted successfully',
        ]);
    }
}

