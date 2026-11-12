<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">Détail du paiement</h2>
    </x-slot>

    <div class="py-10">
        <div class="max-w-3xl mx-auto sm:px-6 lg:px-8 space-y-6">
            <div class="bg-white shadow-sm sm:rounded-lg p-6 space-y-3 text-base">
                <p><span class="text-gray-500">Date :</span> <strong>{{ $payment->date->format('d/m/Y') }}</strong></p>
                <p><span class="text-gray-500">Appartement :</span> <strong>{{ $payment->apartment->number }}</strong></p>
                <p><span class="text-gray-500">Résident :</span> <strong>{{ $payment->apartment->resident?->name ?? '—' }}</strong></p>
                <p><span class="text-gray-500">Cotisation :</span> <strong>{{ $payment->contribution->title }}</strong></p>
                <p><span class="text-gray-500">Montant versé :</span> <strong>{{ $payment->amount_paid_formatted }}</strong></p>
            </div>

            <div class="bg-white shadow-sm sm:rounded-lg p-6">
                <h3 class="font-semibold text-gray-900 mb-4">Photo du reçu</h3>
                @if ($payment->receipt_url)
                    <img src="{{ $payment->receipt_url }}" alt="Reçu de paiement" class="max-w-full rounded-md border border-gray-200" />
                @else
                    <p class="text-gray-500">Aucune photo de reçu n'a été jointe.</p>
                @endif
            </div>

            <a href="{{ route('payments.index') }}" class="text-gray-600 hover:underline">← Retour aux paiements</a>
        </div>
    </div>
</x-app-layout>
