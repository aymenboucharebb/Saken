<?php

namespace App\Http\Resources;

use App\Support\Dzd;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\Contribution
 */
class ContributionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'amount_per_apartment' => (float) $this->amount_per_apartment,
            'amount_per_apartment_formatted' => Dzd::format($this->amount_per_apartment),
            'status' => $this->status,
            'status_label' => $this->status === 'active' ? 'Ouverte' : 'Fermée',
            'remaining_amount' => $this->when(isset($this->remaining_amount), fn () => (float) $this->remaining_amount),
            'remaining_amount_formatted' => $this->when(
                isset($this->remaining_amount),
                fn () => Dzd::format($this->remaining_amount),
            ),
            'is_fully_paid' => $this->when(isset($this->is_fully_paid), fn () => (bool) $this->is_fully_paid),
        ];
    }
}
