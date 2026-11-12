<x-app-layout>
    <x-slot name="header">
        <div class="flex items-center justify-between gap-4">
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">Cotisations</h2>
            <a href="{{ route('contributions.create') }}" class="inline-flex items-center px-4 py-2 bg-gray-800 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-gray-700">
                Créer une cotisation
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
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Titre</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Montant / appartement</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">État</th>
                            <th class="px-6 py-3 text-right font-medium text-gray-600">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        @forelse ($contributions as $contribution)
                            <tr>
                                <td class="px-6 py-4 font-medium text-gray-900">{{ $contribution->title }}</td>
                                <td class="px-6 py-4 text-gray-700">{{ $contribution->amount_per_apartment_formatted }}</td>
                                <td class="px-6 py-4">
                                    @if ($contribution->status === 'active')
                                        <span class="inline-flex px-2 py-1 text-sm rounded-md bg-green-100 text-green-800">Ouverte</span>
                                    @else
                                        <span class="inline-flex px-2 py-1 text-sm rounded-md bg-gray-100 text-gray-700">Fermée</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <a href="{{ route('contributions.show', $contribution) }}" class="text-indigo-600 hover:underline">Voir le détail</a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="px-6 py-8 text-center text-gray-500">
                                    Aucune cotisation. Créez-en une pour commencer.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <div class="mt-4">{{ $contributions->links() }}</div>
        </div>
    </div>
</x-app-layout>
