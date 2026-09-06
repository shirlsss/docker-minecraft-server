# Base image: using eclipse-temurin, for lightweight JRE using Java 25
FROM eclipse-temurin:25-jre-ubi10-minimal

# Create and set working directory
WORKDIR /minecraft-server

# Copy the included server.jar MC server file to /minecraft-server
COPY server.jar server.properties config-edit ./

# Run commands, e.g.: eula=true
RUN echo "eula=true" > eula.txt

# Ensure bash script can be ran by container
RUN chmod +x config-edit

# Expose default MC server port for the container to listen on
EXPOSE 25565

# Run the server.jar when the container boots up
CMD ["java", "-jar", "server.jar"]