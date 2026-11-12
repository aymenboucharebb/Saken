<?php

namespace Database\Factories;

use App\Models\Apartment;
use App\Models\Contribution;
use App\Models\Payment;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Payment>
 */
class PaymentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'apartment_id' => Apartment::factory(),
            'contribution_id' => Contribution::factory(),
            'amount_paid' => fake()->randomFloat(2, 10, 250),
            'date' => fake()->date(),
            'receipt_path' => null,
        ];
    }
}
