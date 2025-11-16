# Dockerfile for nginx-3: Fully Optimized
# This version combines commands AND cleans up the apt cache in the same layer.
# This is the best practice for minimizing image size.

FROM ubuntu
LABEL author="DevOps Student" description="Fully Optimized Nginx Image"

# This single RUN command does three things:
# 1. Updates package lists.
# 2. Installs nginx.
# 3. CRUCIAL: Cleans up the apt cache, which is no longer needed.
# By cleaning up in the same RUN command, we ensure the deleted files
# do not persist in the final image layer, resulting in a smaller size.
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Expose port 80 for the web server
EXPOSE 80

# The command to run when the container starts.
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
