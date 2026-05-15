<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PublicController extends Controller
{
    public function home() { return inertia('Public/Home'); }
    public function pricing() { return inertia('Public/Pricing'); }
    public function faq() { return inertia('Public/FAQ'); }
    public function about() { return inertia('Public/About'); }
    public function contact() { return inertia('Public/Contact'); }
}
