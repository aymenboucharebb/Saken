<?php

namespace App\Repositories;

use App\Models\Contribution;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ContributionRepository
{
    /**
     * @return LengthAwarePaginator<int, Contribution>
     */
    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return Contribution::query()
            ->orderByDesc('id')
            ->paginate($perPage);
    }

    public function find(int $id): Contribution
    {
        return Contribution::query()->findOrFail($id);
    }

    /**
     * @param  array{title: string, amount_per_apartment: float|string, status?: string}  $data
     */
    public function create(array $data): Contribution
    {
        return Contribution::query()->create($data);
    }

    /**
     * @param  array{title?: string, amount_per_apartment?: float|string, status?: string}  $data
     */
    public function update(Contribution $contribution, array $data): Contribution
    {
        $contribution->update($data);

        return $contribution->refresh();
    }

    public function countActive(): int
    {
        return Contribution::query()->where('status', 'active')->count();
    }

    /**
     * @return \Illuminate\Database\Eloquent\Collection<int, Contribution>
     */
    public function allActive()
    {
        return Contribution::query()
            ->where('status', 'active')
            ->orderByDesc('id')
            ->get();
    }
}
