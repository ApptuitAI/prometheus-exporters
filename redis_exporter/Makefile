# Makefile for building linux packages for redis_exporter

export PACKAGE_DESCRIPTION := Prometheus Redis metrics exporter for apptuit.ai

export SRC_PACKAGE_NAME := ${PACKAGE_MODULE}

export PACKAGE_NAME := redis-exporter
export DEB_PACKAGE_NAME := ${PACKAGE_NAME}
export RPM_PACKAGE_NAME := ${PACKAGE_NAME}

export PACKAGE_LICENSE := MIT

export DEB_TARGET_amd64_ARCH := amd64

export RPM_TARGET_amd64_ARCH := x86_64

export GIT_VERSION := \
  $(shell git rev-list --pretty=format:%h HEAD --max-count=1 | sed 1d || echo unknown)
export GIT_FULLSHA1 := \
  $(shell git rev-list --pretty=format:%H HEAD --max-count=1 | sed 1d || echo unknown)
export GIT_SHORTSHA1 := \
  $(shell git rev-list --pretty=format:%h HEAD --max-count=1 | sed 1d || echo unknown)

all: deb rpm

deb:
	make 'DEB_SRC_ARCH=amd64' -C deb/

rpm:
	make 'RPM_SRC_ARCH=amd64' -C rpm/

lint:
	make 'DEB_SRC_ARCH=amd64' -C deb/ lint

.PHONY: all deb rpm lint
