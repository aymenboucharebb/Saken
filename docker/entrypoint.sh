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

# Normalize APP_KEY for Render/env quirks: trim, strip quotes, restore '+' mangled as spaces.
export APP_KEY="$(php -r '
$key = getenv("APP_KEY") ?: "";
$key = trim($key);
$key = trim($key, "\"'\''");
if (str_starts_with($key, "base64:")) {
    $payload = substr($key, 7);
    // Some hosts turn "+" into " " inside env values.
    $payload = str_replace(" ", "+", $payload);
    $key = "base64:" . $payload;
}
$decoded = str_starts_with($key, "base64:")
    ? base64_decode(substr($key, 7), true)
    : $key;
if ($decoded === false || strlen($decoded) !== 32) {
    $preview = substr($key, 0, 12) . "...(len=" . strlen($key) . ")";
    fwrite(STDERR, "ERROR: APP_KEY invalid for AES-256-CBC. Got {$preview}\n");
    fwrite(STDERR, "Generate with: php artisan key:generate --show\n");
    fwrite(STDERR, "Paste exactly, no quotes. Prefer a key without + if issues persist.\n");
    exit(1);
}
echo $key;
')"

echo "APP_KEY OK (32 bytes)."

# Do NOT run migrations or seeders here (manual on Render).
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
