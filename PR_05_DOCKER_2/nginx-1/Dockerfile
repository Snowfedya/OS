# Dockerfile for nginx-1: Unoptimized
# Each RUN command creates a new layer in the Docker image.
# This is inefficient as it increases build time and image size.

FROM ubuntu
LABEL author="DevOps Student" description="Unoptimized Nginx Image"

# This RUN command creates a layer containing the updated package lists.
RUN apt-get update

# This RUN command creates another, separate layer containing the nginx package.
RUN apt-get install -y nginx

# Expose port 80 for the web server
EXPOSE 80

# The command to run when the container starts.
# "-g 'daemon off;'" ensures nginx runs in the foreground.
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
