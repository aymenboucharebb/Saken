<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">Enregistrer un paiement</h2>
    </x-slot>

    <div class="py-10">
        <div class="max-w-2xl mx-auto sm:px-6 lg:px-8">
            <x-flash-messages />

            <div class="bg-white shadow-sm sm:rounded-lg p-6">
                <form method="POST" action="{{ route('payments.store') }}" enctype="multipart/form-data" class="space-y-6">
                    @csrf

                    <div>
                        <x-input-label for="apartment_id" value="Appartement" />
                        <select id="apartment_id" name="apartment_id" class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm" required>
                            <option value="">— Choisir —</option>
                            @foreach ($apartments as $apartment)
                                <option value="{{ $apartment->id }}" @selected(old('apartment_id') == $apartment->id)>
                                    {{ $apartment->number }}
                                    @if ($apartment->resident)
                                        ({{ $apartment->resident->name }})
                                    @endif
                                </option>
                            @endforeach
                        </select>
                        <x-input-error class="mt-2" :messages="$errors->get('apartment_id')" />
                    </div>

                    <div>
                        <x-input-label for="contribution_id" value="Cotisation" />
                        <select id="contribution_id" name="contribution_id" class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm" required>
                            <option value="">— Choisir —</option>
                            @foreach ($contributions as $contribution)
                                <option value="{{ $contribution->id }}" @selected(old('contribution_id') == $contribution->id)>
                                    {{ $contribution->title }} — {{ $contribution->amount_per_apartment_formatted }}
                                </option>
                            @endforeach
                        </select>
                        <x-input-error class="mt-2" :messages="$errors->get('contribution_id')" />
                    </div>

                    <div>
                        <x-input-label for="amount_paid" value="Montant versé (dinars)" />
                        <x-text-input id="amount_paid" name="amount_paid" type="number" step="0.01" min="0.01" class="mt-1 block w-full" :value="old('amount_paid')" required />
                        <p class="mt-1 text-sm text-gray-500">Vous pouvez saisir un paiement partiel.</p>
                        <x-input-error class="mt-2" :messages="$errors->get('amount_paid')" />
                    </div>

                    <div>
                        <x-input-label for="date" value="Date du versement" />
                        <x-text-input id="date" name="date" type="date" class="mt-1 block w-full" :value="old('date', now()->toDateString())" required />
                        <x-input-error class="mt-2" :messages="$errors->get('date')" />
                    </div>

                    <div>
                        <x-input-label for="receipt" value="Photo du reçu (facultatif)" />
                        <input id="receipt" name="receipt" type="file" accept="image/jpeg,image/png,image/webp"
                               class="mt-1 block w-full text-sm text-gray-700" />
                        <p class="mt-1 text-sm text-gray-500">JPEG, PNG ou WebP — maximum 5 Mo.</p>
                        <x-input-error class="mt-2" :messages="$errors->get('receipt')" />
                    </div>

                    <div class="flex items-center gap-3">
                        <x-primary-button>Enregistrer le paiement</x-primary-button>
                        <a href="{{ route('payments.index') }}" class="text-gray-600 hover:underline">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</x-app-layout>
