<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StorePaymentRequest;
use App\Services\ApartmentService;
use App\Services\ContributionService;
use App\Services\PaymentService;
use Carbon\Carbon;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PaymentController extends Controller
{
    public function __construct(
        private readonly PaymentService $payments,
        private readonly ApartmentService $apartments,
        private readonly ContributionService $contributions,
    ) {}

    public function index(): View
    {
        return view('admin.payments.index', [
            'payments' => $this->payments->listPaginated(),
        ]);
    }

    public function create(): View
    {
        return view('admin.payments.create', [
            'apartments' => $this->apartments->listAll(),
            'contributions' => $this->contributions->listActive(),
        ]);
    }

    public function store(StorePaymentRequest $request): RedirectResponse
    {
        $data = $request->validated();

        try {
            $apartment = $this->apartments->find((int) $data['apartment_id']);
            $contribution = $this->contributions->find((int) $data['contribution_id']);

            $this->payments->recordPayment(
                $apartment,
                $contribution,
                (float) $data['amount_paid'],
                Carbon::parse($data['date']),
                $request->file('receipt'),
            );
        } catch (InvalidArgumentException $e) {
            return back()
                ->withInput()
                ->with('error', $e->getMessage());
        }

        return redirect()
            ->route('payments.index')
            ->with('success', 'Paiement enregistré avec succès.');
    }

    public function show(int $payment): View
    {
        return view('admin.payments.show', [
            'payment' => $this->payments->find($payment),
        ]);
    }

    /**
     * Stream privé du reçu (session admin).
     */
    public function receipt(int $payment): StreamedResponse
    {
        $model = $this->payments->find($payment);

        return $this->payments->streamReceipt($model);
    }
}
