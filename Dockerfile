# ==========================
# Stage 1: Build
# ==========================
FROM gradle:8.10.0-jdk21 AS builder

WORKDIR /app

# Copy Gradle files first (better caching)
COPY build.gradle settings.gradle ./
COPY gradle gradle
COPY gradlew .

RUN chmod +x gradlew

# Download dependencies
RUN ./gradlew dependencies --no-daemon || true

# Copy source code
COPY src src

# Build application
RUN ./gradlew clean bootJar --no-daemon

# ==========================
# Stage 2: Runtime
# ==========================
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]