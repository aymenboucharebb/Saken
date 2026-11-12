<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StorePaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'contribution_id' => [
                'required',
                'integer',
                Rule::exists('contributions', 'id')->where(fn ($q) => $q->where('status', 'active')),
            ],
            'apartment_id' => ['nullable', 'integer', 'exists:apartments,id'],
            'amount_paid' => ['required', 'numeric', 'min:0.01'],
            'date' => ['nullable', 'date'],
            'receipt' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:5120'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'contribution_id.required' => 'Choisissez la cotisation.',
            'contribution_id.exists' => 'Cette cotisation n\'est pas ouverte.',
            'amount_paid.required' => 'Indiquez le montant versé en dinars.',
            'receipt.image' => 'Le reçu doit être une photo (JPEG, PNG ou WebP).',
            'receipt.max' => 'La photo du reçu ne doit pas dépasser 5 Mo.',
        ];
    }
}
