# Base image: using eclipse-temurin, for lightweight JRE using Java 25
FROM eclipse-temurin:25-jre-ubi10-minimal

# Create and set working directory
WORKDIR /opt/minecraft

# Copy the included server.jar MC server file to /minecraft-server
COPY server.jar config-edit server.properties.bak ./

# Run commands, e.g.: eula=true
RUN echo "eula=true" > eula.txt

# Ensure bash script can be ran by container
RUN chmod +x config-edit

# Expose default MC server port for the container to listen on
EXPOSE 25565

# Install vim to be used as needed during config-setup and then switch back to regular user
USER ROOT
RUN microdnf install -y vim && microdnf clean all
USER 10001

# Run the server.jar when the container boots up
# CMD ["java", "-jar", "server.jar"]
CMD ["./config-edit"]
