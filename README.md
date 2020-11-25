# enet-pytorch-docker
Docker environment to use [PyTorch-ENet](https://github.com/davidtvs/PyTorch-ENet)

# How to use
## Building the image
```
make build
```

## Running the codes in the container
### Network training
1. Example : Network training
```
docker-compose up pytorch-train
```
2. Visualization using Tensorboard
```
docker-compose up tensorboard  
```

### ROS node
1. Build (`catkin build`)
```
docker-compose up build
```
2. Launch `roscore`
```
docker-compose up pytorch-ros-master
```
3. Run a ROS node (`roslaunch pytorch_enet_ros pytorch_enet_ros.launch`)
```
docker-compose up pytorch-ros-node
```
