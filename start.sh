#!/bin/sh
set -e

cd /app/dist

echo "[start] Running database migrations..."
npx medusa db:migrate || {
  echo "[start] db:migrate failed" >&2
  exit 1
}

if [ -n "${MEDUSA_ADMIN_EMAIL}" ] && [ -n "${MEDUSA_ADMIN_PASSWORD}" ]; then
  echo "[start] Ensuring admin user ${MEDUSA_ADMIN_EMAIL} exists..."
  npx medusa user --email "${MEDUSA_ADMIN_EMAIL}" --password "${MEDUSA_ADMIN_PASSWORD}" || \
    echo "[start] Admin user already exists or could not be created (continuing)"
fi

echo "[start] Launching Medusa (mode=${MEDUSA_WORKER_MODE:-shared}, port=${PORT:-9000})..."
exec npx medusa start
