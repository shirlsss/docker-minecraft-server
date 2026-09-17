# Base image: using eclipse-temurin, for lightweight JRE using Java 25
FROM eclipse-temurin:25-jre-ubi10-minimal

# Create and set working directory
WORKDIR /opt/minecraft

# Copy the included server.jar MC server file to /minecraft-server
COPY server.jar config-edit.sh server.properties.bak ./

# Expose default MC server port for the container to listen on
EXPOSE 25565

USER root 
# Run commands, e.g.: eula=true
# Ensure bash script can be ran by container
# Install vim to be used as needed during config-setup and then switch back to regular user
RUN echo "eula=true" > eula.txt \
    chmod +x config-edit \
    microdnf install -y vim-9.2.1011-1.1 && microdnf clean all
USER 10001

# Run the server.jar when the container boots up
# CMD ["java", "-jar", "server.jar"]
CMD ["./config-edit.sh"]
