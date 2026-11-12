<?php

namespace App\Models;

use App\Support\Dzd;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['title', 'amount_per_apartment', 'status'])]
class Contribution extends Model
{
    /** @use HasFactory<\Database\Factories\ContributionFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'amount_per_apartment' => 'decimal:2',
        ];
    }

    /**
     * Amount per apartment formatted in Algerian dinars.
     */
    protected function amountPerApartmentFormatted(): Attribute
    {
        return Attribute::get(
            fn (): string => Dzd::format($this->amount_per_apartment),
        );
    }

    /**
     * Payments recorded against this contribution.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }
}

