# ROS distribution to use as default
ARG ROS_DISTRO=noetic

###############################################################################################
# Base Image (stable) #
# Contains ONLY core dependencies
###############################################################################################

# Use Base Image from introlab3it/rtabmap_ros
FROM introlab3it/rtabmap_ros:${ROS_DISTRO}-latest as base
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

# Install additional apt packages (for development)
RUN apt-get update && apt-get install -y \
  cmake \
  g++ \
  git \
  python3-catkin-tools \
  python3-pip \
  wget \
  vim \
  nano \
  iputils-ping \
  python3-vcstool \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install additional pip packages (project-specific)
RUN pip3 install --upgrade pip \
&& pip3 install \
  rospkg \
  catkin_pkg

# Workspace setup (underlay/base that is not to be modified)
RUN mkdir -p /underlay_ws/src
WORKDIR /underlay_ws/src
COPY dependencies_underlay.repos .

# Import repositories if the file is not empty
RUN if [ -s dependencies_underlay.repos ]; then \
    vcs import < dependencies_underlay.repos; \
else \
    echo "No repositories to import"; \
fi

# Initialize Catkin workspace
WORKDIR /underlay_ws/src
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    catkin init

# Build the base Catkin workspace
RUN cd /underlay_ws \
 && source /opt/ros/${ROS_DISTRO}/setup.bash \
 && rosdep install -y --from-paths src --ignore-src \
 && catkin build

# Remove display warnings
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
ENV NO_AT_BRIDGE 1

# Set up the work directory and entrypoint
WORKDIR /underlay_ws
COPY ./docker/entrypoint.sh /

# Alias python3 as python
RUN ln -s /usr/bin/python3 /usr/bin/python

ENTRYPOINT [ "/entrypoint.sh" ]


###############################################################################################
# Overlay Image (frequently changed) #
# Contains project-specific dependencies and source code
###############################################################################################
FROM base as overlay

RUN apt-get update && apt-get install -y \
  gdb \
  curl \
  build-essential \
  htop \
  net-tools \
  psmisc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install additional pip packages (project-specific)
RUN pip3 install --upgrade pip \
&& pip3 install \
  rospkg \
  catkin_pkg \
  numpy \
  opencv-python

# Workspace setup (this is to be modified frequently)
RUN mkdir -p /overlay_ws/src
COPY ../packages/ /overlay_ws/src
# Initialize Catkin workspace
WORKDIR /overlay_ws/src
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    catkin init
# Build the base Catkin workspace
RUN cd /overlay_ws \
 && source /opt/ros/${ROS_DISTRO}/setup.bash \
 && rosdep install -y --from-paths src --ignore-src \
 && catkin build

# Run entrypoint
WORKDIR /overlay_ws
COPY ./docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

################################################################################################
# Development Image #
# Tools used only in development are installed here
################################################################################################
FROM overlay as dev

# Install additional apt packages (development-specific) - can add --no-install-recommends to reduce size
RUN apt-get update && apt-get install -y \
  gdbserver \
  usbutils \
  ros-${ROS_DISTRO}-rqt \
  ros-${ROS_DISTRO}-rqt-common-plugins \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Dev container arguments
ARG USERNAME=devuser
ARG UID=1000
ARG GID=${UID}

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
 && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME} \
 && mkdir -p /home/${USERNAME} \
 && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the overlay workspace to the new user
RUN chown -R ${UID}:${GID} /overlay_ws/ /underlay_ws/

# Set the user and source entrypoint in the user's .bashrc file
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc