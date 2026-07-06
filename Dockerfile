# ── Stage 1: build Flutter web ──────────────────────────────────────────────
FROM debian:bookworm-slim AS builder

ARG FLUTTER_VERSION=3.32.4
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
# Suppress Flutter analytics and root warnings
ENV FLUTTER_ANALYTICS_DISABLE=1
ENV PUB_HOSTED_URL=https://pub.dartlang.org

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl git ca-certificates unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK (web only — skip android/gradle precache)
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
      https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter config --no-analytics \
    && flutter config --enable-web \
    && flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows --no-fuchsia

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
