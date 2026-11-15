<?php

namespace App\Providers;

use Dedoc\Scramble\Scramble;
use Dedoc\Scramble\Support\Generator\OpenApi;
use Dedoc\Scramble\Support\Generator\SecurityScheme;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Ensure Vite/asset URLs stay HTTPS when APP_URL is https (Render TLS termination).
        if (str_starts_with((string) config('app.url'), 'https://')) {
            URL::forceScheme('https');
            URL::forceRootUrl(rtrim((string) config('app.url'), '/'));

            // Session cookies must be Secure on HTTPS or browsers / proxies drop them
            // → login appears to "redirect back to login" with no error.
            $domain = config('session.domain');
            if ($domain === 'null' || $domain === '') {
                $domain = null;
            }

            config([
                'session.secure' => true,
                'session.same_site' => config('session.same_site') ?: 'lax',
                'session.domain' => $domain,
            ]);
        }

        Scramble::configure()
            ->withDocumentTransformers(function (OpenApi $openApi): void {
                $openApi->secure(
                    SecurityScheme::http('bearer', 'JWT')
                        ->setDescription('Token Sanctum. Obtenu via POST /api/login. Exemple : Bearer 1|xxxx'),
                );
            });
    }
}
