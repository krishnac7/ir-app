# ── Stage 1: build Flutter web ──────────────────────────────────────────────
FROM debian:bookworm-slim AS builder

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
ENV FLUTTER_ROOT=$FLUTTER_HOME

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates unzip xz-utils git \
    && rm -rf /var/lib/apt/lists/*

# Download Flutter SDK as tarball (avoids git depth/chown issues in rootless builds)
RUN curl -fsSL \
      https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.4-stable.tar.xz \
      -o /tmp/flutter.tar.xz \
    && mkdir -p /opt \
    && tar -xJf /tmp/flutter.tar.xz -C /opt --no-same-owner \
    && rm /tmp/flutter.tar.xz \
    && flutter config --no-analytics \
    && flutter config --enable-web

WORKDIR /app
COPY . .

RUN flutter pub get \
 && flutter build web --release

# ── Stage 2: serve with nginx ────────────────────────────────────────────────
FROM nginx:1.27-alpine

RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
