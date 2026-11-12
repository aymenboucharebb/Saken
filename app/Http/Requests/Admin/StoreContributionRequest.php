<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreContributionRequest extends FormRequest
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
            'title' => ['required', 'string', 'max:255'],
            'amount_per_apartment' => ['required', 'numeric', 'min:1'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'title.required' => 'Donnez un nom à la cotisation (ex. Charges communes).',
            'amount_per_apartment.required' => 'Indiquez le montant en dinars pour chaque appartement.',
            'amount_per_apartment.min' => 'Le montant doit être d\'au moins 1 DZD.',
        ];
    }
}
