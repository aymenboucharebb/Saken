<?php

namespace App\Repositories;

use App\Models\Apartment;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class ApartmentRepository
{
    /**
     * @return LengthAwarePaginator<int, Apartment>
     */
    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return Apartment::query()
            ->with('resident')
            ->orderBy('number')
            ->paginate($perPage);
    }

    /**
     * @return Collection<int, Apartment>
     */
    public function allOrdered(): Collection
    {
        return Apartment::query()
            ->with('resident')
            ->orderBy('number')
            ->get();
    }

    public function find(int $id): Apartment
    {
        return Apartment::query()->with('resident')->findOrFail($id);
    }

    /**
     * @param  array{number: string, resident_id?: int|null}  $data
     */
    public function create(array $data): Apartment
    {
        return Apartment::query()->create($data);
    }

    /**
     * @param  array{number?: string, resident_id?: int|null}  $data
     */
    public function update(Apartment $apartment, array $data): Apartment
    {
        $apartment->update($data);

        return $apartment->refresh();
    }

    public function delete(Apartment $apartment): void
    {
        $apartment->delete();
    }

    public function count(): int
    {
        return Apartment::query()->count();
    }
}
