ARG VERSION
FROM nvidia/cuda:11.7.0-cudnn8-devel-ubuntu20.04

ENV ROS_DISTRO noetic

WORKDIR /workspace
# avoid blocking in installation of tzdata
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt install -y \
  lsb-release \
  net-tools \
  curl \
  python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*rm 

# # Install LibTorch, a C++ API of PyTorch
#  - Following the instruction in https://github.com/pytorch/pytorch/blob/master/docs/libtorch.rst
#  - Use /opt/conda/bin/python because the default python can't locate necessary modules due to its configuration
RUN apt install -y git libssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*rm

RUN git clone --recursive https://github.com/Kitware/CMake && \
  cd CMake && ./bootstrap && make -j$(nproc) && make install

RUN git clone --recursive https://github.com/pytorch/pytorch -b v1.13.1 && \
  cd pytorch && \
  pip3 install -r requirements.txt && \
  python3 setup.py develop && \
  mkdir build_libtorch && cd build_libtorch \
  && python3 ../tools/build_libtorch.py

RUN apt update && \
  apt install -y \
  libjpeg-turbo8-dev \
  libpng-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*rm

RUN git clone --recursive https://github.com/pytorch/vision && \
  cd vision && \
  python3 setup.py install

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN apt update && \
  apt install -y \
  ros-${ROS_DISTRO}-ros-base \
  ros-${ROS_DISTRO}-image-transport \
  ros-${ROS_DISTRO}-image-transport-plugins \
  ros-${ROS_DISTRO}-usb-cam \
  ros-${ROS_DISTRO}-tf2-py \
  ros-${ROS_DISTRO}-tf2-tools \
  ros-${ROS_DISTRO}-tf2-geometry-msgs \
  ros-${ROS_DISTRO}-tf2-sensor-msgs \
  python3-catkin-tools \
  python3-rosdep \
  python3-osrf-pycommon  \
  python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*rm

RUN pip3 install scikit-image

# Set entry point
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod 777 /ros_entrypoint.sh

# Set environment variables
ENV PATH /opt/ros/${ROS_DISTRO}/bin:/usr/local/cuda/bin:$PATH
ENV PYTHONPATH /opt/ros/${ROS_DISTRO}/lib/python3/dist-packages:$PYTHONPATH
ENV Torch_INST_ROOT "/workspace/pytorch/"

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
