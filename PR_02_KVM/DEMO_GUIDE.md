# PR-02: KVM Demonstration Guide

This guide provides a step-by-step scenario for demonstrating a full hardware virtualization setup using KVM on an Ubuntu 22.04 host provisioned by Vagrant.

**Objective:** To demonstrate the ability to set up a KVM hypervisor, configure a virtual network, and manage a complete virtual machine through a web-based interface (Cockpit).

---

### Step 1: Initial Environment Setup

**Goal:** Provision the virtual machine that will act as our KVM hypervisor and connect to it.

1.  **Start the VM:**
    *   **Command:** `vagrant up`
    *   **Explanation:** "This command provisions an Ubuntu 22.04 VM named `kvm-host`. The script automatically installs KVM, the libvirt daemon, and the Cockpit web management interface. Crucially, it also enables nested virtualization, which is required for running a VM inside our Vagrant-managed VM."

2.  **Connect to the VM:**
    *   **Command:** `vagrant ssh`
    *   **Explanation:** "Now, I will connect to the hypervisor VM to perform the setup and verification steps."

---

### Step 2: Verify KVM Installation

**Goal:** Confirm that the KVM hypervisor and its supporting services are installed and running correctly.

1.  **Check the Libvirt Service:**
    *   **Command:** `systemctl status libvirtd`
    *   **Explanation:** "First, I am checking the status of `libvirtd`, the core daemon for managing virtual machines and hypervisors. As you can see, the service is **active (running)**, which confirms the installation was successful."

2.  **Confirm Hardware Virtualization Support:**
    *   **Command:** `egrep -cwo 'vmx|svm' /proc/cpuinfo`
    *   **Explanation:** "This is a critical check. This command counts the CPU flags for hardware virtualization support (`vmx` for Intel, `svm` for AMD). The output must be greater than zero. A result of **2** (or higher, matching our vCPU count) confirms that nested virtualization is correctly enabled by the parent hypervisor (VirtualBox), allowing KVM to function."

---

### Step 3: Configure the Virtual Network

**Goal:** Define and activate a custom, isolated network for our future VMs.

1.  **Define the Network from XML:**
    *   **Command:** `sudo virsh net-define --file /vagrant/hostonly-network.xml`
    *   **Explanation:** "KVM's default network is shared with the host. For better isolation, we are defining a new 'hostonly' network from the provided XML file. This creates a network on the `192.168.100.0/24` subnet."

2.  **Start the Network:**
    *   **Command:** `sudo virsh net-start hostonly`
    *   **Explanation:** "The network is now defined, but not active. This command starts it."

3.  **Enable Autostart:**
    *   **Command:** `sudo virsh net-autostart hostonly`
    *   **Explanation:** "To ensure the network persists after a reboot of the hypervisor, I'll set it to autostart."

4.  **Verify Network Status:**
    *   **Command:** `sudo virsh net-list --all`
    *   **Explanation:** "As you can see from the output, we now have two networks: the `default` network and our newly created `hostonly` network, which is **active** and set to **autostart**."

---

### Step 4: Prepare ISO for VM Installation

**Goal:** Prepare the hypervisor by creating a dedicated directory and uploading an OS installation ISO.

1.  **Create ISO Directory (inside the VM):**
    *   **Command:** `sudo mkdir -p /var/images && sudo chown vagrant:vagrant /var/images`
    *   **Explanation:** "To keep things organized, I'll create a standard directory, `/var/images/`, to store our OS installation media."

2.  **Upload the ISO (from your host machine):**
    *   **Explanation:** "Now, I need to upload the Ubuntu Server ISO to the VM. I will open a **new, separate terminal** on my host machine to run the following `vagrant scp` command."
    *   **Command (run on host):** `vagrant scp /path/to/your/ubuntu-22.04.iso kvm-host:/var/images/ubuntu.iso`
    *   **Note for Defense:** "Replace `/path/to/your/ubuntu-22.04.iso` with the actual path to the downloaded ISO file. This command securely copies the file into the directory we just created inside the VM."

---

### Step 5: Cockpit Web UI Demonstration

**Goal:** To demonstrate the entire VM lifecycle—creation, execution, and interaction—through a user-friendly web interface.

1.  **Access Cockpit:**
    *   **Action:** Open a web browser on your host machine.
    *   **URL:** `https://localhost:9090`
    *   **Explanation:** "Our Vagrantfile forwarded port 9090 from the VM to our host machine. I can now access the Cockpit management interface directly in my browser. I will log in with the credentials `vagrant` and `vagrant`."

2.  **Create a Virtual Machine:**
    *   **Action:** Navigate to the **"Virtual Machines"** tab in Cockpit and click **"Create VM"**.
    *   **Explanation:** "Here, I will configure and create a new virtual machine named `Ubuntu_2` directly from the UI."
    *   **Settings to use:**
        *   **Name:** `Ubuntu_2`
        *   **Installation Source:** Use the path to the ISO we uploaded: `/var/images/ubuntu.iso`
        *   **Storage:** Create a new virtual disk, 5GB is sufficient.
        *   **Memory:** 1024 MB (1 GB).
    *   **Action:** Click **"Create"**.
    *   **Explanation:** "Cockpit is now using `virt-install` in the background to create the VM based on these parameters. The OS installation process will begin automatically."

3.  **Show the Running VM and Console:**
    *   **Action:** Click on the `Ubuntu_2` VM in the list.
    *   **Explanation:** "We can now see the running VM and its resource usage. Most importantly, Cockpit provides a fully interactive **VNC console** directly in the web browser. This allows us to complete the OS installation and interact with the VM without needing a separate VNC client."
    *   **Action:** Briefly interact with the installer in the console to prove it's a live, running machine.

---

### Step 6: Cleanup

**Goal:** To demonstrate proper resource management by cleanly removing the created VM and network.

1.  **Destroy the VM:**
    *   **Command (in VM SSH session):** `sudo virsh destroy Ubuntu_2`
    *   **Explanation:** "First, I will stop the VM."

2.  **Undefine the VM and Remove Storage:**
    *   **Command:** `sudo virsh undefine Ubuntu_2 --remove-all-storage`
    *   **Explanation:** "Next, I will completely remove the VM's configuration and its associated virtual disk. This is a destructive but clean way to remove a VM."

3.  **Destroy and Undefine the Network:**
    *   **Command:** `sudo virsh net-destroy hostonly`
    *   **Command:** `sudo virsh net-undefine hostonly`
    *   **Explanation:** "Finally, I will shut down and remove the custom 'hostonly' network we created. This returns the hypervisor to its original state, completing the demonstration."
