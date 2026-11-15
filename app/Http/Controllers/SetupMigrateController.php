<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schema;
use Throwable;

/**
 * One-shot DB bootstrap for hosts without a shell (e.g. Render free).
 * Protected by SETUP_TOKEN. Disable by removing SETUP_TOKEN from the environment.
 */
class SetupMigrateController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $expected = (string) config('app.setup_token', '');
        $provided = (string) ($request->query('token') ?: $request->bearerToken() ?: '');

        if ($expected === '' || ! hash_equals($expected, $provided)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        try {
            Artisan::call('migrate', ['--force' => true]);
            $migrateOutput = trim(Artisan::output());

            $adminEmail = null;
            $email = (string) config('app.admin_email', '');
            $password = (string) config('app.admin_password', '');
            $name = (string) config('app.admin_name', 'Admin');

            if ($email !== '' && $password !== '' && Schema::hasTable('users')) {
                $admin = User::query()->updateOrCreate(
                    ['email' => $email],
                    [
                        'name' => $name !== '' ? $name : 'Admin',
                        'password' => $password,
                        'role' => 'admin',
                        'email_verified_at' => now(),
                    ],
                );
                $adminEmail = $admin->email;
            }

            return response()->json([
                'ok' => true,
                'migrate' => $migrateOutput,
                'users_table' => Schema::hasTable('users'),
                'sessions_table' => Schema::hasTable('sessions'),
                'admin' => $adminEmail,
            ]);
        } catch (Throwable $e) {
            return response()->json([
                'ok' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
