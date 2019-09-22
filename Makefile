NAME=aisl/pytorch
VERSION=latest
CONTAINER_NAME=pytorch-enet

build : 
	docker build -t $(NAME):$(VERSION) .

restart: stop start

start:
	docker start $(CONTAINER_NAME)
run:
	docker run -it \
    		--runtime=nvidia \
    		-v /media/data/dataset/matsuzaki:/tmp/dataset \
    		-v /home/aisl/matsuzaki/PyTorch-ENet:/root/PyTorch-ENet \
		-p 60006:6006 \
		--shm-size 12G \
		--name $(CONTAINER_NAME) \
		$(NAME):$(VERSION)
					
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

