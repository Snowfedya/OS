# PR-03: LXC and LXD Demonstration Guide

This guide provides a step-by-step scenario for demonstrating and contrasting classic LXC and modern LXD for OS-level virtualization.

**Objective:** To demonstrate the creation and management of system containers using both the original LXC toolset and the modern LXD daemon, highlighting the differences in workflow and features.

---

### Step 1: Initial Environment Setup

**Goal:** Provision the host environment and connect to it.

1.  **Start the VM:**
    *   **Command:** `vagrant up`
    *   **Explanation:** "This command provisions an Ubuntu 22.04 VM named `lxc-host`. The script installs both the classic `lxc` packages and the modern `lxd` daemon via Snap. It then automatically initializes LXD with a default configuration."

2.  **Connect to the VM:**
    *   **Command:** `vagrant ssh`
    *   **Explanation:** "I will now connect to the host VM to begin the container demonstrations."

---

### Part I: The "Classic" LXC Experience

**Goal:** To demonstrate the original, lower-level tools for managing system containers.

1.  **Check Host Configuration:**
    *   **Command:** `lxc-checkconfig`
    *   **Explanation:** "This utility checks if the host kernel supports all the features required for LXC containers. As we can see, everything is green, confirming our environment is ready."

2.  **Create an Alpine Container:**
    *   **Command:** `sudo lxc-create -t download -n con1 -- --dist alpine --release 3.16 --arch amd64`
    *   **Explanation:** "Here, I'm creating a new container named `con1` using the `download` template. I am explicitly specifying Alpine Linux version 3.16. This is a deliberate choice for reproducibility, as it avoids potential GPG key or repository issues that can occur with newer, rolling-release images. The output shows the tool downloading the rootfs and setting up the container's configuration file."

3.  **Manage the Container:**
    *   **Command:** `sudo lxc-start -n con1`
    *   **Explanation:** "This command starts the container in the background."
    *   **Command:** `sudo lxc-ls --fancy`
    *   **Explanation:** "The `lxc-ls` command shows the status of our containers. We can see `con1` is in the **RUNNING** state and has been assigned an IP address from the default LXC bridge."

4.  **Interact with and Inspect the Container:**
    *   **Command:** `sudo lxc-attach -n con1 -- /bin/ash`
    *   **Explanation:** "I will now attach to the container's namespace and get an interactive shell. I am now *inside* the Alpine container."
    *   **Action (inside container):** `echo "I am con1" > /readme.txt` then `exit`
    *   **Explanation:** "I've created a file inside the container. Now, I will demonstrate that the container's filesystem is simply a directory on the host, which is a key concept of OS-level virtualization."
    *   **Command (on host):** `sudo cat /var/lib/lxc/con1/rootfs/readme.txt`
    *   **Explanation:** "As you can see, I can access the file created inside the container directly from the host's filesystem. This illustrates the nature of container isolation—it's process and filesystem isolation, not a full hardware abstraction like a VM."

---

### Part II: The "Modern" LXD Experience

**Goal:** To demonstrate the improved, daemon-based approach of LXD.

1.  **Check LXD Server Status:**
    *   **Command:** `lxc version`
    *   **Explanation:** "This shows both the client and server versions, confirming the `lxd` daemon is running."
    *   **Command:** `lxc info`
    *   **Explanation:** "This provides a detailed overview of the LXD server configuration, including network bridges and storage pools. This is far more comprehensive than the classic tooling."

2.  **Launch a Container:**
    *   **Command:** `lxc launch images:alpine/3.16 lxd-con1`
    *   **Explanation:** "This is the modern equivalent of `lxc-create` and `lxc-start` combined. Notice the simpler, more intuitive syntax. We're launching a container named `lxd-con1` from a pre-defined remote image source, `images:`. LXD handles the download, creation, and startup in one step."

3.  **List and Interact with the Container:**
    *   **Command:** `lxc list`
    *   **Explanation:** "The `lxc list` command gives a clean, detailed table of all running containers managed by LXD, including their state, IP addresses, and type."
    *   **Command:** `lxc exec lxd-con1 -- /bin/ash -c "uname -a"`
    *   **Explanation:** "LXD makes it easy to execute a single command inside a container without needing a full interactive shell. Here, I'm just running `uname -a`."
    *   **Command:** `lxc exec lxd-con1 -- /bin/ash`
    *   **Explanation:** "And this command gives me an interactive shell inside the container, similar to `lxc-attach`."
    *   **Action:** Run a few commands, then `exit`.

---

### Step 3: Cleanup

**Goal:** To demonstrate the proper removal of both LXC and LXD containers.

1.  **Cleanup Classic LXC:**
    *   **Command:** `sudo lxc-stop -n con1`
    *   **Command:** `sudo lxc-destroy -n con1`
    *   **Explanation:** "For classic LXC, stopping and destroying are two separate steps."

2.  **Cleanup Modern LXD:**
    *   **Command:** `lxc delete --force lxd-con1`
    *   **Explanation:** "With LXD, a single `delete` command can stop and remove the container. The `--force` flag is used to delete it even if it's running. This completes the demonstration of both container management systems."
