# ── Stage 1: Build React ───────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first for layer caching
COPY package*.json ./

# Use ci for reproducible installs; audit for security awareness
RUN npm ci --audit

COPY . .

# Production build
RUN npm run build

# ── Stage 2: Serve with hardened Nginx ─────────────────────────────────────────
FROM nginx:1.25-alpine AS runtime

# Install security updates
RUN apk update && apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

# Remove default nginx content and configs
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/*

# Copy built React app
COPY --from=builder /app/build /usr/share/nginx/html

# Copy hardened nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create non-root user for nginx
RUN addgroup -S nginxgroup && adduser -S nginxuser -G nginxgroup && \
    chown -R nginxuser:nginxgroup /usr/share/nginx/html && \
    chown -R nginxuser:nginxgroup /var/cache/nginx && \
    chown -R nginxuser:nginxgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginxuser:nginxgroup /var/run/nginx.pid

USER nginxuser

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]