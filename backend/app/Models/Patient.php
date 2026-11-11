<?php

namespace App\Models;

use Database\Factories\PatientFactory;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Patient extends Model
{
    /** @use HasFactory<PatientFactory> */
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'mrn',
        'first_name',
        'last_name',
        'date_of_birth',
        'gender',
        'phone',
        'address',
        'emergency_contact_name',
        'emergency_contact_phone',
        'blood_group',
        'created_by',
    ];

    protected $appends = [
        'name',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date:Y-m-d',
        ];
    }

    /**
     * Full name accessor.
     */
    protected function name(): Attribute
    {
        return Attribute::make(
            get: fn () => trim("{$this->first_name} {$this->last_name}"),
        );
    }

    /**
     * Creator user relationship.
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Auto-generate unique MRN if none provided.
     */
    protected static function booted(): void
    {
        static::creating(function (Patient $patient) {
            if (empty($patient->mrn)) {
                $patient->mrn = static::generateUniqueMrn();
            }
        });
    }

    /**
     * Generate unique MRN in format MRN-YYYY-XXXXX.
     */
    public static function generateUniqueMrn(): string
    {
        do {
            $year = date('Y');
            $random = strtoupper(Str::random(5));
            $mrn = "MRN-{$year}-{$random}";
        } while (static::where('mrn', $mrn)->exists());

        return $mrn;
    }
}

