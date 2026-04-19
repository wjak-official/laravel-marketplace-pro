#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${1:-marketplace-pro}"
APP_URL="${APP_URL:-https://marketplace-pro.mynet}"

DB_CONNECTION="${DB_CONNECTION:-mysql}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_DATABASE="${DB_DATABASE:-marketplace_pro}"
DB_USERNAME="${DB_USERNAME:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"

ADMIN_EMAIL="${ADMIN_EMAIL:-admin@marketplace.mynet}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin12345!}"

HTDOCS_DIR_DEFAULT="/shared/httpd/"
if [ -d "${HTDOCS_DIR_DEFAULT}" ]; then
  HTDOCS_DIR="${HTDOCS_DIR:-${HTDOCS_DIR_DEFAULT}}"
else
  HTDOCS_DIR="${HTDOCS_DIR:-htdocs}"
fi

STATE_FILE=""

run_step() {
  local name="$1"
  shift
  if [ -n "${STATE_FILE}" ] && [ -f "${STATE_FILE}" ] && grep -Fxq -- "${name}" "${STATE_FILE}"; then
    echo "==> Skipping: ${name}"
    return 0
  fi
  echo "==> ${name}"
  "$@"
  if [ -n "${STATE_FILE}" ]; then
    echo "${name}" >> "${STATE_FILE}"
  fi
}

# install_breeze() {
#   local help
#   help="$(php artisan breeze:install --help 2>/dev/null || true)"
#   if echo "${help}" | grep -q -- "--stack"; then
#     php artisan breeze:install --stack=vue --inertia
#   elif echo "${help}" | grep -q -- "inertia"; then
#     php artisan breeze:install vue --inertia
#   else
#     php artisan breeze:install vue
#   fi
# }

# install_breeze_step() {
#   composer require laravel/breeze --dev
#   install_breeze
#   # Align Vite with @vitejs/plugin-vue peer range to avoid ERESOLVE
#   # npm install vite@^4.0.0 @vitejs/plugin-vue@^4.0.0
# }

make_model_if_missing() {
  local name="$1"
  if [ ! -f "app/Models/${name}.php" ]; then
    php artisan make:model "${name}" -m
  fi
}

migrate_seed_step() {
  php artisan migrate
  php artisan db:seed
}

build_assets_step() {
  npm run build
}

copy_to_htdocs_step() {
  local dest="${HTDOCS_DIR}/${APP_DIR}"
  mkdir -p "${dest}"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${SRC_DIR}/" "${dest}/"
  else
    cp -a "${SRC_DIR}/." "${dest}/"
  fi
}

BASE_DIR="$(pwd)"

# echo "==> Creating/using Laravel app in: ${APP_DIR}"
# if [ -d "${APP_DIR}" ]; then
#   if [ ! -f "${APP_DIR}/composer.json" ]; then
#     echo "ERROR: ${APP_DIR} exists but is not a Laravel app (missing composer.json)."
#     exit 1
#   fi
# else
#   # composer create-project laravel/laravel "${APP_DIR}"
# fi

# cd "${APP_DIR}"
# SRC_DIR="${BASE_DIR}/${APP_DIR}"
# STATE_FILE=".bootstrap_state"
# touch "${STATE_FILE}"

# echo "==> .env"
#cp .env.example .env
#php artisan key:generate

#php -r '
# $env=file_get_contents(".env");
# $set = [
#  "APP_URL" => "'"${APP_URL}"'",
#  "DB_CONNECTION" => "'"${DB_CONNECTION}"'",
#  "DB_HOST" => "'"${DB_HOST}"'",
#  "DB_PORT" => "'"${DB_PORT}"'",
#  "DB_DATABASE" => "'"${DB_DATABASE}"'",
#  "DB_USERNAME" => "'"${DB_USERNAME}"'",
#  "DB_PASSWORD" => "'"${DB_PASSWORD}"'",
# ];
# foreach ($set as $k=>$v) {
#   $env=preg_replace("/^".$k."=.*/m", $k."=".$v, $env);
# }
# $append = "\nAPP_CURRENCY=USD\nAPP_FEE_SELLER_LISTING=499\nAPP_FEE_BUYER_REQUEST=499\n".
#           "STRIPE_KEY=pk_test_change_me\nSTRIPE_SECRET=sk_test_change_me\nSTRIPE_WEBHOOK_SECRET=whsec_change_me\n";
# if (!preg_match("/^APP_CURRENCY=/m", $env)) $env .= $append;
# file_put_contents(".env",$env);
# '

# run_step "Breeze (Inertia + Vue)" install_breeze_step

# echo "==> Styling & animation libs"
# # npm install @headlessui/vue @heroicons/vue @vueuse/core aos @studio-freight/lenis

# # echo "==> Filament + Roles + Stripe"
# composer require filament/filament:"^3.0"
# if [ ! -f app/Providers/Filament/AdminPanelProvider.php ]; then
#   php artisan filament:install --panels
# fi

# composer require spatie/laravel-permission
# if [ ! -f config/permission.php ]; then
#   php artisan vendor:publish --provider="Spatie\\Permission\\PermissionServiceProvider"
# fi

# composer require stripe/stripe-php

# echo "==> Create directories"
# mkdir -p app/Enums app/Services app/Http/Middleware app/Http/Controllers app/Http/Requests
# mkdir -p app/Models app/Policies app/Jobs
# mkdir -p app/Filament/Resources app/Filament/Pages app/Filament/Widgets
# mkdir -p database/seeders database/factories
# mkdir -p resources/js/Layouts resources/js/Components resources/js/Pages
# mkdir -p resources/js/Pages/Public resources/js/Pages/App resources/js/Pages/Seller resources/js/Pages/Buyer
# mkdir -p resources/css

echo "==> config/services.php"
php -r '
$p="config/services.php"; $c=file_get_contents($p);
if (strpos($c,"\"stripe\"")===false) {
  $c=preg_replace("/return \\[/","return [\n\n    \"stripe\" => [\n        \"key\" => env(\"STRIPE_KEY\"),\n        \"secret\" => env(\"STRIPE_SECRET\"),\n        \"webhook_secret\" => env(\"STRIPE_WEBHOOK_SECRET\"),\n    ],\n\n    \"fees\" => [\n        \"seller_listing\" => env(\"APP_FEE_SELLER_LISTING\", 499),\n        \"buyer_request\" => env(\"APP_FEE_BUYER_REQUEST\", 499),\n    ],\n\n",$c,1);
}
file_put_contents($p,$c);
'

echo "==> Middleware: EnsureAdmin + SecurityHeaders"
cat > app/Http/Middleware/EnsureAdmin.php <<'PHP'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsureAdmin
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user() || !$request->user()->hasRole('admin')) {
            abort(403);
        }
        return $next($request);
    }
}
PHP

cat > app/Http/Middleware/SecurityHeaders.php <<'PHP'
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
PHP

echo "==> Register middleware aliases"
php /dev/stdin <<'PHPEOF'
<?php
$path="app/Http/Kernel.php"; $c=file_get_contents($path);
if (strpos($c,"SecurityHeaders::class")===false) {
  $c=preg_replace("/protected \\$middleware = \\[/","protected \$middleware = [\n        \\\\App\\\\Http\\\\Middleware\\\\SecurityHeaders::class,\n",$c,1);
}
if (strpos($c,"'admin' =>")===false) {
  $c=preg_replace("/protected \\$middlewareAliases = \\[/","protected \$middlewareAliases = [\n        'admin' => \\\\App\\\\Http\\\\Middleware\\\\EnsureAdmin::class,\n",$c,1);
}
file_put_contents($path,$c);
PHPEOF

echo "==> Update User model for HasRoles"
php -r '
$p="app/Models/User.php"; $c=file_get_contents($p);
if (strpos($c,"HasRoles")===false) {
  $c=str_replace("use Illuminate\\Notifications\\Notifiable;","use Illuminate\\Notifications\\Notifiable;\nuse Spatie\\Permission\\Traits\\HasRoles;",$c);
  $c=str_replace("use HasFactory, Notifiable;","use HasFactory, Notifiable, HasRoles;",$c);
}
file_put_contents($p,$c);
'

echo "==> Core models migrations"
make_model_if_missing SellerListing
make_model_if_missing BuyerRequest
make_model_if_missing MatchRecord
make_model_if_missing Offer
make_model_if_missing Order
make_model_if_missing Transaction
make_model_if_missing Shipment
make_model_if_missing Setting

# Overwrite migrations
MIG() { ls database/migrations/*_"$1".php | tail -n 1; }

cat > "$(MIG create_seller_listings_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('seller_listings', function (Blueprint $table) {
      $table->id();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->string('title');
      $table->text('description')->nullable();
      $table->string('category')->index();
      $table->unsignedInteger('price_min')->nullable();
      $table->unsignedInteger('price_max')->nullable();
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('condition')->index();
      $table->string('status')->default('draft')->index(); // draft/pending_review/active/reserved/sold/archived
      $table->json('photos')->nullable();
      $table->json('attributes')->nullable();
      $table->string('pickup_city')->nullable();
      $table->decimal('pickup_lat', 10, 7)->nullable();
      $table->decimal('pickup_lng', 10, 7)->nullable();
      $table->timestamp('available_from')->nullable();
      $table->timestamp('available_to')->nullable();
      $table->timestamp('activated_at')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('seller_listings'); }
};
PHP

cat > "$(MIG create_buyer_requests_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('buyer_requests', function (Blueprint $table) {
      $table->id();
      $table->foreignId('user_id')->constrained()->cascadeOnDelete();
      $table->string('query');
      $table->string('category')->index();
      $table->text('details')->nullable();
      $table->unsignedInteger('budget_min')->nullable();
      $table->unsignedInteger('budget_max')->nullable();
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->boolean('allow_external_sources')->default(true);
      $table->string('status')->default('draft')->index();
      $table->json('must_haves')->nullable();
      $table->json('nice_to_haves')->nullable();
      $table->string('delivery_city')->nullable();
      $table->decimal('delivery_lat', 10, 7)->nullable();
      $table->decimal('delivery_lng', 10, 7)->nullable();
      $table->timestamp('activated_at')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('buyer_requests'); }
};
PHP

cat > "$(MIG create_match_records_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('match_records', function (Blueprint $table) {
      $table->id();
      $table->foreignId('buyer_request_id')->constrained()->cascadeOnDelete();
      $table->foreignId('seller_listing_id')->nullable()->constrained()->nullOnDelete();
      $table->unsignedSmallInteger('score')->default(0)->index();
      $table->string('source')->default('internal')->index();
      $table->string('status')->default('suggested')->index();
      $table->json('external_payload')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('match_records'); }
};
PHP

cat > "$(MIG create_offers_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('offers', function (Blueprint $table) {
      $table->id();
      $table->foreignId('match_record_id')->constrained()->cascadeOnDelete();
      $table->unsignedInteger('item_price');
      $table->unsignedInteger('platform_fee');
      $table->unsignedInteger('delivery_fee');
      $table->unsignedInteger('tax')->default(0);
      $table->unsignedInteger('total');
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('status')->default('draft')->index(); // draft/sent/accepted/rejected/expired
      $table->json('breakdown')->nullable();
      $table->timestamp('expires_at')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('offers'); }
};
PHP

cat > "$(MIG create_orders_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('orders', function (Blueprint $table) {
      $table->id();
      $table->foreignId('offer_id')->constrained()->cascadeOnDelete();
      $table->foreignId('buyer_id')->constrained('users')->cascadeOnDelete();
      $table->foreignId('seller_id')->nullable()->constrained('users')->nullOnDelete();
      $table->string('status')->default('pending_payment')->index();
      $table->unsignedInteger('total');
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('stripe_payment_intent_id')->nullable()->index();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('orders'); }
};
PHP

cat > "$(MIG create_transactions_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('transactions', function (Blueprint $table) {
      $table->id();
      $table->foreignId('order_id')->constrained()->cascadeOnDelete();
      $table->string('type')->index();
      $table->unsignedInteger('amount');
      $table->string('currency', 3)->default(env('APP_CURRENCY','USD'));
      $table->string('provider')->default('stripe')->index();
      $table->string('provider_ref')->nullable()->index();
      $table->string('status')->default('pending')->index();
      $table->json('meta')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('transactions'); }
};
PHP

cat > "$(MIG create_shipments_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('shipments', function (Blueprint $table) {
      $table->id();
      $table->foreignId('order_id')->constrained()->cascadeOnDelete();
      $table->string('courier')->nullable();
      $table->string('tracking_number')->nullable()->index();
      $table->string('status')->default('pending')->index();
      $table->json('pickup')->nullable();
      $table->json('dropoff')->nullable();
      $table->json('events')->nullable();
      $table->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('shipments'); }
};
PHP

cat > "$(MIG create_settings_table)" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('settings', function (Blueprint $table) {
      $table->id();
      $table->string('group')->default('general')->index();
      $table->string('key')->index();
      $table->json('value')->nullable();
      $table->timestamps();
      $table->unique(['group','key']);
    });
  }
  public function down(): void { Schema::dropIfExists('settings'); }
};
PHP

echo "==> Overwrite models with relationships + casts"
cat > app/Models/SellerListing.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SellerListing extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id','title','description','category','price_min','price_max','currency',
        'condition','status','photos','attributes','pickup_city','pickup_lat','pickup_lng',
        'available_from','available_to','activated_at'
    ];

    protected $casts = [
        'photos' => 'array',
        'attributes' => 'array',
        'available_from' => 'datetime',
        'available_to' => 'datetime',
        'activated_at' => 'datetime',
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function matches() { return $this->hasMany(MatchRecord::class); }
}
PHP

cat > app/Models/BuyerRequest.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class BuyerRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id','query','category','details','budget_min','budget_max','currency',
        'allow_external_sources','status','must_haves','nice_to_haves',
        'delivery_city','delivery_lat','delivery_lng','activated_at'
    ];

    protected $casts = [
        'allow_external_sources' => 'boolean',
        'must_haves' => 'array',
        'nice_to_haves' => 'array',
        'activated_at' => 'datetime',
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function matches() { return $this->hasMany(MatchRecord::class); }
}
PHP

cat > app/Models/MatchRecord.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MatchRecord extends Model
{
    use HasFactory;

    protected $fillable = [
        'buyer_request_id','seller_listing_id','score','source','status','external_payload'
    ];

    protected $casts = [
        'external_payload' => 'array',
    ];

    public function buyerRequest() { return $this->belongsTo(BuyerRequest::class); }
    public function sellerListing() { return $this->belongsTo(SellerListing::class); }
    public function offers() { return $this->hasMany(Offer::class); }
}
PHP

cat > app/Models/Offer.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Offer extends Model
{
    use HasFactory;

    protected $fillable = [
        'match_record_id','item_price','platform_fee','delivery_fee','tax','total','currency',
        'status','breakdown','expires_at'
    ];

    protected $casts = [
        'breakdown' => 'array',
        'expires_at' => 'datetime',
    ];

    public function matchRecord() { return $this->belongsTo(MatchRecord::class); }
    public function order() { return $this->hasOne(Order::class); }
}
PHP

cat > app/Models/Order.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'offer_id','buyer_id','seller_id','status','total','currency','stripe_payment_intent_id'
    ];

    public function offer() { return $this->belongsTo(Offer::class); }
    public function buyer() { return $this->belongsTo(User::class, 'buyer_id'); }
    public function seller() { return $this->belongsTo(User::class, 'seller_id'); }
    public function transactions() { return $this->hasMany(Transaction::class); }
    public function shipment() { return $this->hasOne(Shipment::class); }
}
PHP

cat > app/Models/Transaction.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id','type','amount','currency','provider','provider_ref','status','meta'
    ];

    protected $casts = [
        'meta' => 'array'
    ];

    public function order() { return $this->belongsTo(Order::class); }
}
PHP

cat > app/Models/Shipment.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Shipment extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id','courier','tracking_number','status','pickup','dropoff','events'
    ];

    protected $casts = [
        'pickup' => 'array',
        'dropoff' => 'array',
        'events' => 'array',
    ];

    public function order() { return $this->belongsTo(Order::class); }
}
PHP

cat > app/Models/Setting.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Setting extends Model
{
    use HasFactory;

    protected $fillable = ['group','key','value'];

    protected $casts = [
        'value' => 'array',
    ];
}
PHP

echo "==> Policies (owner + admin)"
if [ ! -f app/Policies/SellerListingPolicy.php ]; then
  php artisan make:policy SellerListingPolicy --model=SellerListing >/dev/null
fi
if [ ! -f app/Policies/BuyerRequestPolicy.php ]; then
  php artisan make:policy BuyerRequestPolicy --model=BuyerRequest >/dev/null
fi

cat > app/Policies/SellerListingPolicy.php <<'PHP'
<?php

namespace App\Policies;

use App\Models\User;
use App\Models\SellerListing;

class SellerListingPolicy
{
    public function view(User $user, SellerListing $listing): bool
    {
        return $user->hasRole('admin') || $listing->user_id === $user->id;
    }

    public function update(User $user, SellerListing $listing): bool
    {
        if ($user->hasRole('admin')) return true;
        return $listing->user_id === $user->id && in_array($listing->status, ['draft','pending_review'], true);
    }
}
PHP

cat > app/Policies/BuyerRequestPolicy.php <<'PHP'
<?php

namespace App\Policies;

use App\Models\User;
use App\Models\BuyerRequest;

class BuyerRequestPolicy
{
    public function view(User $user, BuyerRequest $buyerRequest): bool
    {
        return $user->hasRole('admin') || $buyerRequest->user_id === $user->id;
    }

    public function update(User $user, BuyerRequest $buyerRequest): bool
    {
        if ($user->hasRole('admin')) return true;
        return $buyerRequest->user_id === $user->id && in_array($buyerRequest->status, ['draft'], true);
    }
}
PHP

echo "==> Register policies"
php -r '
$p="app/Providers/AuthServiceProvider.php"; $c=file_get_contents($p);
if (strpos($c,"SellerListing::class")===false) {
  $c=preg_replace("/namespace App\\\\Providers;\\n\\nuse /",
"namespace App\\\\Providers;\n\nuse App\\\\Models\\\\SellerListing;\nuse App\\\\Models\\\\BuyerRequest;\nuse App\\\\Policies\\\\SellerListingPolicy;\nuse App\\\\Policies\\\\BuyerRequestPolicy;\n\nuse ",
$c,1);
  $c=preg_replace("/protected \\$policies = \\[/",
"protected \$policies = [\n        SellerListing::class => SellerListingPolicy::class,\n        BuyerRequest::class => BuyerRequestPolicy::class,\n",
$c,1);
}
file_put_contents($p,$c);
'

echo "==> Controllers (Public pages + App pages + flows + payments + webhook)"
php artisan make:controller PublicController >/dev/null
php artisan make:controller AppController >/dev/null
php artisan make:controller SellerFlowController >/dev/null
php artisan make:controller BuyerFlowController >/dev/null
php artisan make:controller PaymentsController >/dev/null
php artisan make:controller StripeWebhookController >/dev/null

cat > app/Http/Controllers/PublicController.php <<'PHP'
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
PHP

cat > app/Http/Controllers/AppController.php <<'PHP'
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
PHP

cat > app/Http/Controllers/SellerFlowController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use App\Models\SellerListing;
use Illuminate\Http\Request;

class SellerFlowController extends Controller
{
    public function wizard()
    {
        return inertia('Seller/Wizard', [
            'fee' => (int) config('services.fees.seller_listing', env('APP_FEE_SELLER_LISTING', 499)),
            'currency' => env('APP_CURRENCY','USD'),
        ]);
    }

    public function saveDraft(Request $request)
    {
        $data = $request->validate([
            'id' => 'nullable|integer',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:100',
            'condition' => 'required|in:new,like_new,used,fair',
            'price_min' => 'nullable|integer|min:0',
            'price_max' => 'nullable|integer|min:0',
            'pickup_city' => 'nullable|string|max:120',
            'attributes' => 'nullable|array',
            'photos' => 'nullable|array',
        ]);

        $listing = SellerListing::updateOrCreate(
            ['id' => $data['id'] ?? null, 'user_id' => $request->user()->id],
            array_merge(collect($data)->except('id')->toArray(), ['status' => 'draft'])
        );

        return response()->json(['id' => $listing->id]);
    }
}
PHP

cat > app/Http/Controllers/BuyerFlowController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use App\Models\BuyerRequest;
use Illuminate\Http\Request;

class BuyerFlowController extends Controller
{
    public function concierge()
    {
        return inertia('Buyer/Concierge', [
            'fee' => (int) config('services.fees.buyer_request', env('APP_FEE_BUYER_REQUEST', 499)),
            'currency' => env('APP_CURRENCY','USD'),
        ]);
    }

    public function saveDraft(Request $request)
    {
        $data = $request->validate([
            'id' => 'nullable|integer',
            'query' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'details' => 'nullable|string',
            'budget_min' => 'nullable|integer|min:0',
            'budget_max' => 'nullable|integer|min:0',
            'allow_external_sources' => 'boolean',
            'must_haves' => 'nullable|array',
            'nice_to_haves' => 'nullable|array',
            'delivery_city' => 'nullable|string|max:120',
        ]);

        $req = BuyerRequest::updateOrCreate(
            ['id' => $data['id'] ?? null, 'user_id' => $request->user()->id],
            array_merge(collect($data)->except('id')->toArray(), ['status' => 'draft'])
        );

        return response()->json(['id' => $req->id]);
    }
}
PHP

cat > app/Http/Controllers/PaymentsController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use App\Models\SellerListing;
use App\Models\BuyerRequest;
use Illuminate\Http\Request;
use Stripe\StripeClient;

class PaymentsController extends Controller
{
    private function stripe(): StripeClient
    {
        return new StripeClient(config('services.stripe.secret'));
    }

    public function sellerCheckout(Request $request, SellerListing $listing)
    {
        $this->authorize('update', $listing);

        $fee = (int) config('services.fees.seller_listing');
        $currency = strtolower($listing->currency ?? env('APP_CURRENCY','USD'));

        $session = $this->stripe()->checkout->sessions->create([
            'mode' => 'payment',
            'customer_email' => $request->user()->email,
            'line_items' => [[
                'quantity' => 1,
                'price_data' => [
                    'currency' => $currency,
                    'unit_amount' => $fee,
                    'product_data' => ['name' => 'Seller Listing Activation'],
                ],
            ]],
            'metadata' => [
                'type' => 'seller_listing_activation',
                'listing_id' => (string) $listing->id,
                'user_id' => (string) $request->user()->id,
            ],
            'success_url' => url("/app/dashboard?paid=1"),
            'cancel_url' => url("/sell/wizard?cancel=1"),
        ]);

        return redirect($session->url);
    }

    public function buyerCheckout(Request $request, BuyerRequest $buyerRequest)
    {
        $this->authorize('update', $buyerRequest);

        $fee = (int) config('services.fees.buyer_request');
        $currency = strtolower($buyerRequest->currency ?? env('APP_CURRENCY','USD'));

        $session = $this->stripe()->checkout->sessions->create([
            'mode' => 'payment',
            'customer_email' => $request->user()->email,
            'line_items' => [[
                'quantity' => 1,
                'price_data' => [
                    'currency' => $currency,
                    'unit_amount' => $fee,
                    'product_data' => ['name' => 'Buyer Concierge Activation'],
                ],
            ]],
            'metadata' => [
                'type' => 'buyer_request_activation',
                'request_id' => (string) $buyerRequest->id,
                'user_id' => (string) $request->user()->id,
            ],
            'success_url' => url("/app/dashboard?paid=1"),
            'cancel_url' => url("/buy/concierge?cancel=1"),
        ]);

        return redirect($session->url);
    }
}
PHP

cat > app/Http/Controllers/StripeWebhookController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Stripe\Webhook;
use App\Models\SellerListing;
use App\Models\BuyerRequest;

class StripeWebhookController extends Controller
{
    public function handle(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $secret = config('services.stripe.webhook_secret');

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $secret);
        } catch (\Throwable $e) {
            return response('Invalid signature', 400);
        }

        if ($event->type === 'checkout.session.completed') {
            $session = $event->data->object;
            $type = $session->metadata->type ?? null;

            if ($type === 'seller_listing_activation') {
                $listingId = (int) ($session->metadata->listing_id ?? 0);
                SellerListing::whereKey($listingId)->update([
                    'status' => 'pending_review',
                    'activated_at' => now(),
                ]);
            }

            if ($type === 'buyer_request_activation') {
                $requestId = (int) ($session->metadata->request_id ?? 0);
                BuyerRequest::whereKey($requestId)->update([
                    'status' => 'active',
                    'activated_at' => now(),
                ]);
            }
        }

        return response('ok', 200);
    }
}
PHP

echo "==> Routes (public + app + flows + webhook)"
cat > routes/web.php <<'PHP'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PublicController;
use App\Http\Controllers\AppController;
use App\Http\Controllers\SellerFlowController;
use App\Http\Controllers\BuyerFlowController;
use App\Http\Controllers\PaymentsController;
use App\Http\Controllers\StripeWebhookController;

Route::get('/', [PublicController::class, 'home'])->name('home');
Route::get('/pricing', [PublicController::class, 'pricing'])->name('pricing');
Route::get('/faq', [PublicController::class, 'faq'])->name('faq');
Route::get('/about', [PublicController::class, 'about'])->name('about');
Route::get('/contact', [PublicController::class, 'contact'])->name('contact');

Route::middleware(['auth','verified'])->group(function () {
    Route::get('/app/dashboard', [AppController::class, 'dashboard'])->name('app.dashboard');
    Route::get('/app/security', [AppController::class, 'security'])->name('app.security');
    Route::get('/app/notifications', [AppController::class, 'notifications'])->name('app.notifications');

    Route::get('/sell/wizard', [SellerFlowController::class, 'wizard'])->name('sell.wizard');
    Route::post('/sell/draft', [SellerFlowController::class, 'saveDraft'])->name('sell.draft');
    Route::post('/sell/checkout/{listing}', [PaymentsController::class, 'sellerCheckout'])->name('sell.checkout');

    Route::get('/buy/concierge', [BuyerFlowController::class, 'concierge'])->name('buy.concierge');
    Route::post('/buy/draft', [BuyerFlowController::class, 'saveDraft'])->name('buy.draft');
    Route::post('/buy/checkout/{buyerRequest}', [PaymentsController::class, 'buyerCheckout'])->name('buy.checkout');
});

Route::post('/stripe/webhook', [StripeWebhookController::class, 'handle'])
    ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class])
    ->name('stripe.webhook');

require __DIR__.'/auth.php';
PHP

echo "==> Tailwind: add nicer base styles"
cat > resources/css/app.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html { scroll-behavior: smooth; }
  body { @apply bg-zinc-950 text-zinc-50; }
}
@layer components {
  .card { @apply bg-zinc-900/60 border border-zinc-800 rounded-2xl shadow-sm; }
  .btn { @apply inline-flex items-center justify-center rounded-xl px-4 py-2 font-medium transition; }
  .btn-primary { @apply btn bg-white text-zinc-900 hover:bg-zinc-200; }
  .btn-ghost { @apply btn bg-zinc-900/40 hover:bg-zinc-900 border border-zinc-800; }
  .input { @apply w-full rounded-xl bg-zinc-950/40 border border-zinc-800 px-4 py-3 outline-none focus:ring-2 focus:ring-white/30; }
}
CSS

echo "==> Inertia Layouts + animated helpers (Lenis + AOS)"
cat > resources/js/Layouts/PublicLayout.vue <<'VUE'
<script setup>
import { onMounted } from 'vue'
import AOS from 'aos'
import 'aos/dist/aos.css'
import Lenis from '@studio-freight/lenis'
import { Link } from '@inertiajs/vue3'

onMounted(() => {
  AOS.init({ duration: 700, easing: 'ease-out-cubic', once: true })
  const lenis = new Lenis({ smoothWheel: true })
  function raf(time) { lenis.raf(time); requestAnimationFrame(raf) }
  requestAnimationFrame(raf)
})
</script>

<template>
  <div class="min-h-screen">
    <header class="sticky top-0 z-50 backdrop-blur bg-zinc-950/70 border-b border-zinc-800">
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <Link href="/" class="font-semibold tracking-tight">ConciergeMarket</Link>
        <nav class="flex items-center gap-4 text-sm">
          <Link class="opacity-80 hover:opacity-100" href="/pricing">Pricing</Link>
          <Link class="opacity-80 hover:opacity-100" href="/faq">FAQ</Link>
          <Link class="opacity-80 hover:opacity-100" href="/about">About</Link>
          <Link class="opacity-80 hover:opacity-100" href="/contact">Contact</Link>
          <Link class="btn-ghost" href="/login">Log in</Link>
          <Link class="btn-primary" href="/register">Get started</Link>
        </nav>
      </div>
    </header>

    <main>
      <slot />
    </main>

    <footer class="border-t border-zinc-800 mt-20">
      <div class="max-w-6xl mx-auto px-4 py-10 text-sm opacity-80 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>© {{ new Date().getFullYear() }} ConciergeMarket. All rights reserved.</div>
        <div class="flex gap-4">
          <a href="/privacy" class="hover:opacity-100">Privacy</a>
          <a href="/terms" class="hover:opacity-100">Terms</a>
        </div>
      </div>
    </footer>
  </div>
</template>
VUE

cat > resources/js/Layouts/AppLayout.vue <<'VUE'
<script setup>
import { Link, usePage } from '@inertiajs/vue3'
const page = usePage()
</script>

<template>
  <div class="min-h-screen bg-zinc-950 text-zinc-50">
    <div class="border-b border-zinc-800 bg-zinc-950/60 backdrop-blur sticky top-0 z-40">
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <Link href="/app/dashboard" class="font-semibold">ConciergeMarket</Link>
          <span class="text-xs opacity-60">User Portal</span>
        </div>
        <div class="flex items-center gap-2 text-sm">
          <Link class="btn-ghost" href="/sell/wizard">Sell</Link>
          <Link class="btn-ghost" href="/buy/concierge">Buy</Link>
          <Link class="btn-ghost" href="/app/security">Security</Link>
          <Link class="btn-ghost" href="/app/notifications">Notifications</Link>
          <Link class="btn-primary" href="/logout" method="post" as="button">Logout</Link>
        </div>
      </div>
    </div>

    <div class="max-w-6xl mx-auto px-4 py-8 grid grid-cols-1 md:grid-cols-12 gap-6">
      <aside class="md:col-span-3 card p-4">
        <div class="text-sm opacity-70 mb-3">Menu</div>
        <div class="space-y-2 text-sm">
          <Link class="block opacity-90 hover:opacity-100" href="/app/dashboard">Dashboard</Link>
          <Link class="block opacity-90 hover:opacity-100" href="/sell/wizard">Sell onboarding</Link>
          <Link class="block opacity-90 hover:opacity-100" href="/buy/concierge">Buy onboarding</Link>
          <div class="pt-2 border-t border-zinc-800 mt-2"></div>
          <Link class="block opacity-90 hover:opacity-100" href="/app/security">Profile & Security</Link>
          <Link class="block opacity-90 hover:opacity-100" href="/app/notifications">Notifications</Link>
        </div>
      </aside>

      <main class="md:col-span-9">
        <slot />
      </main>
    </div>
  </div>
</template>
VUE

echo "==> Public pages (landing sections + pricing + faq + about + contact)"
cat > resources/js/Pages/Public/Home.vue <<'VUE'
<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
import { Link } from '@inertiajs/vue3'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 pt-16 pb-10">
      <div class="grid md:grid-cols-12 gap-8 items-center">
        <div class="md:col-span-7" data-aos="fade-up">
          <p class="text-xs uppercase tracking-widest opacity-70">Sell & buy with one point of contact</p>
          <h1 class="text-4xl md:text-6xl font-semibold leading-tight mt-3">
            Concierge marketplace that handles sourcing, selling, and delivery.
          </h1>
          <p class="opacity-80 mt-4 text-lg">
            Sellers list in minutes. Buyers describe what they want. We match, negotiate, arrange logistics, and bill from the platform.
          </p>
          <div class="mt-6 flex flex-wrap gap-3">
            <Link class="btn-primary" href="/register">Start now</Link>
            <a class="btn-ghost" href="#how">How it works</a>
            <a class="btn-ghost" href="#pricing">Pricing</a>
          </div>

          <div class="mt-8 grid grid-cols-3 gap-3">
            <div class="card p-4">
              <div class="text-2xl font-semibold">1</div>
              <div class="text-sm opacity-70 mt-1">Single bill</div>
            </div>
            <div class="card p-4">
              <div class="text-2xl font-semibold">2</div>
              <div class="text-sm opacity-70 mt-1">Concierge matching</div>
            </div>
            <div class="card p-4">
              <div class="text-2xl font-semibold">3</div>
              <div class="text-sm opacity-70 mt-1">Managed logistics</div>
            </div>
          </div>
        </div>

        <div class="md:col-span-5" data-aos="fade-left">
          <div class="card p-6">
            <div class="text-sm opacity-70">Try the experience</div>
            <div class="mt-4 space-y-3">
              <div class="card p-4">
                <div class="font-medium">Seller Onboarding</div>
                <p class="text-sm opacity-70 mt-1">Create a story-card listing wizard.</p>
              </div>
              <div class="card p-4">
                <div class="font-medium">Buyer Concierge</div>
                <p class="text-sm opacity-70 mt-1">Describe requirements; get matched options.</p>
              </div>
            </div>
            <div class="mt-5 flex gap-3">
              <Link class="btn-primary" href="/login">Launch portal</Link>
              <Link class="btn-ghost" href="/pricing">View pricing</Link>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="how" class="max-w-6xl mx-auto px-4 py-14">
      <div class="grid md:grid-cols-3 gap-6">
        <div class="card p-6" data-aos="fade-up">
          <div class="text-lg font-semibold">Sell</div>
          <p class="opacity-80 mt-2">Onboard with a guided wizard, pay a small activation fee, and we bring buyers.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="100">
          <div class="text-lg font-semibold">Buy</div>
          <p class="opacity-80 mt-2">Explain what you want, must-haves vs nice-to-haves, and activate concierge sourcing.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="200">
          <div class="text-lg font-semibold">We handle logistics</div>
          <p class="opacity-80 mt-2">Pickup, delivery, sourcing, verification, and a single invoice from the platform.</p>
        </div>
      </div>
    </section>

    <section id="pricing" class="max-w-6xl mx-auto px-4 py-14">
      <div class="flex items-end justify-between gap-6 flex-wrap">
        <div data-aos="fade-up">
          <h2 class="text-3xl font-semibold">Pricing</h2>
          <p class="opacity-80 mt-2">Simple activation fees + transparent platform fees per order.</p>
        </div>
        <Link class="btn-primary" href="/pricing" data-aos="fade-left">Full pricing</Link>
      </div>

      <div class="grid md:grid-cols-3 gap-6 mt-8">
        <div class="card p-6" data-aos="zoom-in">
          <div class="text-sm opacity-70">Seller activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <ul class="text-sm opacity-80 mt-4 space-y-2">
            <li>• Listing verification</li>
            <li>• Matching visibility</li>
            <li>• Concierge support</li>
          </ul>
        </div>
        <div class="card p-6 border-white/20" data-aos="zoom-in" data-aos-delay="100">
          <div class="text-sm opacity-70">Buyer activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <ul class="text-sm opacity-80 mt-4 space-y-2">
            <li>• Matching & sourcing</li>
            <li>• Offer breakdown</li>
            <li>• Priority handling</li>
          </ul>
        </div>
        <div class="card p-6" data-aos="zoom-in" data-aos-delay="200">
          <div class="text-sm opacity-70">Order platform fee</div>
          <div class="text-4xl font-semibold mt-2">X%</div>
          <ul class="text-sm opacity-80 mt-4 space-y-2">
            <li>• Handling + logistics</li>
            <li>• Single invoice</li>
            <li>• Dispute support</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="max-w-6xl mx-auto px-4 py-14">
      <div class="card p-8 flex flex-col md:flex-row md:items-center md:justify-between gap-6" data-aos="fade-up">
        <div>
          <h3 class="text-2xl font-semibold">Ready to try it?</h3>
          <p class="opacity-80 mt-2">Create an account and experience the onboarding flows.</p>
        </div>
        <div class="flex gap-3">
          <Link class="btn-primary" href="/register">Get started</Link>
          <Link class="btn-ghost" href="/faq">Read FAQ</Link>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
VUE

cat > resources/js/Pages/Public/Pricing.vue <<'VUE'
<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">Pricing</h1>
      <p class="opacity-80 mt-3 max-w-2xl" data-aos="fade-up" data-aos-delay="100">
        Transparent activation fees and order fees. Admin can adjust everything in Settings.
      </p>

      <div class="grid md:grid-cols-3 gap-6 mt-10">
        <div class="card p-6" data-aos="fade-up">
          <div class="text-lg font-semibold">Seller Activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <p class="opacity-80 mt-3">Publish + concierge verification pipeline.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="100">
          <div class="text-lg font-semibold">Buyer Activation</div>
          <div class="text-4xl font-semibold mt-2">$4.99</div>
          <p class="opacity-80 mt-3">Matching + optional external sourcing.</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="200">
          <div class="text-lg font-semibold">Order Fee</div>
          <div class="text-4xl font-semibold mt-2">Configurable</div>
          <p class="opacity-80 mt-3">Platform + delivery + taxes in one invoice.</p>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
VUE

cat > resources/js/Pages/Public/FAQ.vue <<'VUE'
<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
const faqs = [
  { q: 'Do users talk directly?', a: 'No. The app is the single point of contact and issues one bill.' },
  { q: 'Can buyers source from the internet?', a: 'Yes if enabled; otherwise internal listings only.' },
  { q: 'What do activation fees cover?', a: 'Verification, concierge handling, and prioritization in matching.' },
]
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">FAQ</h1>
      <div class="mt-10 grid gap-4">
        <div v-for="(f,i) in faqs" :key="i" class="card p-6" data-aos="fade-up" :data-aos-delay="i*80">
          <div class="font-semibold">{{ f.q }}</div>
          <div class="opacity-80 mt-2">{{ f.a }}</div>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
VUE

cat > resources/js/Pages/Public/About.vue <<'VUE'
<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">About</h1>
      <p class="opacity-80 mt-4 max-w-2xl" data-aos="fade-up" data-aos-delay="100">
        ConciergeMarket is a managed marketplace that removes friction: one point of contact, transparent fees, and logistics handled end-to-end.
      </p>
    </section>
  </PublicLayout>
</template>
VUE

cat > resources/js/Pages/Public/Contact.vue <<'VUE'
<script setup>
import PublicLayout from '@/Layouts/PublicLayout.vue'
</script>

<template>
  <PublicLayout>
    <section class="max-w-6xl mx-auto px-4 py-16">
      <h1 class="text-4xl font-semibold" data-aos="fade-up">Contact</h1>
      <div class="grid md:grid-cols-2 gap-6 mt-10">
        <div class="card p-6" data-aos="fade-up">
          <div class="font-semibold">Support</div>
          <p class="opacity-80 mt-2">Email: support@example.com</p>
          <p class="opacity-80">Hours: Mon–Fri</p>
        </div>
        <div class="card p-6" data-aos="fade-up" data-aos-delay="100">
          <div class="font-semibold">Send a message</div>
          <div class="mt-4 space-y-3">
            <input class="input" placeholder="Your email" />
            <textarea class="input" rows="4" placeholder="Message"></textarea>
            <button class="btn-primary">Send</button>
          </div>
          <p class="text-xs opacity-60 mt-3">Hook this to a real form handler (SMTP/support inbox) before production.</p>
        </div>
      </div>
    </section>
  </PublicLayout>
</template>
VUE

echo "==> App portal pages"
cat > resources/js/Pages/App/Dashboard.vue <<'VUE'
<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
</script>

<template>
  <AppLayout>
    <div class="card p-6">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 class="text-2xl font-semibold">Dashboard</h1>
          <p class="opacity-70 mt-1">Your activity, matches, and orders in one place.</p>
        </div>
        <div class="flex gap-3">
          <a class="btn-ghost" href="/sell/wizard">Create listing</a>
          <a class="btn-primary" href="/buy/concierge">Create request</a>
        </div>
      </div>

      <div class="grid md:grid-cols-3 gap-4 mt-6">
        <div class="card p-4">
          <div class="text-sm opacity-70">Matches</div>
          <div class="text-3xl font-semibold mt-2">—</div>
          <div class="text-xs opacity-60 mt-1">Hook to matches API</div>
        </div>
        <div class="card p-4">
          <div class="text-sm opacity-70">Orders</div>
          <div class="text-3xl font-semibold mt-2">—</div>
          <div class="text-xs opacity-60 mt-1">Hook to orders API</div>
        </div>
        <div class="card p-4">
          <div class="text-sm opacity-70">Messages</div>
          <div class="text-3xl font-semibold mt-2">—</div>
          <div class="text-xs opacity-60 mt-1">Single point of contact</div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
VUE

cat > resources/js/Pages/App/Security.vue <<'VUE'
<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
</script>

<template>
  <AppLayout>
    <div class="card p-6">
      <h1 class="text-2xl font-semibold">Profile & Security</h1>
      <p class="opacity-70 mt-1">Manage your account settings securely.</p>

      <div class="grid md:grid-cols-2 gap-4 mt-6">
        <div class="card p-5">
          <div class="font-semibold">Password</div>
          <p class="opacity-70 text-sm mt-1">Use /user/profile to change password (Breeze default).</p>
          <a class="btn-primary mt-4 inline-flex" href="/user/profile">Open Profile</a>
        </div>
        <div class="card p-5">
          <div class="font-semibold">Two-factor auth</div>
          <p class="opacity-70 text-sm mt-1">Add 2FA later via Fortify/Jetstream or a Filament 2FA plugin.</p>
        </div>
      </div>
    </div>
  </AppLayout>
</template>
VUE

cat > resources/js/Pages/App/Notifications.vue <<'VUE'
<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
</script>

<template>
  <AppLayout>
    <div class="card p-6">
      <h1 class="text-2xl font-semibold">Notifications</h1>
      <p class="opacity-70 mt-1">Updates about matches, offers, orders, and delivery.</p>
      <div class="card p-5 mt-6">
        <div class="opacity-70 text-sm">Wire to database notifications later (Laravel Notifications).</div>
      </div>
    </div>
  </AppLayout>
</template>
VUE

echo "==> Onboarding flows (animated stepper styling)"
cat > resources/js/Pages/Seller/Wizard.vue <<'VUE'
<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'

const props = defineProps({ fee: Number, currency: String })
const step = ref(1)
const listingId = ref(null)
const stepsTotal = 6

const form = ref({
  title: '', description: '', category: '', condition: 'used',
  price_min: null, price_max: null, pickup_city: '',
  attributes: {}, photos: [],
})

const progress = computed(() => Math.round((step.value / stepsTotal) * 100))
const canNext = computed(() => step.value === 1 ? (form.value.title && form.value.category) : true)

async function saveDraft() {
  const { data } = await axios.post(route('sell.draft'), { ...form.value, id: listingId.value })
  listingId.value = data.id
}
async function next() { if (!canNext.value) return; await saveDraft(); step.value = Math.min(stepsTotal, step.value + 1) }
function back() { step.value = Math.max(1, step.value - 1) }
async function checkout() { await saveDraft(); router.post(route('sell.checkout', listingId.value)) }
</script>

<template>
  <AppLayout>
    <div class="card p-6 overflow-hidden">
      <div class="flex items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Seller Onboarding</h1>
          <p class="opacity-70 mt-1">A story-card wizard that captures everything we need to sell fast.</p>
        </div>
        <div class="text-sm opacity-70">Step {{ step }} / {{ stepsTotal }}</div>
      </div>

      <div class="mt-5 h-2 bg-zinc-800 rounded">
        <div class="h-2 bg-white rounded transition-all duration-300" :style="{ width: progress + '%' }"></div>
      </div>

      <div class="mt-6 relative">
        <transition name="fade" mode="out-in">
          <div :key="step" class="card p-6">
            <template v-if="step === 1">
              <div class="text-lg font-semibold">What are you selling?</div>
              <div class="mt-4 grid gap-3">
                <input class="input" v-model="form.title" placeholder="e.g., iPhone 14 Pro 256GB" />
                <div class="grid md:grid-cols-2 gap-3">
                  <input class="input" v-model="form.category" placeholder="Category (electronics, furniture...)" />
                  <select class="input" v-model="form.condition">
                    <option value="new">New</option>
                    <option value="like_new">Like new</option>
                    <option value="used">Used</option>
                    <option value="fair">Fair</option>
                  </select>
                </div>
              </div>
            </template>

            <template v-else-if="step === 2">
              <div class="text-lg font-semibold">Tell the story</div>
              <textarea class="input mt-4" rows="6" v-model="form.description"
                        placeholder="Condition notes, accessories, defects..." />
            </template>

            <template v-else-if="step === 3">
              <div class="text-lg font-semibold">Price expectation</div>
              <div class="grid md:grid-cols-2 gap-3 mt-4">
                <input class="input" type="number" v-model.number="form.price_min" placeholder="Min" />
                <input class="input" type="number" v-model.number="form.price_max" placeholder="Max" />
              </div>
              <p class="opacity-70 text-sm mt-2">Used for matching + offer guidance.</p>
            </template>

            <template v-else-if="step === 4">
              <div class="text-lg font-semibold">Pickup area</div>
              <input class="input mt-4" v-model="form.pickup_city" placeholder="City / area" />
              <p class="opacity-70 text-sm mt-2">Exact address confirmed after matching.</p>
            </template>

            <template v-else-if="step === 5">
              <div class="text-lg font-semibold">Quick attributes</div>
              <div class="grid md:grid-cols-2 gap-3 mt-4">
                <input class="input" placeholder="Brand" @input="form.attributes.brand=$event.target.value" />
                <input class="input" placeholder="Model" @input="form.attributes.model=$event.target.value" />
              </div>
            </template>

            <template v-else>
              <div class="text-lg font-semibold">Activate</div>
              <p class="opacity-80 mt-3">
                Activation fee: <span class="font-semibold">{{ (fee/100).toFixed(2) }} {{ currency }}</span>
              </p>
              <button class="btn-primary mt-5" @click="checkout">Pay & Activate</button>
              <p class="text-xs opacity-60 mt-3">After payment, status becomes pending review (admin can approve).</p>
            </template>
          </div>
        </transition>
      </div>

      <div class="flex justify-between mt-6">
        <button class="btn-ghost" @click="back" :disabled="step===1">Back</button>
        <button class="btn-primary" @click="next" v-if="step<stepsTotal" :disabled="!canNext">Continue</button>
      </div>
    </div>

    <style>
    .fade-enter-active,.fade-leave-active{ transition: opacity .2s ease, transform .2s ease; }
    .fade-enter-from,.fade-leave-to{ opacity:0; transform: translateY(6px); }
    </style>
  </AppLayout>
</template>
VUE

cat > resources/js/Pages/Buyer/Concierge.vue <<'VUE'
<script setup>
import AppLayout from '@/Layouts/AppLayout.vue'
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import axios from 'axios'

const props = defineProps({ fee: Number, currency: String })
const step = ref(1)
const requestId = ref(null)
const stepsTotal = 6

const form = ref({
  query: '', category: '', details: '',
  budget_min: null, budget_max: null,
  allow_external_sources: true,
  must_haves: { conditions: [] },
  nice_to_haves: {},
  delivery_city: '',
})

const progress = computed(() => Math.round((step.value / stepsTotal) * 100))
const canNext = computed(() => step.value === 1 ? (form.value.query && form.value.category) : true)

async function saveDraft() {
  const { data } = await axios.post(route('buy.draft'), { ...form.value, id: requestId.value })
  requestId.value = data.id
}
async function next() { if (!canNext.value) return; await saveDraft(); step.value = Math.min(stepsTotal, step.value + 1) }
function back() { step.value = Math.max(1, step.value - 1) }
async function checkout() { await saveDraft(); router.post(route('buy.checkout', requestId.value)) }
</script>

<template>
  <AppLayout>
    <div class="card p-6 overflow-hidden">
      <div class="flex items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Buyer Concierge</h1>
          <p class="opacity-70 mt-1">Describe requirements — we match internal sellers and optionally external sources.</p>
        </div>
        <div class="text-sm opacity-70">Step {{ step }} / {{ stepsTotal }}</div>
      </div>

      <div class="mt-5 h-2 bg-zinc-800 rounded">
        <div class="h-2 bg-white rounded transition-all duration-300" :style="{ width: progress + '%' }"></div>
      </div>

      <div class="mt-6">
        <transition name="fade" mode="out-in">
          <div :key="step" class="card p-6">
            <template v-if="step === 1">
              <div class="text-lg font-semibold">What are you looking for?</div>
              <input class="input mt-4" v-model="form.query" placeholder="e.g., MacBook Pro M2 16GB" />
              <input class="input mt-3" v-model="form.category" placeholder="Category" />
            </template>

            <template v-else-if="step === 2">
              <div class="text-lg font-semibold">Must-haves & nice-to-haves</div>
              <textarea class="input mt-4" rows="5" v-model="form.details" placeholder="Specs, colors, acceptable alternatives..." />
              <p class="text-xs opacity-60 mt-2">This is where a drag-drop UI can be added next.</p>
            </template>

            <template v-else-if="step === 3">
              <div class="text-lg font-semibold">Budget</div>
              <div class="grid md:grid-cols-2 gap-3 mt-4">
                <input class="input" type="number" v-model.number="form.budget_min" placeholder="Min" />
                <input class="input" type="number" v-model.number="form.budget_max" placeholder="Max" />
              </div>
            </template>

            <template v-else-if="step === 4">
              <div class="text-lg font-semibold">Sourcing</div>
              <label class="mt-4 flex items-center gap-3">
                <input type="checkbox" v-model="form.allow_external_sources" />
                <span class="opacity-80">Allow external sourcing (internet)</span>
              </label>
            </template>

            <template v-else-if="step === 5">
              <div class="text-lg font-semibold">Delivery city</div>
              <input class="input mt-4" v-model="form.delivery_city" placeholder="City / area" />
            </template>

            <template v-else>
              <div class="text-lg font-semibold">Activate concierge</div>
              <p class="opacity-80 mt-3">
                Activation fee: <span class="font-semibold">{{ (fee/100).toFixed(2) }} {{ currency }}</span>
              </p>
              <button class="btn-primary mt-5" @click="checkout">Pay & Activate</button>
              <p class="text-xs opacity-60 mt-3">After payment, request becomes Active and matching starts.</p>
            </template>
          </div>
        </transition>
      </div>

      <div class="flex justify-between mt-6">
        <button class="btn-ghost" @click="back" :disabled="step===1">Back</button>
        <button class="btn-primary" @click="next" v-if="step<stepsTotal" :disabled="!canNext">Continue</button>
      </div>
    </div>

    <style>
    .fade-enter-active,.fade-leave-active{ transition: opacity .2s ease, transform .2s ease; }
    .fade-enter-from,.fade-leave-to{ opacity:0; transform: translateY(6px); }
    </style>
  </AppLayout>
</template>
VUE

echo "==> Filament resources generation"
php artisan make:filament-resource SellerListing --generate >/dev/null || true
php artisan make:filament-resource BuyerRequest --generate >/dev/null || true
php artisan make:filament-resource MatchRecord --generate >/dev/null || true
php artisan make:filament-resource Offer --generate >/dev/null || true
php artisan make:filament-resource Order --generate >/dev/null || true
php artisan make:filament-resource Transaction --generate >/dev/null || true
php artisan make:filament-resource Shipment --generate >/dev/null || true
php artisan make:filament-resource Setting --generate >/dev/null || true
php artisan make:filament-resource User --generate >/dev/null || true

echo "==> Seed roles + admin"
if [ ! -f database/seeders/RolesSeeder.php ]; then
  php artisan make:seeder RolesSeeder >/dev/null
fi
cat > database/seeders/RolesSeeder.php <<PHP
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use App\Models\User;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        foreach (['admin','buyer','seller','agent'] as \$r) {
            Role::findOrCreate(\$r);
        }

        \$admin = User::firstOrCreate(
            ['email' => '${ADMIN_EMAIL}'],
            ['name' => 'Admin', 'password' => bcrypt('${ADMIN_PASSWORD}')]
        );
        \$admin->assignRole('admin');
    }
}
PHP

php -r '
$p="database/seeders/DatabaseSeeder.php"; $c=file_get_contents($p);
if (strpos($c,"RolesSeeder")===false) {
  $c=preg_replace("/public function run\\(\\): void\\s*\\{/",
"public function run(): void\n    {\n        \$this->call([\\Database\\Seeders\\RolesSeeder::class]);\n",
$c,1);
}
file_put_contents($p,$c);
'

run_step "Migrate + seed" migrate_seed_step

run_step "Build assets" build_assets_step


echo "==> DONE"
echo "Login: ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}"
echo "Public:   ${APP_URL}/"
echo "Portal:   ${APP_URL}/app/dashboard"
echo "Seller:   ${APP_URL}/sell/wizard"
echo "Buyer:    ${APP_URL}/buy/concierge"
echo "Admin:    ${APP_URL}/admin"
