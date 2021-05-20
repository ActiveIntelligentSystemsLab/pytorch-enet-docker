#!/bin/sh
# docker_ros_setup.sh
#   set the ROS-related environment variables
#   according to the docker container running 'roscore'

#
# Get an (virtual) IP address of a docker container named "master"
#
IP_ADDRESS=`docker inspect master | grep -E "IPAddress" | grep -o "[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+"`
export ROS_MASTER_URI=http://$IP_ADDRESS:11311
export ROS_IP="172.19.0.1" 

echo "Docker ROS setup : $IP_ADDRESS"
echo "ROS IP           : $ROS_IP"