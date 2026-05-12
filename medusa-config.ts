import { loadEnv, defineConfig, Modules } from "@medusajs/framework/utils"

loadEnv(process.env.NODE_ENV || "production", process.cwd())

const REDIS_URL = process.env.REDIS_URL
const hasRedis = Boolean(REDIS_URL)

const modules: Record<string, any> = {}

if (hasRedis) {
  modules[Modules.CACHE] = {
    resolve: "@medusajs/medusa/cache-redis",
    options: { redisUrl: REDIS_URL },
  }
  modules[Modules.EVENT_BUS] = {
    resolve: "@medusajs/medusa/event-bus-redis",
    options: { redisUrl: REDIS_URL },
  }
  modules[Modules.WORKFLOW_ENGINE] = {
    resolve: "@medusajs/medusa/workflow-engine-redis",
    options: { redis: { url: REDIS_URL } },
  }
}

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: REDIS_URL,
    workerMode: (process.env.MEDUSA_WORKER_MODE as
      | "shared"
      | "worker"
      | "server") || "shared",
    http: {
      storeCors: process.env.STORE_CORS || "",
      adminCors: process.env.ADMIN_CORS || "",
      authCors: process.env.AUTH_CORS || "",
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    },
  },
  admin: {
    backendUrl: process.env.BACKEND_URL || "http://localhost:9000",
    disable: process.env.DISABLE_MEDUSA_ADMIN === "true",
  },
  modules,
})
