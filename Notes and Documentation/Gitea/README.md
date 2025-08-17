Gitea Install Guide

Okay, let's break down the user's request first. They want me to explain a Docker Compose file and provide installation steps. The provided context shows two different Docker Compose configurations - one for Gitea with MySQL database using standard images, and another for MariaDB with npm-db service.

Hmm, interesting that they're asking about both files though the user didn't explicitly mention which one. Looking at Context 0: It's a Gitea setup file with three services (db, gitea, runner) all in a bridge network called 'gitea'. This seems to be for setting up Git hosting services locally.

Context 1 appears different - it mentions npm-db and MariaDB with volume './data/mysql:/var/lib/mysql', which suggests this might be for Node.js related projects. The user didn't specify which file they're referring to though.

The user's follow-up question is actually quite broad since we don't know exactly which service configuration they need help with. They want both an explanation and installation instructions, but without knowing the exact use case (Git server vs database setup), I can only focus on the first context provided about Gitea.

I should explain that while they requested one docker-compose file, two different configurations were provided in the contexts - one for Git hosting services and another possibly related to npm with MariaDB. Since we don't know which was originally intended, I'll focus on explaining the available information (the Gitea configuration) as much as possible.

The user seems technically proficient enough to handle Docker setups but might be looking for clarification about how specific components interact in this environment. They're likely setting up some development or testing infrastructure and need guidance.
</think>
Okay, here is a technical explanation of the `docker-compose.yml` content provided (Context 0), followed by step-by-step instructions on how to use it.

**Technical Explanation**

This Docker Compose file (`docker-compose.yml`) defines three distinct services within named networks called "gitea":

1.  **Database Service (`db`):**
    *   Uses the official MySQL image version 8.
    *   Container Name: `gitea-db`
    *   Restart Policy: `unless-stopped` - The container will automatically restart if it stops, unless explicitly stopped by an administrator command or Docker daemon rules (like on shutdown).
    *   Environment Variables: Loaded from a `.env` file and sets standard database credentials (`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, etc.).
    *   Volumes: Mounts the host's current directory (`./mysql`) into the container's default MySQL data location (`/var/lib/mysql`). This stores the Dockerized database files on your host machine for persistence.
    *   Networks: Connects to the "gitea" bridge network so other services can communicate with it via its internal name ("db").
    *   Healthcheck: Uses `mysqladmin ping` command against the local MySQL server (`localhost`) using user and password from environment variables. Checks occur every 10 seconds, wait up to 5s for a response, retry 5 times (total 50s). If it fails, the service is marked unhealthy.

2.  **Gitea Service (`gitea`):**
    *   Uses the official Gitea image from Docker Hub (`gitea/gitea:latest`). This sets up a Git server.
    *   Container Name: `gitea`
    *   Restart Policy: `unless-stopped` - Same behavior as the database service regarding automatic restarts.
    *   Environment Variables: Loaded from `.env`. It requires user ID and group ID (`USER_UID=1000`, `USER_GID=1000`) for proper file ownership within its data volume. The crucial Gitea configuration variables are set here, pointing it to the database server ("db"), specifying the DB type (likely "mysql", loaded from `.env`), and providing credentials (`GITEA__database__...`). It also sets a higher priority port mapping for access.
    *   Volumes: Mounts two directories on the host:
        - `./gitea:/data`: Stores Gitea's application data (repositories, configuration files, logs) in `/data` within the container. Host directory is `./gitea`.
        - `/etc/localtime:/etc/localtime:ro`: Makes this container use your host system's timezone setting.
    *   Networks: Connects to the "gitea" bridge network.
    *   Depends On: The service definition includes a condition (`service_healthy`) that ensures it waits for the `db` service (named dependency) to pass its health checks before starting. Gitea itself uses an internal healthcheck via `curl`.
    *   Ports:
        - `"3000:3000"`: Exposes Gitea's web UI port from container 3000 to host 3000.
        - `"222:22"`: Exposes the SSH server port from container 22 (default for Docker image) to host 222. This allows accessing Git repositories via SSH clients.

3.  **Gitea Runner Service (`runner`):**
    *   Uses a dedicated Gitea CI runner image (`gitea/act_runner:latest`).
    *   Container Name: `gitea-runner`
    *   Restart Policy: `unless-stopped`.
    *   Depends On: Will wait for the `gitea` service (named dependency) to be healthy before starting.
    *   Environment Variables: Loaded from `.env`. Key variables include Gitea's instance URL (`GITEA_INSTANCE_URL`) and a registration token (`GITEA_RUNNER_REGISTRATION_TOKEN`). It also specifies its name, labels for job routing, and log level (trace). Crucially, it sets the `GITEA_RUNNER_JOB_CONTAINER_NETWORK` to "gitea".
    *   Volumes: Mounts three directories:
        - `./runner-data:/data`: Stores CI artifacts or runner-specific data in a subdirectory of Gitea's main directory.
        - `/config.yaml`: This line seems incorrect as provided. Assuming it means mounting the host-side generated configuration file (which is typically done elsewhere) but based on the pattern, it should likely be `- ./runner-config.yaml:/config.yaml`. The `act_runner` *needs* this config file internally, so providing one via volume mount from `./runner-config.yaml` would configure it appropriately. This directory (`./runner-data`) exists and holds persistent data for jobs.
        - `/var/run/docker.sock:/var/run/docker.sock`: Mounts the host's Docker socket into this container. The Gitea runner executes CI commands within a separate Docker container (using `act`). Access to the host's Docker socket is necessary for it to perform these actions (`docker run ...`).

**Common Elements:**

*   `.env`: Used by multiple services to load environment variables, likely containing secrets and configuration values.
*   `gitea` network: A bridge network connecting all three services. They communicate via their internal names (like `db`, `gitea`, `runner`) on this network.

**Purpose:** This setup creates a self-contained local instance of Gitea and its CI runner, with an accompanying MySQL database. It's useful for testing Git functionalities locally or setting up a personal/private Git server without needing to install the software directly on the host OS.

---

**Step-by-Step Installation Guide (Based on Context 0)**

This guide assumes you want to set up Gitea and its runner using Docker Compose with a MySQL database. The instructions are for this specific configuration file structure shown in Context 0.

1.  **Prerequisites:**
    *   Ensure your host machine meets the [requirements](https://docs.gitea.com/installation/requirements) for running Gitea.
    *   Install [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose V2](https://docs.docker.com/compose/v2/) on your system (Windows, macOS, Linux).
    *   Have a `.env` file ready or create one. This file should contain the necessary environment variables for Gitea and MySQL.
        *   Example contents of your `.env` file might include:
            ```
            MYSQL_ROOT_PASSWORD=your_root_password
            MYSQL_DATABASE=gitea_db_name  # Name for the database used by Gitea
            MYSQL_USER=mysql_user          # Database user (Gitea)
            MYSQL_PASSWORD=mysql_password # Password for that user

            GITEA_APP_NAME=Gitea_Instance_Name  # Can be set here or in .env file, but also might default to image name.
            GITEA__database__DB_TYPE=mysql
            GITEA__database__HOST=db:3306         # "db" is the internal hostname for the MySQL service (from context)
            GITEA__database__NAME=gitea_db_name    # Same as MYSQL_DATABASE above, *or* this might override it. Check consistency.
            GITEA__database__USER=mysql_user       # Same as MYSQL_USER
            GITEA__database__PASSWD=mysql_password # Same as MYSQL_PASSWORD

            # For the runner (optional if you don't need CI)
            GITEA_INSTANCE_URL=http://localhost:3000  # Should match your host mapping for gitea service (typically :3000)
            GITEA_RUNNER_REGISTRATION_TOKEN=your_token
            ```

2.  **Prepare the Directory Structure:**
    *   Create a directory where you want to run this setup.
    *   Copy both `docker-compose.yml` and `.env` files into that directory from wherever they are located (ensure Context 0's `docker-compose.yml` is used).
        *   Example structure:
            ```
            /path/to/my/gitea/installation/
              ├── docker-compose.yml
              ├── .env
              ├── gitea/           # Will be created by the first run. Contains Gitea data (repositories, logs)
              └── runner-data/     # Will be created by the Gitea runner container when it starts for the first time.
            ```
    *   Alternatively, if you are using a single `docker-compose.yml` file from Context 0 and want to manage other services later, ensure your chosen directory is correct.

3.  **Start the Services:**
    *   Open a terminal or command prompt in the directory containing `docker-compose.yml`.
    *   Run the following command:
        ```
        docker compose up -d
        ```
        This command starts all three defined services (`db`, `gitea`, and `runner`) in detached mode (background).

4.  **Verify Service Startup:**
    *   Check if the database service is healthy first, as it's critical for Gitea:
        ```
        docker compose ps   # Lists running containers
        docker compose inspect gitea-db | grep -A10 'healthcheck.*Status'   # Inspect container details to see health status (requires Docker Compose V2)
        ```
    *   Check the logs of all services if necessary for startup errors:
        ```
        docker compose logs  # Shows logs from all services
        # Or specific one, e.g., `docker compose logs gitea` or `docker compose logs runner`
        ```

5.  **Accessing Gitea:**
    *   Open a web browser and navigate to `http://localhost:3000`. The default username is `admin`, password is `root`.
    *   You might see an initial setup page if this is the first run.

**Note:** This configuration maps the SSH port (22 for container) to host 222. Remember that ports below 1024 often require root privileges on Linux systems, but Docker Compose handles these mappings appropriately regardless of OS usually.
