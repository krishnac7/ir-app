# ── Stage 1: build Flutter web ──────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.44.4 AS builder

WORKDIR /app

# Copy source
COPY . .

# Enable web and build
RUN flutter config --enable-web \
 && flutter pub get \
 && flutter build web --release

# ── Stage 2: serve with nginx ────────────────────────────────────────────────
FROM nginx:1.27-alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built web assets
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
