<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreApartmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() ?? false;
    }

    protected function prepareForValidation(): void
    {
        if ($this->input('resident_id') === '' || $this->input('resident_id') === null) {
            $this->merge(['resident_id' => null]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $apartmentId = $this->route('apartment')?->id;

        return [
            'number' => [
                'required',
                'string',
                'max:50',
                Rule::unique('apartments', 'number')->ignore($apartmentId),
            ],
            'resident_id' => [
                'nullable',
                'integer',
                Rule::exists('users', 'id')->where(fn ($q) => $q->where('role', 'resident')),
            ],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'number.required' => 'Indiquez le numéro de l\'appartement.',
            'number.unique' => 'Ce numéro d\'appartement existe déjà.',
            'resident_id.exists' => 'Choisissez un résident valide.',
        ];
    }
}
