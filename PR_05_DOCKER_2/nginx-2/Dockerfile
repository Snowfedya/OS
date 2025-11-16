# Dockerfile for nginx-2: Partially Optimized
# This version combines two commands into a single RUN instruction.
# This reduces the number of layers, which is a good practice.

FROM ubuntu
LABEL author="DevOps Student" description="Partially Optimized Nginx Image"

# By combining 'update' and 'install' into one RUN command,
# we create only a single layer for this part of the setup.
RUN apt-get update && apt-get install -y nginx

# Expose port 80 for the web server
EXPOSE 80

# The command to run when the container starts.
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
