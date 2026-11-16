<?php

namespace Database\Seeders;

use App\Models\Apartment;
use App\Models\Contribution;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with a rich demo dataset.
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
            ['name' => 'Amine Khelifi', 'email' => 'amine@saken.dz', 'number' => 'B2'],
            ['name' => 'Nadia Cherif', 'email' => 'nadia@saken.dz', 'number' => 'C1'],
            ['name' => 'Omar Belkacem', 'email' => 'omar@saken.dz', 'number' => 'C2'],
            ['name' => 'Lina Messaoud', 'email' => 'lina@saken.dz', 'number' => 'D1'],
            ['name' => 'Riad Bouzid', 'email' => 'riad@saken.dz', 'number' => 'D2'],
            ['name' => 'Fatima Zohra', 'email' => 'fatima@saken.dz', 'number' => 'E1'],
            ['name' => 'Mehdi Saadi', 'email' => 'mehdi@saken.dz', 'number' => 'E2'],
            ['name' => 'Ines Hamidi', 'email' => 'ines@saken.dz', 'number' => 'F1'],
            ['name' => 'Samir Boudiaf', 'email' => 'samir@saken.dz', 'number' => 'F2'],
        ];

        $apartments = collect();

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

            $apartment = Apartment::query()->updateOrCreate(
                ['number' => $resident['number']],
                ['resident_id' => $user->id],
            );

            $apartments->push($apartment);
        }

        // Vacant apartments (no resident yet).
        foreach (['G1', 'G2', 'H1'] as $number) {
            $apartments->push(
                Apartment::query()->updateOrCreate(
                    ['number' => $number],
                    ['resident_id' => null],
                ),
            );
        }

        $occupied = $apartments->filter(fn (Apartment $a) => $a->resident_id !== null)->values();

        $charges2025 = Contribution::query()->updateOrCreate(
            ['title' => 'Charges communes 2025'],
            [
                'amount_per_apartment' => 4500.00,
                'status' => 'active',
            ],
        );

        $ascenseur = Contribution::query()->updateOrCreate(
            ['title' => 'Travaux ascenseur'],
            [
                'amount_per_apartment' => 12000.00,
                'status' => 'active',
            ],
        );

        $espacesVerts = Contribution::query()->updateOrCreate(
            ['title' => 'Entretien espaces verts 2026'],
            [
                'amount_per_apartment' => 2500.00,
                'status' => 'active',
            ],
        );

        $assurance = Contribution::query()->updateOrCreate(
            ['title' => 'Assurance immeuble 2025'],
            [
                'amount_per_apartment' => 3000.00,
                'status' => 'active',
            ],
        );

        $charges2026 = Contribution::query()->updateOrCreate(
            ['title' => 'Charges communes 2026'],
            [
                'amount_per_apartment' => 5000.00,
                'status' => 'active',
            ],
        );

        // Historical payments on 2025 charges (mix of full / partial).
        foreach ($occupied as $index => $apartment) {
            $this->upsertPayment(
                $apartment,
                $charges2025,
                $index % 3 === 0 ? 2000.00 : 4500.00,
                Carbon::parse('2025-03-10')->addDays($index * 3),
            );
        }

        // Elevator fund: several installments for history.
        foreach ($occupied->take(8) as $index => $apartment) {
            $this->upsertPayment(
                $apartment,
                $ascenseur,
                4000.00,
                Carbon::parse('2025-06-01')->addDays($index * 5),
            );
            $this->upsertPayment(
                $apartment,
                $ascenseur,
                4000.00,
                Carbon::parse('2025-08-15')->addDays($index * 4),
            );
            if ($index % 2 === 0) {
                $this->upsertPayment(
                    $apartment,
                    $ascenseur,
                    4000.00,
                    Carbon::parse('2025-10-20')->addDays($index * 2),
                );
            }
        }

        // Green spaces: mostly paid.
        foreach ($occupied as $index => $apartment) {
            $this->upsertPayment(
                $apartment,
                $espacesVerts,
                $index === 1 ? 1000.00 : 2500.00,
                Carbon::parse('2026-01-08')->addDays($index * 2),
            );
        }

        // Insurance 2025: fully paid then close.
        foreach ($occupied as $index => $apartment) {
            $this->upsertPayment(
                $apartment,
                $assurance,
                3000.00,
                Carbon::parse('2025-11-05')->addDays($index),
            );
        }
        $assurance->update(['status' => 'closed']);

        // Current year charges: partial history so dashboard/mobile stay interesting.
        foreach ($occupied->take(9) as $index => $apartment) {
            $amount = match ($index % 4) {
                0 => 5000.00,
                1 => 2500.00,
                2 => 1500.00,
                default => 500.00,
            };

            $this->upsertPayment(
                $apartment,
                $charges2026,
                $amount,
                Carbon::parse('2026-02-01')->addDays($index * 3),
            );
        }

        // Close the older charges campaign after payments exist.
        $charges2025->update(['status' => 'closed']);

        unset($admin);
    }

    private function upsertPayment(
        Apartment $apartment,
        Contribution $contribution,
        float $amount,
        Carbon $date,
    ): void {
        Payment::query()->updateOrCreate(
            [
                'apartment_id' => $apartment->id,
                'contribution_id' => $contribution->id,
                'date' => $date->toDateString(),
                'amount_paid' => $amount,
            ],
            [
                'receipt_path' => null,
            ],
        );
    }
}
