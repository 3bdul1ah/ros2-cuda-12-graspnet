FROM nvidia/cuda:12.2.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ROS_DISTRO=humble \
    QT_QPA_PLATFORM=xcb \
    QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb

SHELL ["/bin/bash", "-c"]

# Base Tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales lsb-release software-properties-common \
    curl gnupg2 sudo git python3-pip \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LANG=${LANG} LC_ALL=${LC_ALL} \
    && add-apt-repository universe \
    && rm -rf /var/lib/apt/lists/*

# ROS2 Humble
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    python3-rosdep ros-dev-tools \
    gedit x11-apps \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init && rosdep update

# Create User
ARG USERNAME=cuda12
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Python Requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

# System Dependencies
COPY packages.txt /tmp/packages.txt
RUN apt-get update && \
    xargs -a /tmp/packages.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# PyTorch CUDA 12.1
USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN pip3 install --no-cache-dir \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121

# Contact-GraspNet
RUN git clone https://github.com/elchun/contact_graspnet_pytorch.git

RUN sed -i 's/^from data import load_available_input_data/from contact_graspnet_pytorch.data import load_available_input_data/' \
    /home/${USERNAME}/contact_graspnet_pytorch/contact_graspnet_pytorch/inference.py && \
    sed -i 's/^import mesh_utils/import contact_graspnet_pytorch.mesh_utils/' \
    /home/${USERNAME}/contact_graspnet_pytorch/contact_graspnet_pytorch/visualization_utils_o3d.py && \
    sed -i 's/gripper = mesh_utils\.create_gripper/gripper = contact_graspnet_pytorch.mesh_utils.create_gripper/' \
    /home/${USERNAME}/contact_graspnet_pytorch/contact_graspnet_pytorch/visualization_utils_o3d.py

RUN echo 'export PYTHONPATH="$PYTHONPATH:$HOME/contact_graspnet_pytorch"' >> /home/${USERNAME}/.bashrc && \
    echo 'export QT_QPA_PLATFORM=offscreen' >> /home/${USERNAME}/.bashrc

# ROS2 Workspace
RUN mkdir -p /home/${USERNAME}/ros2_ws/src

RUN echo 'source /opt/ros/humble/setup.bash' >> /home/${USERNAME}/.bashrc && \
    echo 'alias cbs="colcon build --symlink-install"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias src="source ~/ros2_ws/install/setup.bash"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias rmbil="rm -fr build install log"' >> /home/${USERNAME}/.bashrc

# Entrypoint
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}/ros2_ws

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]