# FROM pytorch/pytorch:latest
#FROM nvcr.io/nvidia/pytorch:19.04-py3
FROM nvcr.io/nvidia/pytorch:20.03-py3

WORKDIR /workspace
# avoid blocking in installation of tzdata
ENV DEBIAN_FRONTEND=noninteractive
#COPY requirements.txt /tmp

#RUN pip install -r /tmp/requirements.txt && rm -rf /tmp/requirements.txt

RUN apt-get update && apt install -y lsb-release net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*rm 

# Install ROS
#  Add key
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt update &&  \
    apt install -y  ros-melodic-ros-base \
                        ros-melodic-image-transport \
                        ros-melodic-image-transport-plugins \
    python-catkin-tools python-rosdep\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*rm

# Initialize the ROS environment
RUN rosdep init && rosdep update 

# Set entry point
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod 777 /ros_entrypoint.sh
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

# Set environment variables
ENV PATH /opt/ros/melodic/bin:/usr/local/mpi/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PYTHONPATH /opt/ros/melodic/lib/python2.7/dist-packages:$PYTHONPATH
ENV ROS_DISTRO melodic

# Install LibTorch, a C++ API of PyTorch
#  - Following the instruction in https://github.com/pytorch/pytorch/blob/master/docs/libtorch.rst
#  - Use /opt/conda/bin/python because the default python can't locate necessary modules due to its configuration
RUN cd /opt/pytorch/pytorch/ && mkdir build_libtorch && cd build_libtorch \
    && /opt/conda/bin/python ../tools/build_libtorch.py

RUN echo 'alias pt-python="/opt/conda/bin/python $@"' >> ~/.bashrc

# Set entry point
RUN rm /ros_entrypoint.sh
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod 755 /ros_entrypoint.sh

RUN echo 'network_if=eth0' >> ~/.bashrc
RUN echo 'export TARGET_IP=$(LANG=C /sbin/ifconfig $network_if | grep -Eo '"'"'inet (addr:)?([0-9]*\.){3}[0-9]*'"'"' | grep -Eo '"'"'([0-9]*\.){3}[0-9]*'"'"')' >> ~/.bashrc
RUN echo 'if [ -z "$TARGET_IP" ] ; then' >> ~/.bashrc
RUN echo '      echo "ROS_IP is not set."' >> ~/.bashrc
RUN echo '      else' >> ~/.bashrc
RUN echo '            export ROS_IP=$TARGET_IP' >> ~/.bashrc
RUN echo '            fi' >> ~/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
