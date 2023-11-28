include ../Makefile.Common


TAGS := annd2/go-app:1.0.0

.PHONY: docker-build
docker-build:
	docker build -t ${TAGS} .

.PHONY: docker-push
docker-push:
	docker push ${TAGS}

