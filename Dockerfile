# Dockerfile — use Debian-slim for reliable TLS support
FROM node:18-slim AS builder
WORKDIR /app

# Install build deps if any (optional) — keep image small
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --legac
COPY . .

FROM node:18-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3300
CMD ["npm", "start"]
