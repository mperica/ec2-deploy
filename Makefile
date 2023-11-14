IMAGE_NAME ?= mperica/ec2-deploy
IMAGE_TAG ?= latest

.PHONY: all
all: build push

.PHONY: build
build:
	docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

.PHONY: push
push:
	docker login
	docker push ${IMAGE_NAME}:${IMAGE_TAG}
