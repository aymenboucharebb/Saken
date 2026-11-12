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

# Do NOT run migrations or seeders here (manual on Render).
if [ -f artisan ]; then
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
