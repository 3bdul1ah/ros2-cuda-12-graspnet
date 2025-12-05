# ROS 2 Humble + CUDA 12.2 + Contact-GraspNet Docker

Docker environment for robotics development with **ROS 2 Humble**, **CUDA 12.2**, **PyTorch**, and **Contact-GraspNet**, with support for GPU-accelerated perception and common GUI tools (RViz2, Open3D, gedit) via X11.

If you're new to Docker, you may find these notes helpful:  
[Docker Study Notes](https://www.notion.so/Docker-Study-Notes-2bc485bc9dad80328a94e77ab3be85cf?source=copy_link)

---

## Prerequisites

<details>
<summary><strong>Docker Installation</strong></summary>

Follow the official Docker installation guide for Ubuntu:  
https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

### Step 1: Add Docker's official GPG key

```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### Step 2: Add the repository to Apt sources

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

### Step 3: Install Docker

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 4: Verify installation

```bash
sudo systemctl status docker
sudo docker run hello-world
```

</details>

<details>
<summary><strong>NVIDIA Container Toolkit Installation</strong></summary>

Follow the official installation guide:  
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

### Step 1: Install prerequisites

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends curl gnupg2
```

### Step 2: Configure the production repository

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
```

```bash
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

### Step 3: Update and install

```bash
sudo apt-get update
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.18.1-1
sudo apt-get install -y nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
```

### Step 4: Configure Docker runtime

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

</details>

---

## Clone

Clone the repository:

```bash
git clone https://github.com/3bdul1ah/ros2-cuda-12-graspnet.git
cd ros2-cuda-12-graspnet
```

---

## Build

Build the image from the Dockerfile in this repository:

```bash
docker build -t <your-image-name> .
```

**Example:**

```bash
docker build -t ros2-cuda12:grasp .
```

---

## Run

### Basic Usage (quick test, temporary container)

This starts a container that is removed when it exits. It enables GPU access, host networking, and X11 GUI support.

```bash
docker run -it --rm --gpus all --runtime=nvidia --net=host --name <container-name> -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR <your-image-name>
```

**Example:**

```bash
docker run -it --rm --gpus all --runtime=nvidia --net=host --name ros2-test -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR ros2-cuda12:grasp
```

---

### With Workspace Mount

Mount a local ROS 2 workspace into the container for development.

```bash
docker run -it --rm --gpus all --runtime=nvidia --net=host --name <container-name> -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR -v /path/to/your/workspace:/home/cuda12/ros2_ws/<target> <your-image-name>
```

**Example:**

```bash
docker run -it --rm --gpus all --runtime=nvidia --net=host --name ros2-dev -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR -v ~/my_robot_ws:/home/cuda12/ros2_ws/src/somepkg ros2-cuda12:grasp
```

---

## Persistent (Saved) Container

If you want a container that persists (not removed on exit):

1. **Run it in detached mode (`-d`) and remove `--rm`:**

   ```bash
   docker run -it -d --gpus all --runtime=nvidia --net=host -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR --name <container-name> ros2-cuda12:grasp
   ```

2. **Attach to the running container later:**

   ```bash
   docker exec -it <container-name> bash
   ```

This way, any changes inside the container (e.g., built workspaces under `/home/cuda12/ros2_ws`) will persist between sessions.

---

## RViz2 Usage Note

If RViz2 fails to start due to Qt platform or GLX errors, try unsetting `QT_QPA_PLATFORM` in that terminal:

```bash
unset QT_QPA_PLATFORM
rviz2
```

This is often necessary if `QT_QPA_PLATFORM` was set to `offscreen` for headless tools such as Open3D.

---

## Access Running Container

At any point, to open a shell into a running container:

```bash
docker exec -it <container-name> bash
```
