NAME=jetson-rostorch-docker
VERSION=r32.6.1
CONTAINER_NAME=pytorch-ros

build : 
	docker build -t $(NAME):$(VERSION) .

restart: stop start

start:
	docker start $(CONTAINER_NAME)
					
contener=`docker ps -a -q`
image=`docker images | awk '/^<none>/ { print $$3 }'`
	
clean:
	@if [ "$(image)" != "" ] ; then \
		docker rmi $(image); \
	fi
	@if [ "$(contener)" != "" ] ; then \
		docker rm $(contener); \
	fi
	
stop:
	docker stop $(CONTAINER_NAME)
	
rm:
	docker rm -f $(CONTAINER_NAME)
attach:
	docker start $(CONTAINER_NAME) && docker exec -it $(CONTAINER_NAME) /bin/bash
	
logs:
	docker logs $(CONTAINER_NAME)

