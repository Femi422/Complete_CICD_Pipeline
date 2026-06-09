# Stage 1 — build/copy static assets
FROM node:20-alpine AS builder
WORKDIR /app
COPY src/ ./src/
COPY nginx.conf .

# Stage 2 — serve with Nginx
FROM nginx:1.25-alpine
COPY --from=builder /app/src /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

# Expose Prometheus scrape port for nginx-prometheus-exporter
EXPOSE 80 9113
HEALTHCHECK --interval=30s --timeout=5s \
  CMD wget -qO- http://localhost/health || exit 1
