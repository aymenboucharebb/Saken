<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ApartmentResource;
use App\Services\ApartmentService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class ApartmentController extends Controller
{
    public function __construct(
        private readonly ApartmentService $apartments,
    ) {}

    /**
     * Liste tous les appartements (responsable / admin).
     */
    public function index(): AnonymousResourceCollection
    {
        return ApartmentResource::collection(
            $this->apartments->listAll(),
        );
    }

    /**
     * Détail d'un appartement (responsable / admin).
     */
    public function show(int $apartment): ApartmentResource
    {
        return ApartmentResource::make(
            $this->apartments->find($apartment),
        );
    }

    /**
     * Appartement du résident connecté (application mobile).
     */
    public function mine(Request $request): ApartmentResource
    {
        $apartment = $request->user()->apartment()?->load('resident');

        if (! $apartment) {
            throw new NotFoundHttpException('Aucun appartement n\'est associé à votre compte.');
        }

        return ApartmentResource::make($apartment);
    }
}
