<?php

namespace App\Repositories;

use App\Models\Payment;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class PaymentRepository
{
    /**
     * Sum of all amounts paid by an apartment for a given contribution.
     */
    public function sumPaidForApartment(int $apartmentId, int $contributionId): float
    {
        return (float) Payment::query()
            ->where('apartment_id', $apartmentId)
            ->where('contribution_id', $contributionId)
            ->sum('amount_paid');
    }

    /**
     * List all payments for an apartment against a contribution.
     *
     * @return Collection<int, Payment>
     */
    public function findByApartmentAndContribution(int $apartmentId, int $contributionId): Collection
    {
        return Payment::query()
            ->where('apartment_id', $apartmentId)
            ->where('contribution_id', $contributionId)
            ->orderBy('date')
            ->orderBy('id')
            ->get();
    }

    /**
     * @return LengthAwarePaginator<int, Payment>
     */
    public function paginateLatest(int $perPage = 15): LengthAwarePaginator
    {
        return Payment::query()
            ->with(['apartment', 'contribution'])
            ->orderByDesc('date')
            ->orderByDesc('id')
            ->paginate($perPage);
    }

    public function find(int $id): Payment
    {
        return Payment::query()
            ->with(['apartment.resident', 'contribution'])
            ->findOrFail($id);
    }

    public function countThisMonth(): int
    {
        return Payment::query()
            ->whereMonth('date', now()->month)
            ->whereYear('date', now()->year)
            ->count();
    }

    /**
     * @return LengthAwarePaginator<int, Payment>
     */
    public function paginateForApartment(int $apartmentId, int $perPage = 15): LengthAwarePaginator
    {
        return Payment::query()
            ->with(['apartment', 'contribution'])
            ->where('apartment_id', $apartmentId)
            ->orderByDesc('date')
            ->orderByDesc('id')
            ->paginate($perPage);
    }

    /**
     * Persist a new payment record.
     *
     * @param  array{apartment_id: int, contribution_id: int, amount_paid: float|string, date: string|\DateTimeInterface, receipt_path?: string|null}  $data
     */
    public function create(array $data): Payment
    {
        return Payment::query()->create($data);
    }
}

