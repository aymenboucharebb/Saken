<?php

namespace App\Models;

use App\Support\Dzd;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

#[Fillable(['apartment_id', 'contribution_id', 'amount_paid', 'date', 'receipt_path'])]
class Payment extends Model
{
    /** @use HasFactory<\Database\Factories\PaymentFactory> */
    use HasFactory;

    /**
     * Bootstrap the model.
     */
    protected static function booted(): void
    {
        static::deleting(function (Payment $payment): void {
            if (! $payment->receipt_path) {
                return;
            }

            Storage::disk('local')->delete($payment->receipt_path);
            Storage::disk('public')->delete($payment->receipt_path);
        });
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'amount_paid' => 'decimal:2',
            'date' => 'date',
        ];
    }

    /**
     * Amount paid formatted in Algerian dinars.
     */
    protected function amountPaidFormatted(): Attribute
    {
        return Attribute::get(
            fn (): string => Dzd::format($this->amount_paid),
        );
    }

    /**
     * Authenticated CMS URL of the receipt photo, if any.
     */
    protected function receiptUrl(): Attribute
    {
        return Attribute::get(function (): ?string {
            if (! $this->receipt_path) {
                return null;
            }

            return route('payments.receipt', $this);
        });
    }

    /**
     * Authenticated API URL of the receipt photo, if any.
     */
    protected function receiptApiUrl(): Attribute
    {
        return Attribute::get(function (): ?string {
            if (! $this->receipt_path) {
                return null;
            }

            return url('/api/payments/'.$this->id.'/receipt');
        });
    }

    /**
     * Apartment that made this payment.
     */
    public function apartment(): BelongsTo
    {
        return $this->belongsTo(Apartment::class);
    }

    /**
     * Contribution this payment belongs to.
     */
    public function contribution(): BelongsTo
    {
        return $this->belongsTo(Contribution::class);
    }
}
