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
autosign = /etc/puppetlabs/puppet/autosign.sh
EOF

cat > /etc/puppetlabs/puppet/autosign.sh <<'SCRIPT'
#!/bin/bash
openssl req -noout -text | grep -q ${autosign_token}
SCRIPT

chmod +x /etc/puppetlabs/puppet/autosign.sh

apt install -y git
git clone https://github.com/rangerpar/terraform-puppet-aws.git /tmp/repo
cp -r /tmp/repo/puppet/modules/* /etc/puppetlabs/code/environments/production/modules/
cp /tmp/repo/puppet/manifests/site.pp /etc/puppetlabs/code/environments/production/manifests/
chown -R root:root /etc/puppetlabs/code/environments/production/
chmod -R a+rX /etc/puppetlabs/code/environments/production/


systemctl enable --now puppetserver