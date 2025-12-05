# ROS2 Humble + CUDA 12.2 + Contact-GraspNet Docker

Docker environment for robotics development with ROS2 Humble, CUDA support, PyTorch, and Contact-GraspNet.

If you're new to Docker, check out my [Docker Study Notes](https://www.notion.so/Docker-Study-Notes-2bc485bc9dad80328a94e77ab3be85cf?source=copy_link).

## Prerequisites

- Docker
- NVIDIA Container Toolkit
- NVIDIA GPU with CUDA support

<details>
<summary>Installation Instructions</summary>

### Docker Installation

Follow [official installation guide](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

**Step 1: Add Docker's official GPG key**
```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

**Step 2: Add the repository to Apt sources**
```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

**Step 3: Install Docker**
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Step 4: Verify installation**
```bash
sudo systemctl status docker
sudo docker run hello-world
```

### NVIDIA Container Toolkit Installation

Follow [official installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

**Step 1: Install prerequisites**
```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends curl gnupg2
```

**Step 2: Configure the production repository**
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
```

```bash
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

**Step 3: Update and install**
```bash
sudo apt-get update
```

```bash
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.18.1-1
sudo apt-get install -y \
    nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
```

**Step 4: Configure Docker runtime**
```bash
sudo nvidia-ctk runtime configure --runtime=docker
```

```bash
sudo systemctl restart docker
```

</details>

## Build

```bash
docker build -t <your-image-name> .
```

**Example:**
```bash
docker build -t ros2-cuda-grasp .
```

## Run

### Basic Usage
```bash
docker run -it --rm \
  --gpus all \
  --runtime=nvidia \
  --net=host \
  --name <container-name> \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
  <your-image-name>
```

**Example:**
```bash
docker run -it --rm \
  --gpus all \
  --runtime=nvidia \
  --net=host \
  --name ros2-dev \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
  ros2-cuda-grasp
```

### With Workspace Mount
```bash
docker run -it --rm \
  --gpus all \
  --runtime=nvidia \
  --net=host \
  --name <container-name> \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
  -v /path/to/your/workspace:/home/cuda12/ros2_ws/src/<workspace-name> \
  <your-image-name>
```

**Example:**
```bash
docker run -it --rm \
  --gpus all \
  --runtime=nvidia \
  --net=host \
  --name ros2-dev \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
  -v ~/my_robot_ws:/home/cuda12/ros2_ws/src/my_robot_ws \
  ros2-cuda-grasp
```

### With Multiple Mounts
```bash
docker run -it --rm \
  --gpus all \
  --runtime=nvidia \
  --net=host \
  --name <container-name> \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
  -v /path/to/workspace:/home/cuda12/ros2_ws/src/<workspace-name> \
  -v /path/to/data:/home/cuda12/<data-folder> \
  <your-image-name>
```

**Example:**
```bash
docker run -it --rm \
  --gpus all \
  --runtime=nvidia \
  --net=host \
  --name ros2-dev \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
  -v ~/my_robot_ws:/home/cuda12/ros2_ws/src/my_robot_ws \
  -v ~/datasets:/home/cuda12/datasets \
  ros2-cuda-grasp
```

## What's Included

- **ROS2 Humble** Desktop
- **CUDA 12.2** with PyTorch
- **Contact-GraspNet** (PyTorch implementation)
- **Useful ROS2 aliases:**
  - `cbs` - colcon build --symlink-install
  - `src` - source workspace
  - `rmbil` - clean build artifacts

## Quick Commands

### ROS2 Workspace
```bash
cd ~/ros2_ws
cbs          # Build workspace
src          # Source workspace
```

### Contact-GraspNet
```bash
cd ~/contact_graspnet_pytorch
python3 -m contact_graspnet_pytorch.inference \
    --np_path="test_data/*.npy" \
    --local_regions \
    --filter_grasps
```

## Access Running Container

```bash
docker exec -it <container-name> bash
```

**Example:**
```bash
docker exec -it ros2-dev bash
```

## Customization

- Modify `requirements.txt` for additional Python packages
- Modify `packages.txt` for additional system packages
- Change `USERNAME`, `USER_UID`, `USER_GID` build args if needed:
  ```bash
  docker build -t <your-image-name> --build-arg USERNAME=myuser --build-arg USER_UID=1001 .
  ```

## User Info

- **Username:** cuda12 (customizable)
- **Home:** /home/cuda12
- **Workspace:** ~/ros2_ws