#!/bin/bash
set -euxo pipefail

cd /tmp

wget https://apt.voxpupuli.org/openvox8-release-ubuntu24.04.deb
dpkg -i openvox8-release-ubuntu24.04.deb
apt update
apt install -y openvox-server

sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/' /etc/default/puppetserver

cat >> /etc/puppetlabs/puppet/puppet.conf <<EOF

[main]
server = $(hostname -f)
EOF

systemctl enable --now puppetserver