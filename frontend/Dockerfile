# ── Stage 1: Build React App ────────────────────────────────────────────────
# FIX v2: nginx.conf already listens on 8080; no sed needed.
# FIX: pid file moved to /tmp so nginx can run as UID 101 (non-root).
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production=false

COPY . .
RUN npm run build

# ── Stage 2: Serve with hardened Nginx ──────────────────────────────────────
FROM nginx:1.25-alpine AS runtime

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy nginx.conf that already has "listen 8080" — no sed patch needed
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built React app
COPY --from=builder /app/build /usr/share/nginx/html

# Move nginx pid file to /tmp so non-root user can write it
RUN sed -i 's|/var/run/nginx.pid|/tmp/nginx.pid|g' /etc/nginx/nginx.conf

# Fix ownership — nginx user (UID 101) must own all writable paths
RUN chown -R nginx:nginx \
        /usr/share/nginx/html \
        /var/cache/nginx \
        /var/log/nginx && \
    chmod -R 755 /var/cache/nginx /var/log/nginx /usr/share/nginx/html

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["nginx", "-g", "daemon off;"]