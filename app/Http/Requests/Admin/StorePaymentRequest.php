<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StorePaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() ?? false;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'apartment_id' => ['required', 'integer', 'exists:apartments,id'],
            'contribution_id' => [
                'required',
                'integer',
                Rule::exists('contributions', 'id')->where(fn ($q) => $q->where('status', 'active')),
            ],
            'amount_paid' => ['required', 'numeric', 'min:0.01'],
            'date' => ['required', 'date'],
            'receipt' => ['nullable', 'image', 'mimes:jpeg,jpg,png,webp', 'max:5120'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'apartment_id.required' => 'Choisissez l\'appartement.',
            'contribution_id.required' => 'Choisissez la cotisation.',
            'contribution_id.exists' => 'Cette cotisation n\'est pas ouverte.',
            'amount_paid.required' => 'Indiquez le montant versé en dinars.',
            'amount_paid.min' => 'Le montant doit être supérieur à 0.',
            'date.required' => 'Indiquez la date du versement.',
            'receipt.image' => 'Le reçu doit être une photo (JPEG, PNG ou WebP).',
            'receipt.max' => 'La photo du reçu ne doit pas dépasser 5 Mo.',
        ];
    }
}
