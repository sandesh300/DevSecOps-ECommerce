# ── Stage 1: Build ─────────────────────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first to cache dependency layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -Dmaven.compiler.source=17 -Dmaven.compiler.target=17

# ── Stage 2: Runtime ───────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS runtime

# Install security updates
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache curl wget && \
    rm -rf /var/cache/apk/*

# Create non-root user/group — UID/GID must match runAsUser: 1001 in deployment.yaml
RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Copy artifact from builder
COPY --from=builder /app/target/*.jar app.jar

# FIX: chmod 550 on /app means appuser can read+execute the dir (list files) ✓
#      chmod 440 on app.jar means appuser can READ the jar ✓
#      Java does NOT need execute bit on the jar file — it reads it as a zip.
#      BUT: fsGroup in K8s pod spec will set group ownership on mounted volumes,
#      not on image files. We must ensure appuser (1001) owns the jar at build time.
RUN chown -R appuser:appgroup /app && \
    chmod 550 /app && \
    chmod 440 /app/app.jar

# Drop to non-root user
USER appuser

EXPOSE 8080

# Health check using actuator endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# JVM hardening flags
ENTRYPOINT ["java", \
  "-Xms256m", "-Xmx512m", \
  "-XX:+UseContainerSupport", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-Dspring.profiles.active=prod", \
  "-jar", "app.jar"]