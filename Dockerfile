# FROM pytorch/pytorch:latest
#FROM nvcr.io/nvidia/pytorch:19.04-py3
FROM nvcr.io/nvidia/pytorch:21.02-py3

WORKDIR /workspace
# avoid blocking in installation of tzdata
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt install -y \
  lsb-release \
  net-tools \
  libgl1-mesa-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*rm 
#
# Install ROS via RoboStack, Conda-based ROS installation
#
ARG env_name=ros_env
RUN conda init bash 
RUN conda update -c defaults conda 
RUN conda install -c conda-forge mamba 
RUN mamba create -n ${env_name} --clone base

# Override default shell and use bash
#SHELL ["conda", "run", "-n", "ros_env", "/bin/bash", "-c"]

# Activate environment
ENV CONDA_DEFAULT_ENV ${env_name}

# Switch default environment
RUN echo "conda activate ${env_name}" >> ~/.bashrc
ENV PATH /opt/conda/envs/${env_name}/bin:$PATH

# this adds the conda-forge channel to the new created environment configuration 
RUN conda config --env --add channels conda-forge
# and the robostack channels
RUN conda config --env --add channels robostack
RUN conda config --env --add channels robostack-experimental

# Install the version of ROS you are interested in:
#RUN mamba install  
RUN mamba install python=3.8
RUN mamba install ros-noetic-desktop

# optionally, install some compiler packages if you want to e.g. build packages in a colcon_ws:
#RUN mamba install compilers cmake pkg-config make ninja colcon-common-extensions

# on Linux and osx (but not Windows) for ROS1 you might want to:
RUN mamba install catkin_tools

# reload environment to activate required scripts before running anything
# on Windows, please restart the Anaconda Prompt / Command Prompt!
#RUN conda deactivate
#RUN conda activate ros_env

# if you want to use rosdep, also do:
RUN mamba install rosdep
RUN rosdep init && rosdep update

# Build LibTorch, a C++ API of PyTorch
#  - Following the instruction in https://github.com/pytorch/pytorch/blob/master/docs/libtorch.rst
#  - Use /opt/conda/bin/python because the default python can't locate necessary modules due to its configuration
RUN cd /opt/pytorch/pytorch/ && mkdir build_libtorch && cd build_libtorch \
    && python ../tools/build_libtorch.py

#RUN conda install pytorch torchvision -c pytorch

#RUN echo 'alias pt-python="/opt/conda/bin/python $@"' >> ~/.bashrc

# Set entry point
#RUN rm /ros_entrypoint.sh
#COPY ./ros_entrypoint.sh /ros_entrypoint.sh
#RUN chmod 755 /ros_entrypoint.sh
#
#ENTRYPOINT ["/ros_entrypoint.sh"]
