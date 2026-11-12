<?php

namespace App\Http\Resources;

use App\Support\Dzd;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\Payment
 */
class PaymentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'apartment_id' => $this->apartment_id,
            'contribution_id' => $this->contribution_id,
            'amount_paid' => (float) $this->amount_paid,
            'amount_paid_formatted' => Dzd::format($this->amount_paid),
            'date' => $this->date?->format('Y-m-d'),
            'receipt_url' => $this->receipt_api_url,
            'apartment' => ApartmentResource::make($this->whenLoaded('apartment')),
            'contribution' => ContributionResource::make($this->whenLoaded('contribution')),
        ];
    }
}
