<?php

namespace App\Services;

use App\Models\Contribution;
use App\Repositories\ContributionRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use InvalidArgumentException;

class ContributionService
{
    public function __construct(
        private readonly ContributionRepository $contributions,
    ) {}

    /**
     * @return LengthAwarePaginator<int, Contribution>
     */
    public function listPaginated(int $perPage = 15): LengthAwarePaginator
    {
        return $this->contributions->paginate($perPage);
    }

    public function find(int $id): Contribution
    {
        return $this->contributions->find($id);
    }

    /**
     * @param  array{title: string, amount_per_apartment: float|string}  $data
     */
    public function create(array $data): Contribution
    {
        return $this->contributions->create([
            'title' => $data['title'],
            'amount_per_apartment' => $data['amount_per_apartment'],
            'status' => 'active',
        ]);
    }

    /**
     * @param  array{title?: string, amount_per_apartment?: float|string}  $data
     */
    public function update(Contribution $contribution, array $data): Contribution
    {
        return $this->contributions->update($contribution, $data);
    }

    public function close(Contribution $contribution): Contribution
    {
        if ($contribution->status === 'closed') {
            throw new InvalidArgumentException('Cette cotisation est déjà fermée.');
        }

        return $this->contributions->update($contribution, ['status' => 'closed']);
    }

    public function countActive(): int
    {
        return $this->contributions->countActive();
    }

    /**
     * @return \Illuminate\Database\Eloquent\Collection<int, Contribution>
     */
    public function listActive()
    {
        return $this->contributions->allActive();
    }
}
