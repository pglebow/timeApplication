# Dockerfile for Spring Boot App
FROM eclipse-temurin:21-jdk-alpine

ARG JAR_FILE=target/timeApplication-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-jar","/app.jar"]