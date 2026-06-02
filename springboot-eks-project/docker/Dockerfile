# ──────────────────────────────────────────────
# Stage 1 — Build
# ──────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests -B

# ──────────────────────────────────────────────
# Stage 2 — Extract Spring Boot layers
# ──────────────────────────────────────────────
FROM eclipse-temurin:21-jre AS extractor
WORKDIR /extract
COPY --from=builder /build/target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# ──────────────────────────────────────────────
# Stage 3 — Runtime
# ──────────────────────────────────────────────
FROM eclipse-temurin:21-jre-jammy

ARG BUILD_DATE
ARG VCS_REF
ARG APP_VERSION=1.0.0

LABEL org.opencontainers.image.title="springboot-app" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}"

# Non-root user
RUN groupadd -g 1001 app && useradd -u 1001 -g app -s /bin/bash -m app

WORKDIR /app

# Copy layers in cache-friendly order
COPY --from=extractor /extract/dependencies/ ./
COPY --from=extractor /extract/spring-boot-loader/ ./
COPY --from=extractor /extract/snapshot-dependencies/ ./
COPY --from=extractor /extract/application/ ./

RUN chown -R app:app /app
USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:InitialRAMPercentage=50.0 \
               -XX:+UseG1GC \
               -XX:+ExitOnOutOfMemoryError \
               -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
