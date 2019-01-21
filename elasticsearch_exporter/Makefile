# Makefile for building linux packages for elasticsearch_exporter

export PACKAGE_DESCRIPTION := Prometheus Elasticsearch metrics exporter for apptuit.ai

export SRC_PACKAGE_NAME := ${PACKAGE_MODULE}

export PACKAGE_NAME := elasticsearch-exporter
export DEB_PACKAGE_NAME := ${PACKAGE_NAME}
export RPM_PACKAGE_NAME := ${PACKAGE_NAME}

export PACKAGE_LICENSE := Apache-2.0

export DEB_TARGET_amd64_ARCH := amd64
export DEB_TARGET_arm64_ARCH := arm64
export DEB_TARGET_armv7_ARCH := armhf
export DEB_TARGET_ppc64le_ARCH := ppc64el
export DEB_TARGET_mips64le_ARCH := mips64el

export RPM_TARGET_amd64_ARCH := x86_64
export RPM_TARGET_arm64_ARCH := aarch64
export RPM_TARGET_armv7_ARCH := armv7
export RPM_TARGET_ppc64_ARCH := ppc64
export RPM_TARGET_ppc64le_ARCH := ppc64le

export GIT_VERSION := \
  $(shell git rev-list --pretty=format:%h HEAD --max-count=1 | sed 1d || echo unknown)
export GIT_FULLSHA1 := \
  $(shell git rev-list --pretty=format:%H HEAD --max-count=1 | sed 1d || echo unknown)
export GIT_SHORTSHA1 := \
  $(shell git rev-list --pretty=format:%h HEAD --max-count=1 | sed 1d || echo unknown)

all: deb rpm

deb:
	make 'DEB_SRC_ARCH=amd64' -C deb/
	make 'DEB_SRC_ARCH=arm64' -C deb/
	make 'DEB_SRC_ARCH=armv7' -C deb/
	make 'DEB_SRC_ARCH=ppc64le' -C deb/
	make 'DEB_SRC_ARCH=mips64le' -C deb/

rpm:
	make 'RPM_SRC_ARCH=amd64' -C rpm/
	make 'RPM_SRC_ARCH=arm64' -C rpm/
	make 'RPM_SRC_ARCH=armv7' -C rpm/
	make 'RPM_SRC_ARCH=ppc64' -C rpm/
	make 'RPM_SRC_ARCH=ppc64le' -C rpm/

lint:
	make 'DEB_SRC_ARCH=amd64' -C deb/ lint
	make 'DEB_SRC_ARCH=arm64' -C deb/ lint
	make 'DEB_SRC_ARCH=armv7' -C deb/ lint
	make 'DEB_SRC_ARCH=ppc64le' -C deb/ lint
	make 'DEB_SRC_ARCH=mips64le' -C deb/ lint

.PHONY: all deb rpm lint
