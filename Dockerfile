# FROM pytorch/pytorch:latest
FROM nvcr.io/nvidia/pytorch:19.04-py3
MAINTAINER ShigemichiMatsuzaki <matsuzaki@aisl.cs.tut.ac.jp>

WORKDIR /workspace
COPY requirements.txt /tmp

RUN pip install tensorflow tensorboard tensorboardX torchvision moviepy
RUN pip install -r /tmp/requirements.txt && rm -rf /tmp/requirements.txt
