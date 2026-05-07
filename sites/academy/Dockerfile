# Build stage
FROM oven/bun:1.3 AS builder

WORKDIR /app

# Arguments
ARG PUBLIC_APP_VERSION
ENV PUBLIC_APP_VERSION=$PUBLIC_APP_VERSION

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

# Runtime stage
# Mirrors landing's pattern: TLS terminated inside the container on port 443.
# In production the bastion deploy script mounts the real LE cert read-only over
# /etc/nginx/certs (the self-signed cert below is the local-dev fallback).
FROM nginx:alpine

# openssl for the self-signed fallback cert (dev only; prod overrides via volume mount)
RUN apk add --no-cache openssl

# Generate self-signed certificate (used in local Docker runs without a real cert mounted)
RUN mkdir -p /etc/nginx/certs
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/privkey.pem \
    -out /etc/nginx/certs/fullchain.pem \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Internal/OU=IT/CN=localhost"

# Copy nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
