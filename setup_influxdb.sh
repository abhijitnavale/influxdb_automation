#!/usr/bin/sh

# run as root only
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# for the time being only 64 bit platform supported
ARCH=$(uname -i)
if [[ "$ARCH" != "x86_64" ]]; then
    echo "Platform Not Supported."
    exit 1
fi

echo "-----------------------------------------------------------------"
echo "Setting up InfluxDB, Telegraph and Graphana On This Computer"
echo

function debian_install {
    if [ -e influxdb_1.2.2_amd64.deb ]; then
        echo "InfluxDB Already Downloaded. Skipping new Download."
    else
        echo "Downloading Debian Package"
        wget https://dl.influxdata.com/influxdb/releases/influxdb_1.2.2_amd64.deb
    fi

    echo "Installing InfluxDB Package..."
    dpkg -i influxdb_1.2.2_amd64.deb

    echo "Starting InfluxDB Service..."
    if [[ `systemctl` =~ -\.mount ]]; then
        systemctl start influxdb
    else
        service influxdb start
    fi
}

function redhat_install {
    if [ -e influxdb-1.2.2.x86_64.rpm ]; then
        echo "InfluxDB Already Downloaded. Skipping new Download."
    else
        echo "Downloading InfluxDB Package"
        wget https://dl.influxdata.com/influxdb/releases/influxdb-1.2.2.x86_64.rpm
    fi
    
    echo "Installing InfluxdDB Package..."
    yum localinstall influxdb-1.2.2.x86_64.rpm -y
    
    echo "Starting InfluxDB Service..."
    if [[ `systemctl` =~ -\.mount ]]; then
        systemctl start influxdb
    else
        service influxdb start
    fi
    
}

if [ -f /etc/debian_version ]; then
    echo "Debian Family Distribution Found"
    debian_install
elif [ -f /etc/redhat-release ]; then
    echo "Redhat Family Distrubition Found"
    redhat_install
else
    echo "UNSUPPORTED DISTRIBUTION! This is something else"
    exit 1
fi

echo
echo "Report Bugs at https://github.com/abhijitnavale/influxdb_automation"
echo "-----------------------------------------------------------------"
