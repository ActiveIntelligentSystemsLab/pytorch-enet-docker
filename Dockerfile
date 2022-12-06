ARG VERSION
# FROM nvidia/cudagl:11.2.2-devel
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
# FROM nvcr.io/nvidia/pytorch:22.11-py3 

ENV ROS_DISTRO noetic

WORKDIR /workspace
# avoid blocking in installation of tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install ROS
#  Add key
# This is added to deal with old pubkey problem
# RUN apt-key del A4B469963BF863CC \
#     && rm /etc/apt/sources.list.d/nvidia-ml.list /etc/apt/sources.list.d/cuda.list

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

RUN git clone --recursive https://github.com/pytorch/pytorch && \
    cd pytorch && \
    pip3 install -r requirements.txt && \
    python3 setup.py develop && \
    mkdir build_libtorch && cd build_libtorch \
    && python3 ../tools/build_libtorch.py

# RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
#     apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
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
  python3-catkin-tools \
  python3-rosdep \
  python3-osrf-pycommon  \
  python3-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*rm

RUN apt install -y wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*rm
RUN wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add -

# Initialize the ROS environment
# RUN rosdep init && rosdep update 
# 
# # Set entry point
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod 777 /ros_entrypoint.sh
# 
# # Set environment variables
ENV PATH /opt/ros/${ROS_DISTRO}/bin:/usr/local/cuda/bin:$PATH
ENV PYTHONPATH /opt/ros/${ROS_DISTRO}/lib/python3/dist-packages:$PYTHONPATH
# 
# 
# ########## PyTorch ##########
# RUN pip3 install torch==1.8.1 torchvision==0.9.1
# COPY ./cudnn-local-repo-ubuntu2004-8.6.0.163_1.0-1_amd64.deb /tmp/cudnn-local-repo-ubuntu2004-8.6.0.163_1.0-1_amd64.deb
# RUN dpkg -i /tmp/cudnn-local-repo-ubuntu2004-8.6.0.163_1.0-1_amd64.deb && \
#   cp /var/cudnn-local-repo-ubuntu2004-8.6.0.163/cudnn-local-B0FE0A41-keyring.gpg /usr/share/keyrings/ && \
#   apt update && apt install -y libcudnn8-dev
# RUN pip3 install efficientnet_pytorch
# 
# RUN echo 'network_if=eth0' >> ~/.bashrc
# RUN echo 'export TARGET_IP=$(LANG=C /sbin/ifconfig $network_if | grep -Eo '"'"'inet (addr:)?([0-9]*\.){3}[0-9]*'"'"' | grep -Eo '"'"'([0-9]*\.){3}[0-9]*'"'"')' >> ~/.bashrc
# RUN echo 'if [ -z "$TARGET_IP" ] ; then' >> ~/.bashrc
# RUN echo '      echo "ROS_IP is not set."' >> ~/.bashrc
# RUN echo '      else' >> ~/.bashrc
# RUN echo '            export ROS_IP=$TARGET_IP' >> ~/.bashrc
# RUN echo '            fi' >> ~/.bashrc

# RUN pip3 install python-dateutil==2.8.1
# RUN pip3 install -r https://raw.githubusercontent.com/ultralytics/yolov5/master/requirements.txt
# RUN pip3 install timm
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
ENV Torch_INST_ROOT "/workspace/pytorch/"

ENTRYPOINT ["/ros_entrypoint.sh"]
