# Image taken from https://github.com/turlucode/ros-docker-gui
FROM osrf/ros:humble-desktop-full-jammy

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y gnupg2 curl lsb-core vim wget python3-pip libpng16-16 libjpeg-turbo8 libtiff5 \
    # Base tools
    cmake \
    build-essential \
    git \
    unzip \
    pkg-config \
    python3-dev \
    # OpenCV dependencies
    python3-numpy \
    # Pangolin dependencies
    libgl1-mesa-dev \
    libglew-dev \
    libpython3-dev \
    libeigen3-dev \
    apt-transport-https \
    ca-certificates\
    software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Build OpenCV
RUN apt-get update && \
    apt-get install -y python3-dev python3-numpy python2-dev libavcodec-dev libavformat-dev libswscale-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libgtk-3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 4.4.0 && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_EXAMPLES=OFF  -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j8 && make install && \
    cd / && rm -rf /tmp/opencv

# Build Pangolin
RUN cd /tmp && git clone https://github.com/stevenlovegrove/Pangolin && \
    cd Pangolin && git checkout v0.9.1 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++14 -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j8 && make install && \
    cd / && rm -rf /tmp/Pangolin

RUN apt-get update && \
    apt-get update && apt-get install -y ros-humble-pcl-ros tmux ros-humble-nav2-common x11-apps nano gdb gdbserver ros-humble-rmw-cyclonedds-cpp ros-humble-cv-bridge ros-humble-image-transport ros-humble-image-common ros-humble-vision-opencv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY ORB_SLAM3 /workspace/ORB_SLAM3
COPY src /workspace/colcon_ws/src

# Build ORB-SLAM3 with its dependencies.
RUN . /opt/ros/humble/setup.sh && cd /workspace/ORB_SLAM3 && ./build.sh
RUN . /opt/ros/humble/setup.sh && cd /workspace/colcon_ws/ && colcon build --symlink-install

COPY docker/ros_entrypoint.sh /ros_entrypoint.sh
COPY docker/ros_env_vars.sh /ros_env_vars.sh
RUN chmod +x /ros_entrypoint.sh /ros_env_vars.sh
ENTRYPOINT ["/ros_entrypoint.sh"]