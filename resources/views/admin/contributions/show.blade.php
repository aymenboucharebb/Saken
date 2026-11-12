<x-app-layout>
    <x-slot name="header">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
                <h2 class="font-semibold text-xl text-gray-800 leading-tight">{{ $contribution->title }}</h2>
                <p class="mt-1 text-gray-600">
                    Montant par appartement : <strong>{{ $contribution->amount_per_apartment_formatted }}</strong>
                    —
                    @if ($contribution->status === 'active')
                        <span class="text-green-700">Ouverte</span>
                    @else
                        <span class="text-gray-600">Fermée</span>
                    @endif
                </p>
            </div>

            @if ($contribution->status === 'active')
                <form method="POST" action="{{ route('contributions.close', $contribution) }}"
                      onsubmit="return confirm('Fermer cette cotisation ? On ne pourra plus y ajouter de paiements.');">
                    @csrf
                    <x-danger-button>Fermer la cotisation</x-danger-button>
                </form>
            @endif
        </div>
    </x-slot>

    <div class="py-10">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-4">
            <x-flash-messages />

            <div class="bg-white shadow-sm sm:rounded-lg overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200 text-base">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Appartement</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Résident</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Déjà payé</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Reste à payer</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Situation</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        @forelse ($rows as $row)
                            <tr>
                                <td class="px-6 py-4 font-medium text-gray-900">{{ $row['apartment']->number }}</td>
                                <td class="px-6 py-4 text-gray-700">{{ $row['apartment']->resident?->name ?? '—' }}</td>
                                <td class="px-6 py-4 text-gray-700">{{ $row['paid_formatted'] }}</td>
                                <td class="px-6 py-4 text-gray-700">{{ $row['remaining_formatted'] }}</td>
                                <td class="px-6 py-4">
                                    @if ($row['is_paid'])
                                        <span class="inline-flex px-2 py-1 text-sm rounded-md bg-green-100 text-green-800">Payé</span>
                                    @else
                                        <span class="inline-flex px-2 py-1 text-sm rounded-md bg-orange-100 text-orange-800">En cours</span>
                                    @endif
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-6 py-8 text-center text-gray-500">
                                    Aucun appartement. Ajoutez d'abord des appartements.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <a href="{{ route('contributions.index') }}" class="text-gray-600 hover:underline">← Retour aux cotisations</a>
        </div>
    </div>
</x-app-layout>
