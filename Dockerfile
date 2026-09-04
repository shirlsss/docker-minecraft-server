# 1. Base image: using eclipse-temurin, for lightweight alpine with JRE preinstalled
FROM eclipse-temurin:21-jre-alpine

#2. Create and set working directory
WORKDIR /minecraft-server

#3. Copy the included server.jar MC server file to /minecraft-server
COPY server.jar .

#4. Run commands, e.g.: eula=true
RUN echo "eula=true" > eula.txt
