<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">Modifier l'appartement {{ $apartment->number }}</h2>
    </x-slot>

    <div class="py-10">
        <div class="max-w-2xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white shadow-sm sm:rounded-lg p-6">
                <form method="POST" action="{{ route('apartments.update', $apartment) }}" class="space-y-6">
                    @csrf
                    @method('PUT')
                    @include('admin.apartments._form')

                    <div class="flex items-center gap-3">
                        <x-primary-button>Enregistrer les modifications</x-primary-button>
                        <a href="{{ route('apartments.index') }}" class="text-gray-600 hover:underline">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</x-app-layout>
