<?php

namespace Database\Factories;

use App\Models\Contribution;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Contribution>
 */
class ContributionFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => fake()->randomElement([
                'Charges communes',
                'Travaux ascenseur',
                'Entretien espaces verts',
                'Assurance immeuble',
            ]),
            'amount_per_apartment' => fake()->randomFloat(2, 50, 500),
            'status' => 'active',
        ];
    }

    /**
     * Closed contribution.
     */
    public function closed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'closed',
        ]);
    }
}
