#!/bin/sh
set -euxo pipefail

# install the packer VIB (vSphere Installation Bundle) to automatically
# configure the system to handle packer deployments with the
# vmware-iso packer builder:
#   * enable guest ARP inspection to get their IP addresses (aka the Guest IP Hack).
#   * configure the firewall to allow vnc connections (5900-6000 ports).
# see https://github.com/umich-vci/packer-vib
#esxcli software acceptance set --level=CommunitySupported
#esxcli software vib install -v https://github.com/umich-vci/packer-vib/releases/download/v1.0.0-1/packer.vib

# create a temporary copy before directly change it.
cp /etc/vmware/esx.conf /tmp/esx.conf.orig

# delete the system uuid.
# see https://www.virtuallyghetto.com/2013/12/how-to-properly-clone-nested-esxi-vm.html
sed -i -E '/^\/system\/uuid = /d' /etc/vmware/esx.conf

# delete the MAC addresses settings.
#
# at installation time ESXi remembers the MAC addresses and will always
# use those even when we switch them at the qemu/VM level, so in order
# to be able to launch this with vagrant, we need to reset them.
#
# the MAC addresses are stored inside /etc/vmware/esx.conf, e.g.:
#
#   /net/vmkernelnic/child[0000]/mac = "52:54:00:12:34:56"
#   /net/pnic/child[0000]/mac = "52:54:00:12:34:56"
#   /net/pnic/child[0000]/virtualMac = "00:50:56:5d:29:50"
#
# see https://github.com/vagrant-libvirt/vagrant-libvirt/issues/1099
sed -i -E '/\/(mac|virtualMac) = /d' /etc/vmware/esx.conf

# show our changes.
diff -u /tmp/esx.conf.orig /etc/vmware/esx.conf || true

# configure the system to automatically set the vmk0 mac address to
# the vmnic0 mac address.
cat >/etc/rc.local.d/local.sh <<'LOCAL_SH'
#!/bin/sh
# local configuration options
# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.
# Note: This script will not be run when UEFI secure boot is enabled.
python3 <<'EOF'
import csv
import io
import subprocess
import sys
def get_csv_property(command, filter_property_name, filter_property_value, filter_property_output_name):
    p = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    for row in csv.DictReader(io.TextIOWrapper(p.stdout)):
        if row[filter_property_name] == filter_property_value:
            return row[filter_property_output_name]
vmk0_mac = get_csv_property(
    ('esxcli', '--formatter=csv', 'network', 'ip', 'interface', 'list'),
    'Name',
    'vmk0',
    'MACAddress')
vmnic0_mac = get_csv_property(
    ('esxcli', '--formatter=csv', 'network', 'nic', 'list'),
    'Name',
    'vmnic0',
    'MACAddress')
if vmk0_mac != vmnic0_mac:
    print('setting vmk0 mac address to %s...' % vmnic0_mac)
    subprocess.run(('esxcli', 'network', 'ip', 'interface', 'set', '-i', 'vmk0', '-e', 'false'))
    subprocess.run(('sed', '-i', '-E', r's,^(/net/vmkernelnic/child\[0000\]/mac) = .+,\1 = "%s",g' % vmnic0_mac, '/etc/vmware/esx.conf'))
    subprocess.run(('esxcli', 'network', 'ip', 'interface', 'set', '-i', 'vmk0', '-e', 'true'))
EOF
LOCAL_SH
