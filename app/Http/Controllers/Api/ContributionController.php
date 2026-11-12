<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ContributionResource;
use App\Models\Contribution;
use App\Services\ApartmentService;
use App\Services\ContributionService;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class ContributionController extends Controller
{
    public function __construct(
        private readonly ContributionService $contributions,
        private readonly PaymentService $payments,
        private readonly ApartmentService $apartments,
    ) {}

    /**
     * Liste des cotisations.
     *
     * Pour un résident : inclut le reste à payer de son appartement.
     * Pour un admin : liste complète sans reste individuel.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $user = $request->user();
        $items = $this->contributions->listPaginated(50);

        if (! $user->isAdmin()) {
            $apartment = $user->apartment;

            if ($apartment) {
                $items->getCollection()->transform(function (Contribution $contribution) use ($apartment) {
                    $remaining = $this->payments->getRemainingAmount($apartment, $contribution);
                    $contribution->remaining_amount = $remaining;
                    $contribution->is_fully_paid = $remaining <= 0;

                    return $contribution;
                });
            }
        }

        return ContributionResource::collection($items);
    }

    /**
     * Détail d'une cotisation.
     *
     * Résident : reste à payer pour son appartement.
     * Admin : tableau de soldes par appartement.
     */
    public function show(Request $request, int $contribution): ContributionResource|\Illuminate\Http\JsonResponse
    {
        $contributionModel = $this->contributions->find($contribution);
        $user = $request->user();

        if ($user->isAdmin()) {
            $balances = $this->apartments->listAll()->map(function ($apartment) use ($contributionModel) {
                $remaining = $this->payments->getRemainingAmount($apartment, $contributionModel);
                $due = (float) $contributionModel->amount_per_apartment;

                return [
                    'apartment_id' => $apartment->id,
                    'apartment_number' => $apartment->number,
                    'resident_name' => $apartment->resident?->name,
                    'amount_due' => $due,
                    'amount_paid' => round($due - $remaining, 2),
                    'remaining_amount' => $remaining,
                    'is_fully_paid' => $remaining <= 0,
                ];
            });

            return response()->json([
                'data' => ContributionResource::make($contributionModel),
                'balances' => $balances,
            ]);
        }

        $apartment = $user->apartment;

        if (! $apartment) {
            throw new NotFoundHttpException('Aucun appartement n\'est associé à votre compte.');
        }

        $remaining = $this->payments->getRemainingAmount($apartment, $contributionModel);
        $contributionModel->remaining_amount = $remaining;
        $contributionModel->is_fully_paid = $remaining <= 0;

        return ContributionResource::make($contributionModel);
    }
}
