![Medusa.js v2 logo](https://cdn.sanity.io/images/5a711ubd/production/73ede9fccb57607fd0c48863b88a9ad4965fef18-1000x420.webp?w=1200)

# Deploy and Host Medusa.js v2

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/medusa?referralCode=QXdhdr)

Medusa.js v2 is an MIT-licensed, open-source headless commerce engine that gives JavaScript developers full ownership of the storefront, checkout, admin, and underlying data — with no per-sale fees, no feature paywalls, and no vendor lock-in. It's the open-source alternative to Shopify and the REST-first answer to Saleor and Vendure, with a modular Node.js + TypeScript backend that drops into any Next.js, Remix, or native frontend.

This template lets you deploy Medusa.js v2 on Railway in one click, with managed Postgres and Redis pre-wired, JWT and cookie secrets auto-generated, CORS configured for your Railway domain, and the initial admin user bootstrapped on first boot. The backend ships from a public custom Dockerfile (`praveen-ks-2001/medusa-railway`) — fork it to add modules, custom routes, subscribers, or workflows, then auto-deploy on every `git push`.

![Medusa.js v2 Railway architecture](https://res.cloudinary.com/asset-cloudinary/image/upload/v1778613776/4de15b50-2c72-41f4-8b95-00035a38a968.png)

## Getting Started with Medusa.js v2 on Railway

Click **Deploy**, set `MEDUSA_ADMIN_EMAIL` and `MEDUSA_ADMIN_PASSWORD`, and wait roughly 30 seconds for the build to finish and the healthcheck on `/health` to go green. The admin UI is at `https://your-domain.up.railway.app/app` — log in with the credentials you just provided. First, head to **Settings → Regions** to add your selling regions and currencies, then **Settings → Publishable API Keys** to grab the auto-created key your storefront needs. From there, **Products → Add Product** and you're ready to wire up any frontend.

![Medusa.js v2 dashboard screenshot](https://res.cloudinary.com/asset-cloudinary/image/upload/v1778613742/2925d054-ac01-4175-9b19-fd1eae9054f2.png)

![Medusa.js v2 dashboard screenshot](https://medusajs.com/_next/static/media/admin.299d3bc5.png)

![Medusa.js v2 dashboard screenshot](https://medusajs.com/_next/static/media/modules.9b6127fc.png)

## About Hosting Medusa.js v2

Medusa.js v2 is a TypeScript-first commerce engine that exposes Store, Admin, and Workflow APIs you build any frontend on. Each commerce primitive (cart, order, payment, fulfillment, customer, inventory) is an independent, swappable module.

Key features:
- **Modular core** — products, carts, orders, promotions, taxes, inventory, fulfillment as separate modules
- **Workflow engine** — durable, retryable, Redis-backed commerce workflows with rollback
- **Admin dashboard** — built in at `/app`, no separate service to host
- **B2B, D2C, marketplace, POS starters** — same engine, different starter
- **First-class integrations** — Stripe, Resend, SendGrid, MinIO, Meilisearch

The `medusa` service talks to Postgres and Redis over Railway's private network.

## Why Deploy Medusa.js v2 on Railway

- One-click deploy with Postgres + Redis pre-wired
- Public GitHub repo to fork — full backend customization
- Auto-deploy on `git push`, managed TLS, custom domains
- Generated secrets and cross-service refs — zero `.env` editing
- Private networking and managed backups out of the box

## Common Use Cases

- **D2C storefronts** — Medusa backend + Next.js storefront on Vercel or Railway calling the Store API
- **B2B portals** — company accounts, quote requests, custom price lists, net-30 invoicing via Medusa's B2B starter
- **Headless replatform** — drop-in replacement for Shopify or Magento behind your existing checkout UI
- **Multi-vendor marketplaces** — Mercur (mercurjs.com) is an open-source marketplace framework built on Medusa v2

## Dependencies for Medusa.js v2

- **Postgres** — primary commerce store (Railway-managed)
- **Redis** — cache + event bus + workflow engine (Railway-managed)
- **Node.js 22** — runtime, Alpine base image
- **Medusa 2.13.6** — pinned in `package.json`

### Environment Variables Reference

| Variable | Description | Required |
|----------|-------------|----------|
| `MEDUSA_ADMIN_EMAIL` | Initial admin login email | Yes |
| `MEDUSA_ADMIN_PASSWORD` | Initial admin password (auto-generated) | Yes |
| `JWT_SECRET` | Signs admin and customer JWTs | Yes (auto) |
| `COOKIE_SECRET` | Signs admin session cookies | Yes (auto) |
| `DATABASE_URL` | Postgres connection string | Yes (auto-wired) |
| `REDIS_URL` | Redis connection (must include `?family=0` on Railway) | Yes (auto-wired) |
| `STORE_CORS` / `ADMIN_CORS` / `AUTH_CORS` | Your Railway public domain (CORS allowlist for the storefront, admin, and auth APIs) | Yes (auto) |
| `BACKEND_URL` | Only set if the admin UI is served from a different domain than the API. Empty by default — admin uses same-origin relative URLs. | Optional |
| `MEDUSA_WORKER_MODE` | `shared` (default), `server`, or `worker` | Optional |
| `DISABLE_MEDUSA_ADMIN` | Set `true` to disable the admin UI | Optional |

### Deployment Dependencies

- **Build output**: `/app/.medusa/server/` — canonical Medusa path; do **not** change `tsconfig.outDir` to `dist`
- **GitHub repo**: https://github.com/praveen-ks-2001/medusa-railway
- **Medusa source**: https://github.com/medusajs/medusa
- **Official docs**: https://docs.medusajs.com

## Minimum Hardware Requirements for Medusa.js v2

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM (medusa) | 1 GB | 2 GB+ (admin build is RAM-hungry) |
| CPU (medusa) | 0.5 vCPU | 1+ vCPU |
| Postgres | 256 MB / 1 GB disk | 1 GB / 10 GB+ |
| Redis | 256 MB | 512 MB+ |
| Node.js | 20+ | 22 LTS |

## How to Self-Host Medusa.js v2

Outside Railway, build the same image and run it with Docker. Clone the template repo:

```
git clone https://github.com/praveen-ks-2001/medusa-railway.git
cd medusa-railway
docker build -t medusa-railway .
```

Then run with Postgres + Redis side-cars:

```
docker run -d --name pg -e POSTGRES_PASSWORD=secret postgres:16
docker run -d --name redis redis:7
docker run -d --name medusa --link pg --link redis -p 9000:9000 \
  -e DATABASE_URL=postgres://postgres:secret@pg:5432/postgres \
  -e REDIS_URL=redis://redis:6379 \
  -e JWT_SECRET=$(openssl rand -hex 32) \
  -e COOKIE_SECRET=$(openssl rand -hex 32) \
  -e MEDUSA_ADMIN_EMAIL=admin@example.com \
  -e MEDUSA_ADMIN_PASSWORD=$(openssl rand -hex 16) \
  medusa-railway
```

Admin UI at `http://localhost:9000/app` once `/health` returns 200.

## How Much Does Medusa.js v2 Cost?

Medusa.js v2 is free and open-source under the MIT license — no license fees, no per-sale cut, no feature paywalls. On Railway you pay only for infrastructure: a small live store typically costs $5–$15/month, a steady mid-traffic store $25–$60/month. Compare that to Shopify's $39–$399/month plus 0.5–2 % of every sale, or any fully managed commerce platform where you don't own the data model.

## Medusa.js v2 vs Shopify vs Saleor vs Vendure

| | Medusa.js v2 | Shopify | Saleor | Vendure |
|---|---|---|---|---|
| License | MIT (OSS) | Proprietary SaaS | BSD-3 | MIT |
| Per-sale fee | None | 0.5–2 % | None | None |
| Stack | Node.js / TS | Closed | Python / Django / GraphQL | TypeScript / GraphQL |
| API style | REST + workflows | REST + GraphQL | GraphQL only | GraphQL only |
| Self-host complexity | Low (this template) | N/A | High (typically K8s) | Medium |

Medusa wins for JavaScript teams that want REST + typed workflows over GraphQL, full backend control, and a one-click deploy path. Saleor is stronger for GraphQL-native teams; Vendure for pure TypeScript GraphQL stacks.

## FAQ

**What is Medusa.js v2?**
An MIT-licensed, open-source headless commerce platform written in TypeScript. It exposes Store, Admin, and Workflow APIs you build any frontend on — Next.js, Remix, native mobile, POS — without per-sale fees or vendor lock-in.

**What does this Railway template deploy?**
Three services: the `medusa` Node.js backend (API + admin + worker in shared mode), Railway-managed Postgres for the primary store, and Railway-managed Redis for cache, event bus, and workflow engine. Public domain, healthchecks, secrets, and CORS are all pre-wired.

**Why are Postgres and Redis both required?**
Postgres is the primary commerce store — products, customers, orders, carts. Redis backs the workflow engine (durable workflows + retries), the cache, and the event bus. Both are mandatory for Medusa v2 in production.

**The Store API returns "Publishable API key required" — is something broken?**
No — Medusa v2 protects the storefront API by design. A default publishable key is auto-created on first boot. Find it under **Admin → Settings → Publishable API Keys** and pass it as `x-publishable-api-key` on every Store API call.

**Can I customize the backend?**
Yes. Fork `https://github.com/praveen-ks-2001/medusa-railway`, drop code in `src/api/`, `src/modules/`, `src/subscribers/`, or `src/workflows/`, push to GitHub, and Railway auto-deploys on every commit.

**How do I add Stripe, Resend, MinIO, or Meilisearch?**
All four are first-class Medusa module providers. Set their env vars on the `medusa` service, register the module in `medusa-config.ts` in your fork, push. The `rpuls/medusajs-2.0-for-railway-boilerplate` config shows the conditional-module pattern.

**Can I split API and worker into separate services for higher traffic?**
Yes. Duplicate the `medusa` service, set `MEDUSA_WORKER_MODE=server` on one and `MEDUSA_WORKER_MODE=worker` on the other — both pointing at the same GitHub repo and sharing Postgres + Redis.
