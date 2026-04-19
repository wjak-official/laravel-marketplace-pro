<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class SecurityHeaders
{
    public function handle(Request $request, Closure $next)
    {
        $res = $next($request);
        // Hardened defaults (tune CSP to your assets/domains)
        $res->headers->set('X-Content-Type-Options', 'nosniff');
        $res->headers->set('X-Frame-Options', 'SAMEORIGIN');
        $res->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        $res->headers->set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
        // You should add a real CSP before production:
        // $res->headers->set('Content-Security-Policy', "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline';");
        return $res;
    }
}
