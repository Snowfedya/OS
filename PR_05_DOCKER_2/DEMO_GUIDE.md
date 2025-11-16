# PR-05: Advanced Docker and Image Optimization Demo Guide

This guide is a complete script for demonstrating advanced Docker concepts, focusing on image creation strategies and optimization.

**Objective:** To demonstrate how `Dockerfile` design directly impacts image efficiency by comparing layer count and final image size. This culminates in running a service from the most optimized image.

---

### Step 1: Initial Environment Setup

1.  **Start the VM:**
    *   **Command:** `vagrant up`
    *   **Explanation:** "This command provisions our second Docker host. The setup is identical to the previous lab, but adds a crucial port forward: port 8080 on my host machine will forward to port 8080 on the VM, which we will use to access our Nginx container later."

2.  **Connect to the VM:**
    *   **Command:** `vagrant ssh`
    *   **Explanation:** "I will now connect to the VM to begin the demonstration."

---

### Step 2: `docker commit` Demonstration

**Goal:** To show how to create an image from a running container's state.

1.  **Run a Base Container:**
    *   **Command:** `docker container run -it -d --name my-ubuntu ubuntu /bin/bash`
    *   **Explanation:** "First, I'm starting a basic Ubuntu container and letting it run in the background (`-d`)."

2.  **Commit the Container's State:**
    *   **Command:** `docker container commit --author "RUT-USER" my-ubuntu new-ubuntu`
    *   **Explanation:** "The `commit` command takes a snapshot of the container's current filesystem and creates a new image from it. This is a quick way to save changes or create a custom image, although using a Dockerfile is the more reproducible and recommended method. I've named the new image `new-ubuntu`."

3.  **Run from the New Image:**
    *   **Command:** `docker container run -it --rm new-ubuntu echo "I run from a committed image"`
    *   **Explanation:** "To prove the new image works, I'll run a container from it. As you can see, it successfully executes the command. The `--rm` flag ensures this temporary container is deleted after it exits."

---

### Step 3: Heredoc Dockerfile Demo

**Goal:** To demonstrate an alternative, script-friendly way to build an image.

1.  **Build Image using Heredoc:**
    *   **Command:**
        ```bash
        docker image build -t alp-htop - << EOF
        FROM alpine
        RUN apk --no-cache add htop
        EOF
        ```
    *   **Explanation:** "Instead of a physical `Dockerfile`, we can pipe a build context directly into the Docker daemon using a 'heredoc'. This is useful for simple images or in automated scripts. Here, I'm creating a small Alpine image with the `htop` utility."

2.  **Run the Image:**
    *   **Command:** `docker container run -it --rm alp-htop htop`
    *   **Explanation:** "Now, I'll run the `htop` command from the image we just built. As you can see, the `htop` interface is running, confirming the build was successful."
    *   **Action:** Press 'q' to exit `htop` and stop the container.

---

### Step 4: Dockerfile Build Demonstration

**Goal:** To build the three Nginx images from their respective Dockerfiles.

1.  **Navigate to the Shared Directory:**
    *   **Command:** `cd /vagrant`
    *   **Explanation:** "All the project files are available in the `/vagrant` directory. I will now `cd` into each `nginx-*` subdirectory to build the images."

2.  **Build the Images:**
    *   **Command:** `cd nginx-1 && docker image build -t nginx-1 . && cd ..`
    *   **Command:** `cd nginx-2 && docker image build -t nginx-2 . && cd ..`
    *   **Command:** `cd nginx-3 && docker image build -t nginx-3 . && cd ..`
    *   **Explanation:** "I am now building the three `nginx` images, one from each Dockerfile. Docker is executing the instructions in each file, pulling the base Ubuntu image and running the specified commands."

---

### Step 5: Optimization Analysis (THE KEY DEMO)

**Goal:** To clearly explain and show the direct results of our optimization strategies.

1.  **Analyze Layer Difference with `history`:**
    *   **Command:** `echo "--- NGINX-1 HISTORY (More Layers) ---" && docker image history nginx-1`
    *   **Explanation:** "First, let's examine the history of the `nginx-1` image. **As you can see, there are two separate `RUN` commands**, one for `apt-get update` and one for `apt-get install`. Each `RUN` instruction creates a new, distinct layer in the image."
    *   **Command:** `echo "--- NGINX-2 HISTORY (Fewer Layers) ---" && docker image history nginx-2`
    *   **Explanation:** "Now, let's look at `nginx-2`. **Notice that there is only one `RUN` command listed here.** By chaining the `apt-get update` and `install` commands with `&&`, we combined them into a single, more efficient layer. This is the first step of optimization: reducing the number of layers."

2.  **Analyze Size Difference with `ls`:**
    *   **Command:** `echo "--- IMAGE SIZES (nginx-3 is smallest) ---" && docker image ls nginx-*`
    *   **Explanation:** "This is the most important part of the demonstration. Let's compare the final image sizes.
        *   `nginx-1` and `nginx-2` are very similar in size. Although `nginx-2` has fewer layers, both images still contain the `apt` cache data, which is downloaded by `apt-get update`.
        *   **Now, look at `nginx-3`. It is significantly smaller than the other two.** This is because, in the *same layer* that we installed nginx, we also ran `rm -rf /var/lib/apt/lists/*`. This cleans up the downloaded package lists, which are not needed for the final running container. Because the cleanup happened in the same `RUN` command, the deleted data doesn't persist in the final image layer. This is the key to minimizing image size."

---

### Step 6: Final Result and Verification

**Goal:** To run the fully optimized image and confirm it works as expected.

1.  **Run the Optimized Container:**
    *   **Command:** `docker container run -d -p 8080:80 --name web-3 nginx-3`
    *   **Explanation:** "I will now run a container from our smallest, most optimized image, `nginx-3`. I'm running it in detached mode (`-d`) and mapping port 8080 on the Vagrant VM to port 80 inside the container, which is where Nginx is listening."

2.  **Verify from Host Browser:**
    *   **Action:** Open a web browser on the **host machine** (your computer).
    *   **URL:** `http://localhost:8080`
    *   **Explanation:** "Because we have a chain of port forwards (Host:8080 -> VM:8080 -> Container:80), I can now access the Nginx server directly from my own browser. The **'Welcome to nginx!'** page confirms that our optimized container is running successfully."

---

### Step 7: Final Cleanup

**Goal:** To return the system to a clean state.

1.  **Stop and Remove Containers:**
    *   **Command:** `docker container stop web-3`
    *   **Command:** `docker container rm web-3 my-ubuntu`
    *   **Explanation:** "First, I'll stop and remove the running containers."

2.  **Remove Images:**
    *   **Command:** `docker image rm nginx-1 nginx-2 nginx-3 new-ubuntu alp-htop`
    *   **Explanation:** "Finally, I will remove all the images we created during this demonstration. This concludes the practical work."
