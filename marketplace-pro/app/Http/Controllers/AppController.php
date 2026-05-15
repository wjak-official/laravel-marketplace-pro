<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AppController extends Controller
{
    public function dashboard(Request $request)
    {
        return inertia('App/Dashboard', [
            'user' => $request->user(),
        ]);
    }

    public function security(Request $request)
    {
        return inertia('App/Security', ['user' => $request->user()]);
    }

    public function notifications(Request $request)
    {
        return inertia('App/Notifications', ['user' => $request->user()]);
    }
}
