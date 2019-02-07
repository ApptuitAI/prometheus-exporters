# Don't check stuff, we know exactly what we want.
%undefine __check_files

%global @SRC_PACKAGE_NAME@_dir /opt/prometheus/@SRC_PACKAGE_NAME@
%global rootdir       		%{_topdir}/..
%global @SRC_PACKAGE_NAME@ @SRC_PACKAGE_NAME@

Name:           @RPM_PACKAGE_NAME@
Group:          System/Monitoring
Version:        @PACKAGE_VERSION@
Release:        @PACKAGE_REVISION@
Distribution:   buildhash=@GIT_FULLSHA1@
License:        @PACKAGE_LICENSE@
Summary:        @RPM_PACKAGE_NAME@ - Data collection agent for apptuit.ai
URL:            https://github.com/ApptuitAI/prometheus-exporters/tree/master/@SRC_PACKAGE_NAME@
Provides:       @RPM_PACKAGE_NAME@ = @PACKAGE_VERSION@-@PACKAGE_REVISION@_@GIT_SHORTSHA1@
Packager:       Prom Exporter Maintainers <hello+promex@apptuit.ai>
Requires:       initscripts

%description
@PACKAGE_DESCRIPTION@

%install

mkdir -p %{buildroot}/usr/lib/systemd/system/
%{__install} -m 0755 -D %{rootdir}/build/usr/lib/systemd/system/@RPM_PACKAGE_NAME@.service %{buildroot}/usr/lib/systemd/system/@RPM_PACKAGE_NAME@.service

mkdir -p %{buildroot}/etc/init.d/
%{__install} -m 0755 -D %{rootdir}/build/etc/init.d/@RPM_PACKAGE_NAME@ %{buildroot}/etc/init.d/@RPM_PACKAGE_NAME@

mkdir -p %{buildroot}/etc/default/
%{__install} -m 0755 -D %{rootdir}/../assets/etc/default/@RPM_PACKAGE_NAME@ %{buildroot}/etc/default/@RPM_PACKAGE_NAME@

# Install Base files
mkdir -p %{buildroot}%{@SRC_PACKAGE_NAME@_dir}/bin/
%{__install} -m 0755 -D %{rootdir}/build-tmp/@SRC_PKG_BASE_NAME@/@SRC_PACKAGE_NAME@ %{buildroot}%{@SRC_PACKAGE_NAME@_dir}/bin/@SRC_PACKAGE_NAME@

%if "%{cassandra_exporter}" == "cassandra_exporter"
%{__install} -m 0755 -D %{rootdir}/build/opt/prometheus/jmx_exporter_base/lib/jmx_prometheus_httpserver-@PACKAGE_VERSION@-jar-with-dependencies.jar %{buildroot}/opt/prometheus/jmx_exporter_base/lib/jmx_prometheus_httpserver-@PACKAGE_VERSION@-jar-with-dependencies.jar
mkdir -p %{buildroot}%{@SRC_PACKAGE_NAME@_dir}/conf/
%{__install} -m 0755 -D %{rootdir}/build/cassandra.yml %{buildroot}%{@SRC_PACKAGE_NAME@_dir}/conf/cassandra.yml
%endif

%files

/usr/lib/systemd/system/@RPM_PACKAGE_NAME@.service
%attr(755, -, -) /etc/init.d/@RPM_PACKAGE_NAME@
%attr(600, -, -) /etc/default/@RPM_PACKAGE_NAME@
%dir %{@SRC_PACKAGE_NAME@_dir}
%{@SRC_PACKAGE_NAME@_dir}/bin/@SRC_PACKAGE_NAME@

%if "%{cassandra_exporter}" == "cassandra_exporter"
/opt/prometheus/jmx_exporter_base/lib/jmx_prometheus_httpserver-@PACKAGE_VERSION@-jar-with-dependencies.jar
%{@SRC_PACKAGE_NAME@_dir}/conf/cassandra.yml
%endif


%pre
is_systemd=0

if [ -d /run/systemd/system ]; then
   is_systemd=1
fi

if [ "$1" = "2" ]; then
    # stop previous version of @RPM_PACKAGE_NAME@ service before starting upgrade
    if [ $is_systemd -eq 1 ]
    then
		service @RPM_PACKAGE_NAME@ stop
	else
		/etc/init.d/@RPM_PACKAGE_NAME@ stop
	fi
fi

%post

is_systemd=0

if [ -d /run/systemd/system ]; then
   is_systemd=1
fi

PROMETHEUS_USER="prometheus"
PROMETHEUS_GROUP="prometheus"

if [ -z "$(getent group $PROMETHEUS_GROUP)" ]; then
  groupadd --system $PROMETHEUS_GROUP
else
  echo "Group [$PROMETHEUS_GROUP] already exists"
fi

if [ -z "$(id $PROMETHEUS_USER)" ]; then
  useradd --system --home-dir /home/prometheus --no-create-home \
  -g $PROMETHEUS_GROUP --shell /sbin/nologin $PROMETHEUS_USER
else
  echo "User [$PROMETHEUS_USER] already exists"
fi

chown -R $PROMETHEUS_USER.$PROMETHEUS_GROUP /opt/prometheus/@SRC_PACKAGE_NAME@

mkdir -p /var/log/prometheus/@SRC_PACKAGE_NAME@
chown -R $PROMETHEUS_USER.$PROMETHEUS_GROUP /var/log/prometheus/@SRC_PACKAGE_NAME@

if [ $is_systemd -eq 1 ]
then
	systemctl daemon-reload && systemctl enable @RPM_PACKAGE_NAME@
fi

chkconfig --add @RPM_PACKAGE_NAME@


%preun
is_systemd=0

if [ -d /run/systemd/system ]; then
   is_systemd=1
fi

if [ "$1" = "0" ]; then
    # stop service before starting the uninstall
    if [ $is_systemd -eq 1 ]
    then
    	service @RPM_PACKAGE_NAME@ stop
    else
    	/etc/init.d/@RPM_PACKAGE_NAME@ stop
    fi
    chkconfig --del @RPM_PACKAGE_NAME@
fi

%postun
# $1 --> if 0, then it is a deinstall
# $1 --> if 1, then it is an upgrade
if [ $1 -eq 0 ] ; then
    # This is a removal, not an upgrade
    #  $1 versions will remain after this uninstall

    # Clean up collectors
    rm -f /etc/init.d/@RPM_PACKAGE_NAME@
fi
