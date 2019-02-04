# Makefile for building linux packages for mysqld_exporter

export PACKAGE_DESCRIPTION := Prometheus Cassandra metrics exporter for apptuit.ai

export SRC_PACKAGE_NAME := cassandra_exporter

export PACKAGE_NAME := cassandra-exporter
export DEB_PACKAGE_NAME := ${PACKAGE_NAME}
export RPM_PACKAGE_NAME := ${PACKAGE_NAME}

export PACKAGE_LICENSE := Apache-2.0

export DEB_TARGET_noarch_ARCH := all

export RPM_TARGET_noarch_ARCH := noarch

export GIT_VERSION := \
  $(shell git rev-list --pretty=format:%h HEAD --max-count=1 | sed 1d || echo unknown)
export GIT_FULLSHA1 := \
  $(shell git rev-list --pretty=format:%H HEAD --max-count=1 | sed 1d || echo unknown)
export GIT_SHORTSHA1 := \
  $(shell git rev-list --pretty=format:%h HEAD --max-count=1 | sed 1d || echo unknown)

all: deb rpm

deb:
	make 'DEB_SRC_ARCH=noarch' -C deb/

rpm:
	make 'RPM_SRC_ARCH=noarch' -C rpm/

lint:
	make 'DEB_SRC_ARCH=noarch' -C deb/ lint

.PHONY: all deb rpm lint
