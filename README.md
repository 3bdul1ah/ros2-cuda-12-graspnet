# ROS2 Humble + CUDA 12.2 + Contact-GraspNet Docker

Docker environment for robotics development with ROS2 Humble, CUDA support, PyTorch, and Contact-GraspNet.

## Prerequisites

- Docker
- NVIDIA Docker Runtime (`nvidia-docker2`)
- NVIDIA GPU with CUDA support

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
  --name <container-name> \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  <your-image-name>
```

**Example:**
```bash
docker run -it --rm \
  --gpus all \
  --name ros2-dev \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  ros2-cuda-grasp
```

### With Workspace Mount
```bash
docker run -it --rm \
  --gpus all \
  --name <container-name> \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v /path/to/your/workspace:/home/cuda12/ros2_ws/src/<workspace-name> \
  <your-image-name>
```

**Example:**
```bash
docker run -it --rm \
  --gpus all \
  --name ros2-dev \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v ~/my_robot_ws:/home/cuda12/ros2_ws/src/my_robot_ws \
  ros2-cuda-grasp
```

### With Multiple Mounts
```bash
docker run -it --rm \
  --gpus all \
  --name <container-name> \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v /path/to/workspace:/home/cuda12/ros2_ws/src/<workspace-name> \
  -v /path/to/data:/home/cuda12/<data-folder> \
  <your-image-name>
```

**Example:**
```bash
docker run -it --rm \
  --gpus all \
  --name ros2-dev \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
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

# Dev Container Quick Reference

## Start/Stop Container
```bash
cd ~/Abdullah
docker compose -f docker/docker-compose.yml start
docker compose -f docker/docker-compose.yml stop
```

## If Stop Fails (Permission Denied)
```bash
docker ps
docker inspect dev_ws | grep Pid
sudo kill -9 <PID>
docker compose -f docker/docker-compose.yml stop
```

## Open in VS Code
```bash
cd ~/Abdullah
code .
# F1 → "Dev Containers: Attach running container"
```

## Folder Mapping (Volumes)
```
~/Abdullah/ros2_ws/                   → /home/cuda12/ros2_ws
~/Abdullah/testing/                   → /home/cuda12/testing
~/Abdullah/contact_graspnet_pytorch/  → /home/cuda12/contact_graspnet_pytorch
~/Abdullah/rai/                       → /home/cuda12/rai
```

## Add More Volumes
Edit `docker/docker-compose.yml`:
```yaml
volumes:
  - ../ros2_ws:/home/cuda12/ros2_ws
  - ../new_folder:/home/cuda12/new_folder  # Add this
```

Create folder and rebuild:
```bash
mkdir ~/Abdullah/new_folder
docker compose -f docker/docker-compose.yml down
docker compose -f docker/docker-compose.yml up -d
```

## Rebuild Container
```bash
docker compose -f docker/docker-compose.yml down
docker compose -f docker/docker-compose.yml up -d
```

## Check Status
```bash
docker ps        # Running
docker ps -a     # All
```