<?php

namespace Database\Factories;

use App\Models\Apartment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Apartment>
 */
class ApartmentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'number' => (string) fake()->unique()->numberBetween(1, 200),
            'resident_id' => User::factory(),
        ];
    }

    /**
     * Apartment without an assigned resident.
     */
    public function vacant(): static
    {
        return $this->state(fn (array $attributes) => [
            'resident_id' => null,
        ]);
    }
}
