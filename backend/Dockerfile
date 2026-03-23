# ── Stage 1: Build ─────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
# Copy pom.xml first to cache dependencies layer
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests
# ── Stage 2: Runtime ────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS runtime
# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
# Set ownership
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 8080
# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
 CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-jar", "app.jar"]
