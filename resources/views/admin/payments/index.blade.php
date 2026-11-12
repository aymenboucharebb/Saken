<x-app-layout>
    <x-slot name="header">
        <div class="flex items-center justify-between gap-4">
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">Paiements</h2>
            <a href="{{ route('payments.create') }}" class="inline-flex items-center px-4 py-2 bg-gray-800 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-gray-700">
                Enregistrer un paiement
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
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Date</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Appartement</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Cotisation</th>
                            <th class="px-6 py-3 text-left font-medium text-gray-600">Montant</th>
                            <th class="px-6 py-3 text-right font-medium text-gray-600">Reçu</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        @forelse ($payments as $payment)
                            <tr>
                                <td class="px-6 py-4 text-gray-700">{{ $payment->date->format('d/m/Y') }}</td>
                                <td class="px-6 py-4 font-medium text-gray-900">{{ $payment->apartment->number }}</td>
                                <td class="px-6 py-4 text-gray-700">{{ $payment->contribution->title }}</td>
                                <td class="px-6 py-4 text-gray-700">{{ $payment->amount_paid_formatted }}</td>
                                <td class="px-6 py-4 text-right">
                                    <a href="{{ route('payments.show', $payment) }}" class="text-indigo-600 hover:underline">
                                        {{ $payment->receipt_path ? 'Voir le reçu' : 'Détail' }}
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-6 py-8 text-center text-gray-500">
                                    Aucun paiement enregistré pour le moment.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <div class="mt-4">{{ $payments->links() }}</div>
        </div>
    </div>
</x-app-layout>
