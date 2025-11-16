# PR-04: Docker Fundamentals Demonstration Guide

This guide provides a step-by-step scenario for demonstrating the basic concepts of Docker, including image management and the container lifecycle.

**Objective:** To demonstrate the end-to-end workflow of finding, running, interacting with, and managing a Docker container.

---

### Step 1: Initial Environment Setup

**Goal:** Provision the Docker host and connect to it.

1.  **Start the VM:**
    *   **Command:** `vagrant up`
    *   **Explanation:** "This command provisions an Ubuntu 22.04 VM named `docker-host`. The script uses the official Docker installation method to set up a clean, modern Docker environment. It also adds the `vagrant` user to the `docker` group, so we can run Docker commands without `sudo`."

2.  **Connect to the VM:**
    *   **Command:** `vagrant ssh`
    *   **Explanation:** "I will now connect to the host. If the `docker` group permissions haven't applied, you may need to exit and re-enter the SSH session. Let's verify with `docker ps` - if it runs without a permission error, we are ready."

---

### Step 2: Image Management

**Goal:** To demonstrate how to find and manage Docker images.

1.  **Search for an Image:**
    *   **Command:** `docker search ubuntu`
    *   **Explanation:** "My goal is to run an Ubuntu container. The `docker search` command lets me search for publicly available images on Docker Hub. As you can see, the official `ubuntu` image is listed at the top."

2.  **Pull a Specific Image Version:**
    *   **Command:** `docker image pull ubuntu:18.04`
    *   **Explanation:** "It's a best practice to specify an image tag to ensure reproducibility. Here, I am pulling the `18.04` version of Ubuntu, which might be required for a legacy application. Docker now downloads the image layers required to assemble the complete image."

3.  **List Local Images:**
    *   **Command:** `docker image ls`
    *   **Explanation:** "This command lists all the Docker images stored on this machine. We can now see `ubuntu` with the tag `18.04` is available locally, ready to be used."

---

### Step 3: Container Lifecycle Demonstration

**Goal:** To walk through the entire lifecycle of a container: create, run, interact, detach, re-attach, stop, and inspect.

1.  **Run a Container in Interactive Mode:**
    *   **Command:** `docker container run -it --name test-ubuntu ubuntu:18.04 /bin/bash`
    *   **Explanation:** "I will now create and start a new container from the image we just pulled.
        *   `-it` gives me an interactive TTY, connecting my terminal directly to the container's shell.
        *   `--name test-ubuntu` assigns a memorable name to the container.
        *   `ubuntu:18.04` is the image to use.
        *   `/bin/bash` is the command to run inside the container.
    *   **Note:** "My command prompt has now changed, indicating I am inside the container's isolated environment."

2.  **Work Inside the Container:**
    *   **Command (inside container):** `apt-get update && apt-get install -y inetutils-ping`
    *   **Explanation:** "The container's filesystem is ephemeral. Any changes I make, like installing software, only affect this specific container. I'm installing the `ping` utility to demonstrate network connectivity from within the container."
    *   **Command (inside container):** `ping -c 3 ya.ru`
    *   **Explanation:** "As you can see, the container has its own network stack and can reach the public internet, successfully pinging the destination."

3.  **Detach from the Container:**
    *   **Action:** Press `Ctrl+P`, then `Ctrl+Q`.
    *   **Explanation:** "I've now detached from the container's shell without stopping it. The container continues to run in the background."

4.  **Show the Running Container:**
    *   **Command:** `docker container ls`
    *   **Explanation:** "This command shows all *running* containers. We can see our `test-ubuntu` container is still in the **Up** state."

5.  **Re-attach to the Container:**
    *   **Command:** `docker container attach test-ubuntu`
    *   **Explanation:** "I can re-attach my terminal to the running container's process at any time. As you can see, I'm back in the bash shell where I left off."

6.  **Stop the Container:**
    *   **Action (inside container):** `exit`
    *   **Explanation:** "When the main process inside a container finishes (in this case, the bash shell), the container stops. I will now exit the shell."

7.  **Show the Stopped Container:**
    *   **Command:** `docker container ls -a`
    *   **Explanation:** "If I run `docker container ls` again, the container is gone. However, using the `-a` flag shows *all* containers, including stopped ones. We can see `test-ubuntu` now has an **Exited** status. It still exists on the disk, but it is not running."

---

### Step 4: Cleanup

**Goal:** To demonstrate the proper removal of stopped containers and unused images.

1.  **Remove the Container:**
    *   **Command:** `docker container rm test-ubuntu`
    *   **Explanation:** "A stopped container still occupies disk space. This command permanently removes it."

2.  **Prune Stopped Containers (Alternative):**
    *   **Command:** `docker container prune -f`
    *   **Explanation:** "As an alternative, `prune` is a useful command to remove all stopped containers at once. The `-f` flag confirms without prompting."

3.  **Remove the Image:**
    *   **Command:** `docker image rm ubuntu:18.04`
    *   **Explanation:** "Finally, to free up disk space, I will remove the Ubuntu image we downloaded. This completes the basic Docker workflow."
