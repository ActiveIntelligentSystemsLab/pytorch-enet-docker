# enet-pytorch-docker

Docker environment to use [pytorch_ros](https://github.com/ActiveIntelligentSystemsLab/pytorch_enet_ros/)

# How to use
## Building the image
```
make build
```

## Running the ROS nodes in the container

1. Build (`catkin build`)
```
docker-compose up catkin-build
```

2. Launch `roscore`
```
docker-compose up master
```

3. Run a ROS node (`roslaunch pytorch_ros pytorch_enet_ros.launch`)
```
docker-compose up pytorch-ros
```

4. (Optional) Run `sh docker_ros_setup.sh` to set the environment variables in the host.
   
   If you want to run other nodes in the host and let them communicate with the nodes in the container, this is necessary.