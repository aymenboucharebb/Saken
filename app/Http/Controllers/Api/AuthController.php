<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\LoginRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Connexion (mobile / outils API) — retourne un token Sanctum.
     *
     * Utilisez ce token dans l'en-tête Authorization: Bearer {token}
     */
    public function login(LoginRequest $request): JsonResponse
    {
        if (! Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['Identifiants incorrects.'],
            ]);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $deviceName = $request->string('device_name')->toString() ?: 'api-token';
        $token = $user->createToken($deviceName)->plainTextToken;

        return response()->json([
            'message' => 'Connexion réussie.',
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => UserResource::make($user),
        ]);
    }

    /**
     * Profil de l'utilisateur connecté.
     */
    public function me(Request $request): UserResource
    {
        return UserResource::make($request->user());
    }

    /**
     * Déconnexion — révoque le token courant.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'Déconnexion réussie.',
        ]);
    }
}
