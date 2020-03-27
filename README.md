# salt-edi-example

This repository contains a demo for event-driven infrastructure example using Salt.

# Requirements

In order to spin-up this demo, you will need:

- at least 4 GB of memory
- [Oracle VirtualBox](https://virtualbox.org)
- [HashiCorp Vagrant](https://vagrantup.com)

## Overview

There is a [Vagrantfile](Vagrantfile) for creating the following resources:

- two openSUSE Leap 15.1 VMs
  - `salt` running Salt Master
  - `client` managed by `salt`, running Apache2 web server
    - port forwarding from localhost:8888 to port 80

## Usage

Clone this repository or download and extract the archive. Open a terminal and switch to the freshly created directory.

To create the environment, run the following command:

```shell
$ vagrant up
```

This will download an openSUSE template (*roughly 2 GB size*) and deploy two VMs and execute the following steps:

- Install and configure Salt Master on `salt` (*reactors, states, templates*)
- Install Salt Minion on `client` and configure beacons
- Install and configure Apache2 webserver on `client`
- Start services

Login to the Salt Master and open the event-bus console:

```shell
$ vagrant ssh salt
$ sudo salt-run state.event pretty=True
```

Open another terminal and login into the `client` machine. Try stopping apache2 and overwriting the default website (*`/srv/htdocs/www/index.html`*):

```shell
$ vagrant ssh client
$ sudo systemctl stop apache2
$ watch -n1 "sudo systemctl status apache2"
CTRL+C
$ sudo echo "Test" > /srv/www/htdocs/www/index.html
$ watch -n1 "sudo cat /srv/www/htdocs/www/index.html"
CTRL+C
```

## Technical details
TODO: Image
TODO: Reactors, beacons, states, etc.
