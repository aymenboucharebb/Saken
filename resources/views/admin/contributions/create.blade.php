<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">Créer une cotisation</h2>
    </x-slot>

    <div class="py-10">
        <div class="max-w-2xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white shadow-sm sm:rounded-lg p-6">
                <form method="POST" action="{{ route('contributions.store') }}" class="space-y-6">
                    @csrf

                    <div>
                        <x-input-label for="title" value="Nom de la cotisation" />
                        <x-text-input id="title" name="title" type="text" class="mt-1 block w-full" :value="old('title')" required autofocus />
                        <p class="mt-1 text-sm text-gray-500">Exemple : Charges communes, Travaux ascenseur…</p>
                        <x-input-error class="mt-2" :messages="$errors->get('title')" />
                    </div>

                    <div>
                        <x-input-label for="amount_per_apartment" value="Montant par appartement (dinars)" />
                        <x-text-input id="amount_per_apartment" name="amount_per_apartment" type="number" step="0.01" min="1" class="mt-1 block w-full" :value="old('amount_per_apartment')" required />
                        <p class="mt-1 text-sm text-gray-500">Chaque appartement devra payer ce montant.</p>
                        <x-input-error class="mt-2" :messages="$errors->get('amount_per_apartment')" />
                    </div>

                    <div class="flex items-center gap-3">
                        <x-primary-button>Créer la cotisation</x-primary-button>
                        <a href="{{ route('contributions.index') }}" class="text-gray-600 hover:underline">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</x-app-layout>
