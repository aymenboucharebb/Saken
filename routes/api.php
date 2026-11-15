<?php

use App\Http\Controllers\Api\ApartmentController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContributionController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\SetupMigrateController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Saken — consommée par Flutter et outils (Swagger / Scramble)
|--------------------------------------------------------------------------
| Auth : Bearer token Sanctum (POST /api/login)
*/

// No session middleware (api) — usable even when sessions table is missing.
Route::match(['GET', 'POST'], '/setup/migrate', SetupMigrateController::class);

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/user', [AuthController::class, 'me']); // alias Swagger / anciens clients

    // Résident (mobile)
    Route::get('/my-apartment', [ApartmentController::class, 'mine']);

    // Cotisations & paiements (résident + admin)
    Route::get('/contributions', [ContributionController::class, 'index']);
    Route::get('/contributions/{contribution}', [ContributionController::class, 'show']);
    Route::get('/payments', [PaymentController::class, 'index']);
    Route::get('/payments/{payment}', [PaymentController::class, 'show']);
    Route::get('/payments/{payment}/receipt', [PaymentController::class, 'receipt']);
    Route::post('/payments', [PaymentController::class, 'store']);

    // Admin / CMS JSON
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/apartments', [ApartmentController::class, 'index']);
        Route::get('/apartments/{apartment}', [ApartmentController::class, 'show']);
    });
});
