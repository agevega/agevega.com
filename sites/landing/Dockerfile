# Build stage
FROM oven/bun:1.3 AS builder

WORKDIR /app

# Arguments
ARG PUBLIC_APP_VERSION
ARG PUBLIC_API_URL
ENV PUBLIC_APP_VERSION=$PUBLIC_APP_VERSION
ENV PUBLIC_API_URL=$PUBLIC_API_URL

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

# Runtime stage
# nginx-unprivileged runs as user nginx (uid 101) and listens on unprivileged
# ports — in-container 80/443 become 8080/8443 (host port mapping is unchanged).
FROM nginxinc/nginx-unprivileged:alpine

# Build-time setup needs root; the final USER below drops back to nginx.
USER root

# Install curl for IMDS fetching and openssl for self-signed certs
RUN apk add --no-cache curl openssl

# Generate self-signed certificate. Must be readable by uid 101 at runtime.
RUN mkdir -p /etc/nginx/certs
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/privkey.pem \
    -out /etc/nginx/certs/fullchain.pem \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Internal/OU=IT/CN=localhost" && \
    chown -R nginx:nginx /etc/nginx/certs

# Copy static config and entrypoint
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Copy built application
COPY --from=builder /app/dist /usr/share/nginx/html
RUN chown nginx:nginx /usr/share/nginx/html

USER nginx

EXPOSE 8443

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD printf 'GET /health HTTP/1.0\r\nHost: localhost\r\n\r\n' \
    | openssl s_client -quiet -verify_quiet -connect localhost:8443 2>/dev/null \
    | grep -q '200 OK' || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
