FROM ros:humble-ros-base

# 1. Install minimal GUI dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends     bash-completion     build-essential     python3-colcon-common-extensions     x11-apps     mesa-utils     && rm -rf /var/lib/apt/lists/*

# 2. Set up the environment
WORKDIR /ros2_ws
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
