include ../Makefile.Common


# TAGS := annd2/go-app:1.0.0
TAGS := vcr.vngcloud.vn/60108-annd2-ingress/goapp-debug:v2.0.0

.PHONY: docker-build
docker-build:
	docker build -t ${TAGS} .

.PHONY: docker-push
docker-push:
	docker push ${TAGS}

.PHONY: all
all:
	rm -rf main
	go build .
	make docker-build
	make docker-push