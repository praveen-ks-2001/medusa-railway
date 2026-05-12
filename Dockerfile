FROM node:22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++ libc6-compat \
    && corepack enable

COPY package.json ./
COPY tsconfig.json ./
COPY medusa-config.ts ./
COPY src ./src

RUN npm install --legacy-peer-deps --no-audit --no-fund

# Force fresh build run to see diagnostics
ARG CACHE_BUST=v3
RUN echo "BUST=${CACHE_BUST}" && npx medusa build 2>&1 | tee /tmp/build.log; \
    echo "=== EXIT CODE: $? ===" && \
    echo "=== /app contents ===" && ls -la /app && \
    echo "=== /app/.medusa tree ===" && (find /app/.medusa -maxdepth 3 2>&1 | head -50 || echo "NO .medusa") && \
    echo "=== /app/dist tree ===" && (find /app/dist -maxdepth 2 2>&1 | head -30 || echo "NO dist")

# Continue only if .medusa/server exists
RUN test -d /app/.medusa/server && cd /app/.medusa/server && npm install --omit=dev --no-audit --no-fund && npm cache clean --force || (echo "BUILD INCOMPLETE: .medusa/server missing" && exit 1)


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
