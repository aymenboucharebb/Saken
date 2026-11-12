<?php

use App\Http\Controllers\Admin\ApartmentController;
use App\Http\Controllers\Admin\ContributionController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\PaymentController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    if (! auth()->check()) {
        return redirect()->route('login');
    }

    return auth()->user()->isAdmin()
        ? redirect()->route('dashboard')
        : redirect()->route('profile.edit');
});

Route::middleware(['auth', 'admin'])->group(function () {
    Route::get('/dashboard', DashboardController::class)->name('dashboard');

    Route::resource('apartments', ApartmentController::class)->except(['show']);
    Route::resource('contributions', ContributionController::class)->except(['edit', 'destroy']);
    Route::post('contributions/{contribution}/close', [ContributionController::class, 'close'])
        ->name('contributions.close');
    Route::resource('payments', PaymentController::class)->only(['index', 'create', 'store', 'show']);
    Route::get('payments/{payment}/receipt', [PaymentController::class, 'receipt'])
        ->name('payments.receipt');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
