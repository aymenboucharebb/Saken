<?php

namespace App\Services;

use App\Models\Apartment;
use App\Models\Contribution;
use App\Models\Payment;
use App\Repositories\PaymentRepository;
use Carbon\Carbon;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class PaymentService
{
    public const RECEIPT_DISK = 'local';

    private const RECEIPT_DIRECTORY = 'receipts/payments';

    private const RECEIPT_MAX_KILOBYTES = 5120;

    /** @var list<string> */
    private const RECEIPT_MIME_TYPES = [
        'image/jpeg',
        'image/png',
        'image/webp',
    ];

    public function __construct(
        private readonly PaymentRepository $payments,
    ) {}

    /**
     * @return LengthAwarePaginator<int, Payment>
     */
    public function listPaginated(int $perPage = 15): LengthAwarePaginator
    {
        return $this->payments->paginateLatest($perPage);
    }

    public function find(int $id): Payment
    {
        return $this->payments->find($id);
    }

    public function countThisMonth(): int
    {
        return $this->payments->countThisMonth();
    }

    /**
     * @return LengthAwarePaginator<int, Payment>
     */
    public function listForApartment(int $apartmentId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->payments->paginateForApartment($apartmentId, $perPage);
    }

    /**
     * Remaining amount due for an apartment on a contribution (DZD).
     *
     * Formula: Contribution.amount_per_apartment - SUM(Payment.amount_paid).
     */
    public function getRemainingAmount(Apartment $apartment, Contribution $contribution): float
    {
        $due = (float) $contribution->amount_per_apartment;
        $paid = $this->payments->sumPaidForApartment(
            $apartment->id,
            $contribution->id,
        );

        return max(0, round($due - $paid, 2));
    }

    /**
     * Record a (possibly partial) payment for an apartment/contribution.
     *
     * Optionally stores a receipt photo on the private local disk.
     *
     * @throws InvalidArgumentException
     */
    public function recordPayment(
        Apartment $apartment,
        Contribution $contribution,
        float $amount,
        ?Carbon $date = null,
        ?UploadedFile $receipt = null,
    ): Payment {
        if ($contribution->status !== 'active') {
            throw new InvalidArgumentException(
                'Impossible d\'enregistrer un paiement sur une cotisation inactive.',
            );
        }

        $amount = round($amount, 2);

        if ($amount <= 0) {
            throw new InvalidArgumentException(
                'Le montant du paiement doit être supérieur à 0 DZD.',
            );
        }

        $remaining = $this->getRemainingAmount($apartment, $contribution);

        if ($amount > $remaining) {
            throw new InvalidArgumentException(
                sprintf(
                    'Le montant (%.2f DZD) dépasse le reste à payer (%.2f DZD).',
                    $amount,
                    $remaining,
                ),
            );
        }

        $receiptPath = null;

        if ($receipt !== null) {
            $receiptPath = $this->storeReceipt($receipt);
        }

        return $this->payments->create([
            'apartment_id' => $apartment->id,
            'contribution_id' => $contribution->id,
            'amount_paid' => $amount,
            'date' => ($date ?? now())->toDateString(),
            'receipt_path' => $receiptPath,
        ]);
    }

    /**
     * Whether the apartment has fully paid the contribution (remaining <= 0).
     */
    public function isFullyPaid(Apartment $apartment, Contribution $contribution): bool
    {
        return $this->getRemainingAmount($apartment, $contribution) <= 0;
    }

    /**
     * Stream a private receipt for an authorized viewer.
     */
    public function streamReceipt(Payment $payment): StreamedResponse
    {
        $path = $payment->receipt_path;

        if (! $path || ! Storage::disk(self::RECEIPT_DISK)->exists($path)) {
            // Fallback for legacy files stored on the public disk before hardening.
            if ($path && Storage::disk('public')->exists($path)) {
                return Storage::disk('public')->response($path);
            }

            throw new NotFoundHttpException('Aucun reçu n\'est disponible pour ce paiement.');
        }

        return Storage::disk(self::RECEIPT_DISK)->response($path);
    }

    /**
     * Store a receipt image on the private local disk.
     *
     * @throws InvalidArgumentException
     */
    private function storeReceipt(UploadedFile $receipt): string
    {
        if (! $receipt->isValid()) {
            throw new InvalidArgumentException('Le fichier du reçu est invalide.');
        }

        if ($receipt->getSize() > self::RECEIPT_MAX_KILOBYTES * 1024) {
            throw new InvalidArgumentException(
                'Le reçu ne doit pas dépasser 5 Mo.',
            );
        }

        $mime = $receipt->getMimeType();

        if (! in_array($mime, self::RECEIPT_MIME_TYPES, true)) {
            throw new InvalidArgumentException(
                'Le reçu doit être une image JPEG, PNG ou WebP.',
            );
        }

        $path = $receipt->store(self::RECEIPT_DIRECTORY, self::RECEIPT_DISK);

        if ($path === false) {
            throw new InvalidArgumentException(
                'Échec de l\'enregistrement du reçu.',
            );
        }

        return $path;
    }
}
