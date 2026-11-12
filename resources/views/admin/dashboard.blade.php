<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Accueil
        </h2>
    </x-slot>

    <div class="py-10">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-8">
            <x-flash-messages />

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="bg-white shadow-sm sm:rounded-lg p-6">
                    <p class="text-sm text-gray-500">Appartements</p>
                    <p class="mt-2 text-3xl font-semibold text-gray-900">{{ $apartmentCount }}</p>
                </div>
                <div class="bg-white shadow-sm sm:rounded-lg p-6">
                    <p class="text-sm text-gray-500">Cotisations ouvertes</p>
                    <p class="mt-2 text-3xl font-semibold text-gray-900">{{ $activeContributionCount }}</p>
                </div>
                <div class="bg-white shadow-sm sm:rounded-lg p-6">
                    <p class="text-sm text-gray-500">Paiements ce mois</p>
                    <p class="mt-2 text-3xl font-semibold text-gray-900">{{ $paymentCountThisMonth }}</p>
                </div>
            </div>

            <div class="bg-white shadow-sm sm:rounded-lg p-6">
                <h3 class="text-lg font-semibold text-gray-900">Que voulez-vous faire ?</h3>
                <p class="mt-1 text-gray-600">Choisissez une action ci-dessous.</p>

                <div class="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <a href="{{ route('apartments.create') }}" class="inline-flex justify-center items-center px-4 py-4 bg-gray-800 text-white text-base font-medium rounded-md hover:bg-gray-700">
                        Ajouter un appartement
                    </a>
                    <a href="{{ route('contributions.create') }}" class="inline-flex justify-center items-center px-4 py-4 bg-gray-800 text-white text-base font-medium rounded-md hover:bg-gray-700">
                        Créer une cotisation
                    </a>
                    <a href="{{ route('payments.create') }}" class="inline-flex justify-center items-center px-4 py-4 bg-gray-800 text-white text-base font-medium rounded-md hover:bg-gray-700">
                        Enregistrer un paiement
                    </a>
                    <a href="/docs/api" class="inline-flex justify-center items-center px-4 py-4 bg-indigo-700 text-white text-base font-medium rounded-md hover:bg-indigo-600">
                        Tester l'API (Swagger)
                    </a>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
