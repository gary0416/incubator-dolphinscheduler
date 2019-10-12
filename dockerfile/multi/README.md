# DolphinScheduler in multi docker containers
purpose: easier to scale and maintenance.

## docker-compose dir
start DolphinScheduler by docker
- docker-compose/docker-compose.yml: start DolphinScheduler all components with one zookeeper for testing env.

single component is in sub folder.

## dockerfile dir
build docker images
- dockerfile/api: build DolphinScheduler UI image.
- dockerfile/common: build DolphinScheduler Master/Worker and Logger/Alert server image.
- dockerfile/api: build DolphinScheduler API server image. 
Init MySQL DB is in this container.Did not use a separate init container for now.
