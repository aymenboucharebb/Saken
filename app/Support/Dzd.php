<?php

namespace App\Support;

use Illuminate\Support\Number;

class Dzd
{
    /**
     * Format an amount in Algerian dinars (DZD).
     */
    public static function format(float|string $amount): string
    {
        return Number::currency((float) $amount, in: 'DZD', locale: 'fr');
    }
}
