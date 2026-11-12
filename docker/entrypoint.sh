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

php -r '
$key = getenv("APP_KEY") ?: "";
if (str_starts_with($key, "base64:")) {
    $decoded = base64_decode(substr($key, 7), true);
} else {
    $decoded = $key;
}
if ($decoded === false || strlen($decoded) !== 32) {
    fwrite(STDERR, "ERROR: APP_KEY has incorrect length for AES-256-CBC (need 32 bytes after decode).\n");
    exit(1);
}
echo "APP_KEY OK (32 bytes).\n";
'

# Do NOT run migrations or seeders here (manual on Render).
# Cache config with real env so FPM serves a valid baked config even if env were cleared.
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
