#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"

# Inject Render PORT into Nginx (template uses ${PORT}).
envsubst '${PORT}' < /etc/nginx/sites-available/default > /tmp/nginx-default.conf
cp /tmp/nginx-default.conf /etc/nginx/sites-available/default

mkdir -p \
  storage/framework/cache/data \
  storage/framework/sessions \
  storage/framework/views \
  storage/logs \
  storage/app/private/receipts/payments \
  storage/app/public \
  bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rwx storage bootstrap/cache || true

# Fail fast if APP_KEY is missing or invalid (AES-256 needs 32 bytes after base64 decode).
if [ -z "${APP_KEY:-}" ]; then
  echo "ERROR: APP_KEY is not set. Add a valid Laravel key in Render Environment." >&2
  exit 1
fi

# Normalize + validate APP_KEY.
# IMPORTANT: bash `set -e` does NOT abort on failed command-substitution inside
# `export VAR="$(...)"`. Always check the exit code explicitly with `|| exit 1`.
normalize_app_key() {
  php -r '
$key = getenv("APP_KEY") ?: "";

// Strip UTF-8 BOM and all whitespace (including NBSP / zero-width).
$key = preg_replace("/^\xEF\xBB\xBF/u", "", $key) ?? $key;
$key = preg_replace("/[\x{00A0}\x{200B}\x{FEFF}\s]+/u", "", $key) ?? $key;
$key = trim($key, "\"'\''");

if ($key === "") {
    fwrite(STDERR, "ERROR: APP_KEY is empty after normalization.\n");
    exit(1);
}

if (str_starts_with($key, "base64:")) {
    $payload = substr($key, 7);
    // Some hosts turn "+" into " " inside env values.
    $payload = str_replace(" ", "+", $payload);
    // Keep only valid base64 alphabet (drops accidental pasted junk).
    $payload = preg_replace("/[^A-Za-z0-9+\/=]/", "", $payload) ?? $payload;
    $key = "base64:" . $payload;

    $decoded = base64_decode($payload, true);
    if ($decoded === false || strlen($decoded) !== 32) {
        $expected = 7 + 44; // "base64:" + 32-byte base64 payload
        fwrite(STDERR, "ERROR: APP_KEY invalid for AES-256-CBC.\n");
        fwrite(STDERR, "  Got length=" . strlen($key) . " (payload=" . strlen($payload) . "). Expected length={$expected} (payload=44).\n");
        fwrite(STDERR, "  Preview: " . substr($key, 0, 16) . "...\n");
        fwrite(STDERR, "Generate with: php artisan key:generate --show\n");
        fwrite(STDERR, "PowerShell check: (php artisan key:generate --show).Length  # must be {$expected}\n");
        fwrite(STDERR, "Paste exactly, no quotes. Prefer a key without + if issues persist.\n");
        exit(1);
    }
} else {
    // Raw binary / plain string key (rare).
    if (strlen($key) !== 32) {
        fwrite(STDERR, "ERROR: raw APP_KEY must be exactly 32 bytes. Got length=" . strlen($key) . ".\n");
        exit(1);
    }
}

echo $key;
'
}

# Explicit failure propagation (do not rely on set -e alone here).
NORMALIZED_APP_KEY="$(normalize_app_key)" || {
  echo "ERROR: APP_KEY validation failed — refusing to start." >&2
  exit 1
}

if [ -z "${NORMALIZED_APP_KEY}" ]; then
  echo "ERROR: APP_KEY empty after validation — refusing to start." >&2
  exit 1
fi

export APP_KEY="${NORMALIZED_APP_KEY}"
echo "APP_KEY OK (32 bytes, string_len=${#APP_KEY})."

# Do NOT run migrations or seeders here (manual on Render).
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Ensure the cached config actually contains a usable key (catches empty-key cache).
# Must load Composer autoload first: cached config may reference package enums/classes (e.g. Scramble).
php -r '
require "vendor/autoload.php";
$cfgFile = "bootstrap/cache/config.php";
if (!is_file($cfgFile)) {
    fwrite(STDERR, "ERROR: bootstrap/cache/config.php missing after config:cache.\n");
    exit(1);
}
$cfg = require $cfgFile;
$key = $cfg["app"]["key"] ?? "";
if (!is_string($key) || $key === "") {
    fwrite(STDERR, "ERROR: cached config app.key is empty. Check APP_KEY on Render.\n");
    exit(1);
}
$payload = str_starts_with($key, "base64:") ? substr($key, 7) : $key;
$decoded = str_starts_with($key, "base64:")
    ? base64_decode($payload, true)
    : $key;
if ($decoded === false || strlen($decoded) !== 32) {
    fwrite(STDERR, "ERROR: cached config app.key is invalid for AES-256-CBC.\n");
    exit(1);
}
echo "Cached config app.key OK.\n";
'

# Apply pending migrations (needed on free Render without Shell).
# Safe to re-run: already-applied migrations are skipped. Never seeds demo data.
echo "Running migrations..."
php artisan migrate --force
echo "Migrations OK."

# Optional first admin (set ADMIN_EMAIL + ADMIN_PASSWORD on Render once, then remove password).
if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
  php -r '
require "vendor/autoload.php";
$app = require "bootstrap/app.php";
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$email = getenv("ADMIN_EMAIL") ?: "";
$password = getenv("ADMIN_PASSWORD") ?: "";
$name = getenv("ADMIN_NAME") ?: "Admin";
if ($email === "" || $password === "") {
    fwrite(STDERR, "ERROR: ADMIN_EMAIL/ADMIN_PASSWORD empty.\n");
    exit(1);
}
$user = App\Models\User::query()->updateOrCreate(
    ["email" => $email],
    [
        "name" => $name,
        "password" => $password,
        "role" => "admin",
        "email_verified_at" => now(),
    ],
);
echo "Admin ready: {$user->email}\n";
'
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
