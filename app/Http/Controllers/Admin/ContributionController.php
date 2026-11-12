<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreContributionRequest;
use App\Models\Contribution;
use App\Services\ApartmentService;
use App\Services\ContributionService;
use App\Services\PaymentService;
use App\Support\Dzd;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;
use InvalidArgumentException;

class ContributionController extends Controller
{
    public function __construct(
        private readonly ContributionService $contributions,
        private readonly ApartmentService $apartments,
        private readonly PaymentService $payments,
    ) {}

    public function index(): View
    {
        return view('admin.contributions.index', [
            'contributions' => $this->contributions->listPaginated(),
        ]);
    }

    public function create(): View
    {
        return view('admin.contributions.create');
    }

    public function store(StoreContributionRequest $request): RedirectResponse
    {
        $this->contributions->create($request->validated());

        return redirect()
            ->route('contributions.index')
            ->with('success', 'Cotisation créée avec succès.');
    }

    public function show(Contribution $contribution): View
    {
        $rows = $this->apartments->listAll()->map(function ($apartment) use ($contribution) {
            $remaining = $this->payments->getRemainingAmount($apartment, $contribution);
            $due = (float) $contribution->amount_per_apartment;
            $paid = round($due - $remaining, 2);

            return [
                'apartment' => $apartment,
                'paid' => $paid,
                'paid_formatted' => Dzd::format($paid),
                'remaining' => $remaining,
                'remaining_formatted' => Dzd::format($remaining),
                'is_paid' => $remaining <= 0,
            ];
        });

        return view('admin.contributions.show', [
            'contribution' => $contribution,
            'rows' => $rows,
        ]);
    }

    public function update(StoreContributionRequest $request, Contribution $contribution): RedirectResponse
    {
        $this->contributions->update($contribution, $request->validated());

        return redirect()
            ->route('contributions.show', $contribution)
            ->with('success', 'Cotisation mise à jour.');
    }

    public function close(Contribution $contribution): RedirectResponse
    {
        try {
            $this->contributions->close($contribution);
        } catch (InvalidArgumentException $e) {
            return back()->with('error', $e->getMessage());
        }

        return redirect()
            ->route('contributions.show', $contribution)
            ->with('success', 'Cotisation fermée.');
    }
}
