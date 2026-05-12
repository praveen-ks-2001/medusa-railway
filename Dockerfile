FROM node:22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++ libc6-compat \
    && corepack enable

COPY package.json ./
COPY tsconfig.json ./
COPY medusa-config.ts ./
COPY src ./src

RUN npm install --legacy-peer-deps --no-audit --no-fund

ARG CACHE_BUST=v4
RUN echo "BUST=${CACHE_BUST}" && npx medusa build && \
    echo "=== /app/dist deep listing ===" && \
    find /app/dist -maxdepth 5 -type f 2>&1 | head -100 && \
    echo "=== /app/dist package.json ===" && cat /app/dist/package.json && \
    echo "=== checking start script source ===" && (cat /app/dist/medusa-config.js | head -20 || true)

# dist/ is the actual build output (Medusa 2.13.6 with TS config)
RUN cd /app/dist && npm install --omit=dev --no-audit --no-fund && npm cache clean --force


FROM node:22-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache tini libc6-compat curl

COPY --from=builder /app/dist /app/dist
COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh \
    && mkdir -p /app/dist/static

ENV NODE_ENV=production
ENV PORT=9000

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:${PORT:-9000}/health" || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/start.sh"]
