# ---------- BUILD STAGE ----------
FROM node:20-alpine3.20 AS builder

WORKDIR /app

RUN apk update && apk upgrade --no-cache

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ---------- RUNTIME STAGE ----------
FROM node:20-alpine3.20

WORKDIR /app

RUN apk update && apk upgrade --no-cache \
    && addgroup -S app \
    && adduser -S app -G app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./next.config.ts

USER app

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:3000 || exit 1

CMD ["npm", "start"]

