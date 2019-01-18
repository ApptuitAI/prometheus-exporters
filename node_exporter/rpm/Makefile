# Makefile for building rpm packages for node_exporter

OS := linux
RPM_BINTRAY_URL := https://dl.bintray.com/apptuitai/rpm/$(RPM_PACKAGE_NAME)/
PKG_BASENAME := $(RPM_PACKAGE_NAME)-$(PACKAGE_VERSION)-$(PACKAGE_REVISION)
RPM_TARGET_ARCH := $(RPM_TARGET_$(RPM_SRC_ARCH)_ARCH)
RPM := $(PKG_BASENAME).$(RPM_TARGET_ARCH).rpm
SRC_PKG_BASE_URL := https://github.com/prometheus/$(SRC_PACKAGE_NAME)/releases/download/v$(PACKAGE_VERSION)/
SRC_PKG_BASE_NAME := $(SRC_PACKAGE_NAME)-$(PACKAGE_VERSION).$(OS)-$(RPM_SRC_ARCH)
SRC_PKG_FILE_NAME := $(SRC_PKG_BASE_NAME).tar.gz
SRC_PKG_URL := $(SRC_PKG_BASE_URL)$(SRC_PKG_FILE_NAME)

all: clean check dlsrcpkg rpm

clean:
	rm -fr build/
	rm -fr build-tmp/
	rm -f dist/$(RPM)

check: ;
#	curl --output /dev/null --silent --head --fail ${RPM_BINTRAY_URL} || exit 1

dlsrcpkg:
	mkdir -p build-tmp/
	cd build-tmp/ && curl -L -O $(SRC_PKG_URL) && tar -zxvf $(SRC_PKG_FILE_NAME) && cd ..

rpm:
	mkdir -p dist/
	mkdir -p build/usr/lib/systemd/system/
	mkdir -p build/etc/init.d/
	cp -r ../../common/assets/* build/
	cp ../../common/rpm/assets/etc/init.d/template-exporter build/etc/init.d/$(RPM_PACKAGE_NAME)
	cp ../../common/rpm/spec/template-exporter.spec build/$(RPM_PACKAGE_NAME)-t.spec
	cp ../../common/assets/usr/lib/systemd/system/template-exporter.service build/usr/lib/systemd/system/$(PACKAGE_NAME).service
	sed -i \
			-e 's/@GIT_VERSION@/$(GIT_VERSION)/g' \
			-e 's/@GIT_FULLSHA1@/$(GIT_FULLSHA1)/g' \
			-e 's/@GIT_SHORTSHA1@/$(GIT_SHORTSHA1)/g' \
			-e 's/@SRC_PKG_BASE_NAME@/$(SRC_PKG_BASE_NAME)/g' \
			-e 's/@SRC_PACKAGE_NAME@/$(SRC_PACKAGE_NAME)/g' \
			-e 's/@PACKAGE_NAME@/$(PACKAGE_NAME)/g' \
			-e 's/@PACKAGE_DESCRIPTION@/$(PACKAGE_DESCRIPTION)/g' \
			-e 's/@PACKAGE_VERSION@/$(PACKAGE_VERSION)/g' \
			-e 's/@PACKAGE_REVISION@/$(PACKAGE_REVISION)/g' \
			-e 's/@PACKAGE_LICENSE@/$(PACKAGE_LICENSE)/g' \
			-e 's/@RPM_PACKAGE_NAME@/$(RPM_PACKAGE_NAME)/g' \
			-e 's/@RPM_TARGET_ARCH@/$(RPM_TARGET_ARCH)/g' \
		-e 's/@PACKAGE_SYSTEMD_SERVICE_DEPS@//g' \
		-e 's/@EXPORTER_ENVIRONMENT_VARIABLES@//g' \
		build/$(RPM_PACKAGE_NAME)-t.spec build/usr/lib/systemd/system/$(PACKAGE_NAME).service build/etc/init.d/$(RPM_PACKAGE_NAME); \
	rpmbuild --define "_topdir %(pwd)/build" --target ${RPM_TARGET_ARCH} -bb build/$(RPM_PACKAGE_NAME)-t.spec
	mv build/RPMS/${RPM_TARGET_ARCH}/${RPM} dist/

lint:
	lintian --no-tag-display-limit dist/$(RPM)
