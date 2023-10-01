# Copyright rigélblu inc. All rights reserved.

# rsync config
HOST={replace with your ip} # ie. 10.0.3.2
CONTEXT_NAME=docker-ubuntu-server

# docker config
SRC_DIR=/home/server_username/src/project
TARGET_DIR=/src

ONESHELL:
all: rsync-changes run-docker

rsync-changes:
	./rsync-changes.sh &

# ----- docker ----
docker-context:
	@# ignore error if it already exists
	-docker context create ${CONTEXT_NAME} --docker host=tcp://${HOST}:2375
	@echo

	docker context use ${CONTEXT_NAME}
	@echo

run-docker: docker-context 
	docker run --rm \
		--mount type=bind,source="${SRC_DIR}",target="${TARGET_DIR}" \
		--name "docker-remote-server" \
		mojosdk:latest
