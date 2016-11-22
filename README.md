Demo VXLAN Configurations
===========================
This Github repository contains the configuration files necessary for setting up VXLAN on the [Reference Topology](http://github.com/cumulusnetworks/cldemo-vagrant). Two solutions are included:

 * VXLAN with head-end replication
 * VXLAN with a replication service

The flatfiles in this repository will set up a Layer 3 routing fabric between the leafs and spines, and will configure a Layer 2 VXLAN that encompasses the servers. A helper script named `push-config.py` is available to quickly deploy the flatfiles to the devices in the network, but you could just as easily copy and paste them by hand or incorporate them into an automation tool instead.

This demo and these configurations are written to be used with the [cldemo-vagrant](https://github.com/cumulusnetworks/cldemo-vagrant) reference topology.


Quickstart: Run the demo
------------------------
Before running this demo, install [VirtualBox](https://www.virtualbox.org/wiki/Download_Old_Builds) and [Vagrant](https://releases.hashicorp.com/vagrant/). The currently supported versions of VirtualBox and Vagrant can be found on the [cldemo-vagrant](https://github.com/cumulusnetworks/cldemo-vagrant).

    git clone https://github.com/cumulusnetworks/cldemo-vagrant
    cd cldemo-vagrant
    vagrant up oob-mgmt-server oob-mgmt-switch leaf01 leaf02 spine01 spine02 server01 server02
    vagrant ssh oob-mgmt-server
    sudo su - cumulus
    git clone https://github.com/cumulusnetworks/cldemo-config-vxlan
    cd cldemo-config-vxlan
    sudo ln -s  /home/cumulus/cldemo-config-vxlan /var/www/cldemo-config-vxlan
    ansible-playbook deploy-head-end-replication.yml
    ssh server01
    ping 172.16.2.101


Topology
--------
This demo runs on a spine-leaf topology with two single-attached hosts. The helper script `push-config.py` requires an out-of-band management network that provides access to eth0 on all of the in-band devices.

         +------------+       +------------+
         | spine01    |       | spine02    |
         |            |       |            |
         +------------+       +------------+
         swp1 |    swp2 \   / swp1    | swp2
              |           X           |
        swp51 |   swp52 /   \ swp51   | swp52
         +------------+       +------------+
         | leaf01     |       | leaf02     |
         |            |       |            |
         +------------+       +------------+
         swp1 |                       | swp2
              |                       |
         eth1 |                       | eth2
         +------------+       +------------+
         | server01   |       | server02   |
         |            |       |            |
         +------------+       +------------+


Using the Helper Script
-----------------------
The `push-config.py` helper script deploys the configuration to the in-band network by downloading the files from the out-of-band management server. This requires a web server to be installed on the out-of-band server and passwordless login and sudo to be enabled on the in-band devices, both of which are done for you if you used [cldemo-vagrant](http://github.com/cumulusnetworks/cldemo-vagrant) to provision your topology. The demo repository needs to be linked in the management server's `/var/www/` directory:

    vagrant ssh oob-mgmt-server
    sudo su - cumulus
    git clone https://github.com/cumulusnetworks/cldemo-config-vxlan
    cd cldemo-config-routing
    sudo ln -s  /home/cumulus/cldemo-config-vxlan /var/www/cldemo-config-vxlan

After setting up the repo, you can now use `push-config.py`! This script will log in to each device, download the files, and reboot the device.

    python pushconfig.py <demo_name> leaf01,leaf02,spine01,spine02,server01,server02


Verifying Routing
-----------------
Running the demo is easiest with two terminal windows open. One window will log into server01 and ping server02's IP address. The second window will be used to deploy new configuration on the switches.

*In terminal 1*

    vagrant ssh oob-mgmt-server
    sudo su - cumulus
    cd cldemo-config-routing
    python pushconfig.py head-end-replication leaf01,leaf02,spine01,spine02,server01,server02

*In terminal 2*

    vagrant ssh oob-mgmt-server
    sudo su - cumulus
    ssh server01
    ping 172.16.2.101

*In terminal 1*

    python pushconfig.py service-node-replication leaf01,leaf02,spine01,spine02
    # wait and watch connectivity drop and then come back
