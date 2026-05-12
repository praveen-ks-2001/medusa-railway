FROM node:22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++ libc6-compat \
    && corepack enable

COPY package.json ./
COPY tsconfig.json ./
COPY medusa-config.ts ./
COPY src ./src

RUN npm install --legacy-peer-deps --no-audit --no-fund

RUN npx medusa build && \
    echo "=== /app contents after build ===" && ls -la /app && \
    echo "=== /app/.medusa contents (if exists) ===" && (ls -la /app/.medusa 2>/dev/null || echo "NO .medusa DIR") && \
    echo "=== /app/dist contents (if exists) ===" && (ls -la /app/dist 2>/dev/null || echo "NO dist DIR")

RUN if [ -d /app/.medusa/server ]; then \
      cd /app/.medusa/server && npm install --omit=dev --no-audit --no-fund && npm cache clean --force; \
    else \
      echo "ERROR: .medusa/server not produced by medusa build" && exit 1; \
    fi


FROM node:22-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache tini libc6-compat curl

COPY --from=builder /app/.medusa /app/.medusa
COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh \
    && mkdir -p /app/.medusa/server/static

ENV NODE_ENV=production
ENV PORT=9000

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:${PORT:-9000}/health" || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/start.sh"]
