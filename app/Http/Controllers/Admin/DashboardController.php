<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\ApartmentService;
use App\Services\ContributionService;
use App\Services\PaymentService;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __construct(
        private readonly ApartmentService $apartments,
        private readonly ContributionService $contributions,
        private readonly PaymentService $payments,
    ) {}

    public function __invoke(): View
    {
        return view('admin.dashboard', [
            'apartmentCount' => $this->apartments->count(),
            'activeContributionCount' => $this->contributions->countActive(),
            'paymentCountThisMonth' => $this->payments->countThisMonth(),
        ]);
    }
}
