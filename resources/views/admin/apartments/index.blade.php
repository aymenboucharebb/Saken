<x-app-layout>
    <x-slot name="header">
        <div class="flex items-center justify-between gap-4">
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">Appartements</h2>
            <a href="{{ route('apartments.create') }}">
                <x-primary-button type="button">Ajouter un appartement</x-primary-button>
            </a>
        </div>
    </x-slot>

    <div class="py-10">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <x-flash-messages />

            <div class="bg-white shadow-sm sm:rounded-lg overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200 text-base">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Numéro</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Résident</th>
                            <th class="px-6 py-3 text-right font-medium text-gray-600">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        @forelse ($apartments as $apartment)
                            <tr>
                                <td class="px-6 py-4 font-medium text-gray-900">{{ $apartment->number }}</td>
                                <td class="px-6 py-4 text-gray-700">
                                    {{ $apartment->resident?->name ?? 'Aucun résident' }}
                                </td>
                                <td class="px-6 py-4 text-right space-x-3">
                                    <a href="{{ route('apartments.edit', $apartment) }}" class="text-indigo-600 hover:underline">Modifier</a>
                                    <form action="{{ route('apartments.destroy', $apartment) }}" method="POST" class="inline"
                                          onsubmit="return confirm('Supprimer cet appartement ?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="text-red-600 hover:underline">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="3" class="px-6 py-8 text-center text-gray-500">
                                    Aucun appartement pour le moment. Cliquez sur « Ajouter un appartement ».
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <div class="mt-4">{{ $apartments->links() }}</div>
        </div>
    </div>
</x-app-layout>
