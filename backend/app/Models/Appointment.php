<?php

namespace App\Models;

use Carbon\Carbon;
use Database\Factories\AppointmentFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class Appointment extends Model
{
    /** @use HasFactory<AppointmentFactory> */
    use HasFactory, SoftDeletes;

    public const STATUS_SCHEDULED = 'scheduled';
    public const STATUS_CHECKED_IN = 'checked_in';
    public const STATUS_IN_CONSULTATION = 'in_consultation';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_NO_SHOW = 'no_show';

    public const VALID_STATUSES = [
        self::STATUS_SCHEDULED,
        self::STATUS_CHECKED_IN,
        self::STATUS_IN_CONSULTATION,
        self::STATUS_COMPLETED,
        self::STATUS_CANCELLED,
        self::STATUS_NO_SHOW,
    ];

    protected $fillable = [
        'patient_id',
        'doctor_id',
        'scheduled_at',
        'status',
        'token_number',
        'reason',
        'notes',
        'created_by',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'scheduled_at' => 'datetime',
            'token_number' => 'integer',
        ];
    }

    /**
     * The patient for this appointment.
     */
    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class, 'patient_id');
    }

    /**
     * The attending doctor.
     */
    public function doctor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'doctor_id');
    }

    /**
     * The user who booked/created this appointment.
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Check in an appointment and issue a server-generated token number.
     * Enforces date must be today in Asia/Kolkata timezone.
     * Enforces appointment cannot be cancelled or completed.
     *
     * @throws ValidationException
     */
    public function checkIn(): self
    {
        $timezone = 'Asia/Kolkata';
        $today = Carbon::now($timezone)->toDateString();
        $appointmentDate = Carbon::parse($this->scheduled_at)->setTimezone($timezone)->toDateString();

        if ($appointmentDate !== $today) {
            throw ValidationException::withMessages([
                'appointment' => 'Cannot check in an appointment that is not scheduled for today (Asia/Kolkata).',
            ]);
        }

        if ($this->status === self::STATUS_CANCELLED) {
            throw ValidationException::withMessages([
                'status' => 'Cannot check in a cancelled appointment.',
            ]);
        }

        if ($this->status === self::STATUS_COMPLETED) {
            throw ValidationException::withMessages([
                'status' => 'Cannot check in an already completed appointment.',
            ]);
        }

        return DB::transaction(function () {
            if (! $this->token_number) {
                $date = $this->scheduled_at->toDateString();
                $maxToken = self::where('doctor_id', $this->doctor_id)
                    ->whereDate('scheduled_at', $date)
                    ->lockForUpdate()
                    ->max('token_number') ?? 0;

                $this->token_number = $maxToken + 1;
            }

            $this->status = self::STATUS_CHECKED_IN;
            $this->save();

            return $this;
        });
    }

    /**
     * Hide sensitive notes unless user is admin or the assigned doctor.
     */
    public function sanitizeForUser(?User $user): self
    {
        if (! $user || ($user->role !== 'admin' && ! ($user->role === 'doctor' && $this->doctor_id === $user->id))) {
            $this->makeHidden('notes');
        }

        return $this;
    }
}

