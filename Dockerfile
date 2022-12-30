FROM dustynv/ros:noetic-pytorch-l4t-r35.1.0

ENV DEBIAN_FRONTEND noninteractive
ENV ROS_DISTRO noetic
ENV TORCH_PATH /usr/local/lib/python3.8/dist-packages/

# Install ROS
RUN apt purge -y *opencv*
RUN apt update && apt upgrade -y \
  && apt install -y \
  ros-${ROS_DISTRO}-image-transport \
  ros-${ROS_DISTRO}-cv-bridge \
  ros-${ROS_DISTRO}-tf2-py \
  ros-${ROS_DISTRO}-tf2-tools \
  ros-${ROS_DISTRO}-tf2-geometry-msgs \
  ros-${ROS_DISTRO}-tf2-sensor-msgs \
  python3-catkin-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*rm

COPY ./ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
