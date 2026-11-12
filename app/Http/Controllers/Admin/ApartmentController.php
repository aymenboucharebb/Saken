<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreApartmentRequest;
use App\Models\Apartment;
use App\Models\User;
use App\Services\ApartmentService;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class ApartmentController extends Controller
{
    public function __construct(
        private readonly ApartmentService $apartments,
    ) {}

    public function index(): View
    {
        return view('admin.apartments.index', [
            'apartments' => $this->apartments->listPaginated(),
        ]);
    }

    public function create(): View
    {
        return view('admin.apartments.create', [
            'residents' => $this->residentOptions(),
        ]);
    }

    public function store(StoreApartmentRequest $request): RedirectResponse
    {
        $this->apartments->create($request->validated());

        return redirect()
            ->route('apartments.index')
            ->with('success', 'Appartement enregistré avec succès.');
    }

    public function edit(Apartment $apartment): View
    {
        return view('admin.apartments.edit', [
            'apartment' => $apartment,
            'residents' => $this->residentOptions(),
        ]);
    }

    public function update(StoreApartmentRequest $request, Apartment $apartment): RedirectResponse
    {
        $this->apartments->update($apartment, $request->validated());

        return redirect()
            ->route('apartments.index')
            ->with('success', 'Appartement mis à jour.');
    }

    public function destroy(Apartment $apartment): RedirectResponse
    {
        $this->apartments->delete($apartment);

        return redirect()
            ->route('apartments.index')
            ->with('success', 'Appartement supprimé.');
    }

    /**
     * @return \Illuminate\Database\Eloquent\Collection<int, User>
     */
    private function residentOptions()
    {
        return User::query()
            ->where('role', 'resident')
            ->orderBy('name')
            ->get(['id', 'name', 'email']);
    }
}
