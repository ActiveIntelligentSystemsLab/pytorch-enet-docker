# enet-pytorch-docker
Docker environment to use [PyTorch-ENet](https://github.com/davidtvs/PyTorch-ENet)

# How to use
## Building the image
```
make build
```

## Running the codes in the container
1. Run a container and enter it.
```
make run
```

2. Run a script inside the container
  1. Example : Training with greenhouse
  ```
  cd /root/PyTorch-ENet
  python train.py -m train --save-dir save/dir --name [model_name] --dataset greenhouse --dataset-dir dataset/dir --with-unlabeled
  ```
  1. Run tensorboard
  ```
  cd /root/PyTorch-ENet
  tensorboard --logdir=./runs/  
  ```
You can now use `docker-compose` to launch both the training script and `tensorboard`.
```
docker-compose up
```
