<?php

namespace Database\Seeders;

use App\Models\Apartment;
use App\Models\Contribution;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::query()->updateOrCreate(
            ['email' => 'admin@saken.dz'],
            [
                'name' => 'Responsable',
                'password' => 'password',
                'role' => 'admin',
                'email_verified_at' => now(),
            ],
        );

        $residents = [
            ['name' => 'Karim Benali', 'email' => 'karim@saken.dz', 'number' => 'A1'],
            ['name' => 'Sara Mansouri', 'email' => 'sara@saken.dz', 'number' => 'A2'],
            ['name' => 'Youcef Haddad', 'email' => 'youcef@saken.dz', 'number' => 'B1'],
        ];

        foreach ($residents as $resident) {
            $user = User::query()->updateOrCreate(
                ['email' => $resident['email']],
                [
                    'name' => $resident['name'],
                    'password' => 'password',
                    'role' => 'resident',
                    'email_verified_at' => now(),
                ],
            );

            Apartment::query()->updateOrCreate(
                ['number' => $resident['number']],
                ['resident_id' => $user->id],
            );
        }

        Contribution::query()->updateOrCreate(
            ['title' => 'Charges communes 2026'],
            [
                'amount_per_apartment' => 5000.00,
                'status' => 'active',
            ],
        );

        unset($admin);
    }
}
