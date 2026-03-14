ARG ROS_DISTRO=humble
FROM ros:$ROS_DISTRO-ros-base
WORKDIR /root/

# 1. Install general packages + SSH CLIENT + Vision Libraries
RUN rm /var/lib/dpkg/info/libc-bin.* \
    && apt-get clean \
    && apt-get update \
    && apt-get install -y libc-bin \
    && apt-get install -q -y --no-install-recommends \
    libssl-dev pkg-config \
    # We only need openssh-client to use git with ssh
    tmux nano nginx wget netcat openssh-client git \
     # Added Image Transport and CV Bridge here to fix the CMake error
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-cv-bridge \
    ros-${ROS_DISTRO}-sensor-msgs \
    ros-${ROS_DISTRO}-compressed-image-transport \
    ros-${ROS_DISTRO}-mavros ros-${ROS_DISTRO}-mavros-extras ros-${ROS_DISTRO}-mavros-msgs \
    ros-${ROS_DISTRO}-geographic-msgs \
    ros-${ROS_DISTRO}-foxglove-bridge \
    python3-dev python3-pip python3-opencv \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir setuptools pip packaging -U

# 2. Research Stack (Numpy, Matplotlib)
RUN pip3 install --no-cache-dir numpy matplotlib

# [Section 3 removed: No SSH server config needed]

# 4. Gstreamer Deps
RUN apt-get update \
    && apt-get install -q -y --no-install-recommends \
    libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
    gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio \
    libgstreamer-plugins-base1.0-dev \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir setuptools==79.0.1 pip packaging -U

# 5. Ping-Python
RUN cd /root/ \
    && git clone https://github.com/bluerobotics/ping-python.git -b deployment \
    && cd ping-python \
    && git checkout 3d41ddd \
    && python3 setup.py install --user

# 6. ROS2 Workspace Build
COPY ros2_ws /root/ros2_ws
RUN cd /root/ros2_ws/ \
    && python3 -m pip install --no-cache-dir -r src/mavros_control/requirements.txt \
    && git clone https://github.com/ptrmu/ros2_shared.git --depth 1 src/ros2_shared \
    && apt-get update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && ros2 run mavros install_geographiclib_datasets.sh \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# 7. ttyd & Config Files
ADD files/install-ttyd.sh /install-ttyd.sh
RUN bash /install-ttyd.sh && rm /install-ttyd.sh
COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/index.html /usr/share/ttyd/index.html
RUN mkdir -p /site
COPY files/register_service /site/register_service
COPY files/start.sh /start.sh

# 8. RESTORED BASHRC LINES + NEW ALIASES
RUN echo "source /ros_entrypoint.sh" >> ~/.bashrc \
    && echo "set +e" >> ~/.bashrc \
    && echo "alias cb='colcon build --symlink-install && source install/setup.bash'" >> ~/.bashrc \
    && echo "alias ccb='rm -rf build/ install/ log/ && cb'" >> ~/.bashrc \
    && echo "alias cbp='colcon build --symlink-install --packages-select'" >> ~/.bashrc \
    && echo "alias si='source install/setup.bash'" >> ~/.bashrc

# 9. Labels & Entrypoint (Simplified)
LABEL version="0.0.1"
LABEL permissions='{\
  "NetworkMode": "host",\
  "HostConfig": {\
    "Binds": [\
      "/dev:/dev:rw",\
      "/usr/blueos/extensions/ros2/:/root/persistent_ws/:rw",\
      "/root/.ssh:/root/.ssh:ro"\
    ],\
    "Privileged": true,\
    "NetworkMode": "host"\
  }\
}'

# No need to expose port 22 anymore
EXPOSE 4717
# Simple entrypoint: just the original start script
ENTRYPOINT [ "/start.sh" ]