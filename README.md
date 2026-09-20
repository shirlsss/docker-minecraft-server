# <img src="./img/minecraft-1-logo-png-transparent.png" width="50" height="50"> docker-minecraft-server: 
This is a repository to demonstrate a simple CI/CD pipeline between GitHub and a headless personal RHEL server, using GitHub Actions. For hosting a simple Minecraft server on a self-hosted machine.

## Features

### CLI Server Properties Config Editor
* During image build, you are prompted to change either the most common properties or to edit them in vim yourself.
* Current server version: 26.3

### How to Run the Container Locally
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

### How to Run the Container from GitHub Container Registry (GHCR)
* Since we are demonstrating a simple CI/CD pipeline with our Docker container, the continous delivery/deployment end will be done by Watchtower
* Watchtower will be deployed as a container on our host machine, which then watches in our `/var/run/docker.sock` for any containers
* It then uses that info to watch the GHCR/Docker registry and rebuilds and redeploys as needed
    * Because Watchtower rebuilds for us - cannot start the container with a script. 

### Notes
#### Docker volumes
* To ensure the world persists, you must run the Docker image with the tag `-v volume_name:path/to/volume`, with the right side pointing to where you want the world file to save to inside the container, with `volume_name` being stored on your host machine
    - ex. `mc-data` will live in `/var/lib/docker/volumes/mc-data/_data`
    - We can verify the hostpath and metadata using the CLI - `docker volume inspect mc-data`
#### `server.properties`
* Do not need to fill in the server-ip in server.properties - as long as port 25565 is forwarded and **allowed by your firewall**, users can connect via your `public_ip:25565`
#### Troubleshooting the containter
* to view the image directory, `docker run --rm mc-server ls -la /opt/minecraft`
* to also see the Docker volume, `docker run --rm -v mc-data:/opt/minecraft/data mc-server ls -la /opt/minecraft`

## TODO:
### Near future
* Configure config-edit.sh to read from a .env file so it can be autodeployed
* Decide if I want to publish my backup script
#### To be done, one day in the future!
* Add server version selection via cURL
* Add modded options (Forge, Fabric)
* Add modpack support
