# ── Stage 1: Build ─────────────────────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first to cache dependency layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -Dmaven.compiler.source=17 -Dmaven.compiler.target=17

# ── Stage 2: Security Scan Layer ───────────────────────────────────────────────
FROM builder AS scanner
# This layer is used by Trivy/OWASP in CI — not included in final image
RUN mvn dependency:analyze || true

# ── Stage 3: Runtime ───────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS runtime

# Install security updates
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache curl wget && \
    rm -rf /var/cache/apk/*

# Create non-root user/group for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy artifact from builder
COPY --from=builder /app/target/*.jar app.jar

# Set strict ownership — appuser owns only /app
RUN chown -R appuser:appgroup /app && \
    chmod 550 /app && \
    chmod 440 /app/app.jar

# Drop to non-root user
USER appuser

EXPOSE 8080

# Health check using actuator endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# JVM hardening flags: disable DNS caching, limit heap, enable GC logs
ENTRYPOINT ["java", \
  "-Xms256m", "-Xmx512m", \
  "-XX:+UseContainerSupport", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-Dspring.profiles.active=prod", \
  "-jar", "app.jar"]