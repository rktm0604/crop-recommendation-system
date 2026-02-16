# Smart Crop Recommendation System
# Build JAR on your machine first (avoids Docker Desktop pipe timeout on Windows).
# Then: docker compose up -d --build

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -g 1000 appgroup && adduser -u 1000 -G appgroup -D appuser

# Copy JAR built locally (run: mvn clean package -DskipTests)
COPY target/crop-recommendation-system-*.jar app.jar

USER appuser
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
