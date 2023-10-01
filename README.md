# mojo-remote-docker

Instructions to use mojo on Mac with remote Ubuntu server and Docker

# System configuration assumptions (instructions not covered here)

- Docker is set up on your personal computer (i.e. client) and remote server
- A secure connection is set up between the client and remote server (i.e. Cloudflare private tunnel)

# How it works

**Server:**

- Docker on a remote server listens to connections from other computers

**Client:**

- Watch for file changes in the personal computer's project src dir
- Sync file changes to the remote server
- Tell Docker on your personal computer to use (i.e. execute) the Docker on the remote server

**Limitations:** rsync is used because Docker cannot bind a dir/mount a volume to a remote server

# Instruction

## Set up server

1. Create mojosdk docker image. Follow instructions

   - [Modular Docker Example](https://github.com/modularml/mojo/tree/main/examples/docker)
   - [Using Mojo🔥 with Docker containers](https://youtu.be/cHyYmF-RhUk?si=LwyNAobjKlCpdjLz)

1. Enable Docker to accept connections from other computers

     <div style="color: white; background-color: #741624">

   > :warning: from [Configure remote access for Docker daemon](https://docs.docker.com/config/daemon/remote-access/)
   >
   > **Secure your connection**
   > Before configuring Docker to accept connections from remote hosts it's critically important
   > that you understand the security implications of opening Docker to the network. If steps
   > aren't taken to secure the connection, it's possible for remote non-root users to gain root
   > access on the host. For more information on how to use TLS certificates to secure this
   > connection, check Protect the Docker daemon socket.

     </div>

1. Open file `/lib/systemd/system/docker.service`

- Find the line with
  `ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock`

- Add `-H tcp://0.0.0.0:2375` after `-H fd://`

  i.e.
  `ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock`

1. Restart docker daemon and service (DO THIS whenever you create a new mojosdk image)

   ```sh
   sudo systemctl daemon-reload
   sudo systemctl restart Docker
   ```

1. Optional: Create a simple tag

   ```sh
   docker images
   # This will output something like
   # REPOSITORY
   # modular/mojo-v0.3.1-20233009-0602

   docker tag "{{ image_name_from  }}:latest" mojosdk:latest
   ```

1. Create directories on server

   ```
   ssh {{username}}:{{server}}
   mkdir -p src/project
   ```

## Set up personal computer (i.e. host, client)

1. Copy files from `[example](./example/personal_computer/repo) to your project

   ```sh
   cp examples/personal_computer/repo {{ path_to_your_project }}
   ```

1. Change dir to your mojo project

   ```sh
   cd {{ path_to_your_project }}
   ```

1. Open Makefile in editor, and update env variables

   ```sh
    # Makefile
    # rsync config
    HOST={replace with your ip} # ie. 10.0.3.2
    CONTEXT_NAME=docker-ubuntu-server

    # docker config
    SRC_DIR=/home/server_username/src/project
    TARGET_DIR=/src
   ```

1. Opne rsync-changes.sh file and update env variables

   ```sh
   # rsync-changes.sh
   SOURCE_DIR=. # mojo source dir on your personal computer
   DEST_DIR=src/project # relative path remote server (should match structure on personal computer), replace path to your desired project structure
   HOST={{ domain_or_ip }} # ie. 10.0.3.2
   ```

1. Sync local project files to server and run Docker

   ```sh
   make all &
   ```

1. Test through command line (or use Docker VS Code extention)

   ```sh
   docker container
   # This will output something like
   docker container list
   CONTAINER ID   IMAGE
   f9894826e5e4   mojosdk:latest

   docker exec -it docker-remote-server mojo /src/hello.mojo
   # Output: hello mojo

   # Open hello.mojo in your editor and change mojo to modular
   # Wait a few seconds for files to sync

   docker exec -it docker-remote-server mojo /src/hello.mojo
   # Output: hello modular

   # Or swtich into a sub-shell on the container
   docker exec -it docker-remote-server bash
   cd /src # this is docker container dir wit you project src
   ```
