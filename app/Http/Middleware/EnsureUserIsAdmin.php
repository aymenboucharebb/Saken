<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): Response  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->isAdmin()) {
            if ($request->expectsJson()) {
                abort(403, 'Accès réservé au responsable.');
            }

            return redirect()
                ->route('profile.edit')
                ->with('error', 'Cet espace est réservé au responsable de la résidence. Connectez-vous avec le compte admin.');
        }

        return $next($request);
    }
}
