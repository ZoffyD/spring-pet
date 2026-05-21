# --- Build stage: compile and package the app ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
# Copy only what the build needs (keeps the image cache-friendly and the
# build context small; node_modules/target are excluded via .dockerignore).
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# --- Run stage: small JRE image with just the jar ---
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
