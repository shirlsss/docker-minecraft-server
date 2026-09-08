# <img src="./img/minecraft-1-logo-png-transparent.png" width="50" height="50"> docker-minecraft-server: 
This is a repository to demonstrate a simple CI/CD pipeline between GitHub and a headless personal RHEL server, using GitHub Actions. For hosting a simple Minecraft server on a self-hosted machine.

## Features

### CLI Server Properties Config Editor
* During image build, you are prompted to change either the most common properties or to edit them in vim yourself.
* `/servers` contains various server.jar files for Fabric, different Minecraft versions, etc.
    * ensure you `cp` the server.jar you wish to use, and rename to exactly `server.jar`

### How to Run the Server
1. Build the Docker image from the Dockerfile  
    - `docker build -t mc-server .`
2. Run the Docker image with our specified Docker volume to store persistent world/server data/files/configuration
    - `docker run --init -it -p 25565:25565 -v mc-data:/opt/minecraft/data mc-server`
        - `mc-data` is the name of the Docker volume that will be managed on our host machine - commonly stored in `/var/lib/docker/volumes/`

## Structure of the Container
```text
/ (root)
├── opt/
|   ├── minecraft/
|           ├── config-edit.sh
|           ├── server.jar
|           ├── server.properties.bak # backup server.properties file, do not touch
|           ├── data/
|              ├── server.properties
|              ├── [world data...]
...    
```

### Notes
#### Docker volumes
* To ensure the world persists, you must run the Docker image with the tag `-v volume_name:path/to/volume`, with the right side pointing to where you want the world file to save to inside the container, with `volume_name` being stored on your host machine
    - ex. `mc-data` will live in `/var/lib/docker/volumes/mc-data/_data`
    - We can verify the hostpath and metadata using the CLI - `docker volume inspect mc-data`
