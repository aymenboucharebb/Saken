<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\StorePaymentRequest;
use App\Http\Resources\PaymentResource;
use App\Models\Payment;
use App\Services\ApartmentService;
use App\Services\ContributionService;
use App\Services\PaymentService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class PaymentController extends Controller
{
    public function __construct(
        private readonly PaymentService $payments,
        private readonly ApartmentService $apartments,
        private readonly ContributionService $contributions,
    ) {}

    /**
     * Historique des paiements.
     *
     * Résident : uniquement les paiements de son appartement.
     * Admin : tous les paiements.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $user = $request->user();

        if ($user->isAdmin()) {
            return PaymentResource::collection(
                $this->payments->listPaginated(50),
            );
        }

        $apartment = $user->apartment;

        if (! $apartment) {
            throw new NotFoundHttpException('Aucun appartement n\'est associé à votre compte.');
        }

        return PaymentResource::collection(
            $this->payments->listForApartment($apartment->id, 50),
        );
    }

    /**
     * Détail d'un paiement (avec URL du reçu si présent).
     */
    public function show(Request $request, int $payment): PaymentResource
    {
        $model = $this->payments->find($payment);
        $this->assertCanView($request, $model);

        return PaymentResource::make($model);
    }

    /**
     * Télécharger le reçu privé (Bearer Sanctum, propriétaire ou admin).
     */
    public function receipt(Request $request, int $payment): StreamedResponse
    {
        $model = $this->payments->find($payment);
        $this->assertCanView($request, $model);

        return $this->payments->streamReceipt($model);
    }

    /**
     * Déclarer un paiement (montant en DZD + photo de reçu optionnelle).
     *
     * Résident : paie pour son propre appartement.
     * Admin : peut préciser apartment_id.
     */
    public function store(StorePaymentRequest $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validated();

        try {
            if ($user->isAdmin()) {
                if (empty($data['apartment_id'])) {
                    return response()->json([
                        'message' => 'Indiquez l\'appartement (apartment_id).',
                    ], 422);
                }
                $apartment = $this->apartments->find((int) $data['apartment_id']);
            } else {
                $apartment = $user->apartment;

                if (! $apartment) {
                    throw new NotFoundHttpException('Aucun appartement n\'est associé à votre compte.');
                }
            }

            $contribution = $this->contributions->find((int) $data['contribution_id']);
            $date = isset($data['date']) ? Carbon::parse($data['date']) : now();

            $payment = $this->payments->recordPayment(
                $apartment,
                $contribution,
                (float) $data['amount_paid'],
                $date,
                $request->file('receipt'),
            );

            $payment->load(['apartment', 'contribution']);

            return response()->json([
                'message' => 'Paiement enregistré avec succès.',
                'data' => PaymentResource::make($payment),
            ], 201);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    private function assertCanView(Request $request, Payment $payment): void
    {
        $user = $request->user();

        if ($user->isAdmin()) {
            return;
        }

        if ($user->apartment?->id !== $payment->apartment_id) {
            throw new AccessDeniedHttpException('Vous ne pouvez pas voir ce paiement.');
        }
    }
}
