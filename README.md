# OS Practical Assignments Repository

This repository contains the complete, reproducible project setup for four practical assignments for the university course on Operating Systems. The project is designed for demonstration and defense, with each assignment isolated in its own directory.

## Core Objective

The primary goal is to demonstrate a practical understanding of different virtualization and containerization technologies, showcasing the setup, execution, and key conceptual differences between them. Each practical work is automated using Vagrant for consistent environment provisioning.

## Practical Assignments Included

This repository covers the following four assignments:

1.  **PR_02_KVM:** Full hardware virtualization using KVM (Kernel-based Virtual Machine). This demonstration focuses on setting up a hypervisor, managing virtual networks, and creating a virtual machine using Cockpit.

2.  **PR_03_LXC:** Operating-system-level virtualization using both classic LXC and modern LXD. This guide highlights the creation, management, and isolation of system containers.

3.  **PR_04_DOCKER_1:** Introduction to containerization with Docker. This assignment covers the fundamental Docker workflow, including image management and the container lifecycle.

4.  **PR_05_DOCKER_2:** Advanced Docker concepts, focusing on image optimization. This demonstration analyzes how different `Dockerfile` strategies impact image size and layer count, culminating in running a web server from an optimized image.

## Structure

Each assignment is located in its own directory (e.g., `PR_02_KVM/`) and contains:
- A `Vagrantfile` to provision the necessary virtual machine and software.
- A detailed `DEMO_GUIDE.md` that provides a step-by-step script for demonstrating the technology.
- Any additional configuration files required for the assignment.

To begin any assignment, navigate to the corresponding directory and run `vagrant up`.
