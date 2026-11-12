<?php

namespace App\Services;

use App\Models\Apartment;
use App\Repositories\ApartmentRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class ApartmentService
{
    public function __construct(
        private readonly ApartmentRepository $apartments,
    ) {}

    /**
     * @return LengthAwarePaginator<int, Apartment>
     */
    public function listPaginated(int $perPage = 15): LengthAwarePaginator
    {
        return $this->apartments->paginate($perPage);
    }

    /**
     * @return Collection<int, Apartment>
     */
    public function listAll(): Collection
    {
        return $this->apartments->allOrdered();
    }

    public function find(int $id): Apartment
    {
        return $this->apartments->find($id);
    }

    /**
     * @param  array{number: string, resident_id?: int|null}  $data
     */
    public function create(array $data): Apartment
    {
        return $this->apartments->create($data);
    }

    /**
     * @param  array{number?: string, resident_id?: int|null}  $data
     */
    public function update(Apartment $apartment, array $data): Apartment
    {
        return $this->apartments->update($apartment, $data);
    }

    public function delete(Apartment $apartment): void
    {
        $this->apartments->delete($apartment);
    }

    public function count(): int
    {
        return $this->apartments->count();
    }
}
