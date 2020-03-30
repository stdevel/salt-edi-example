# salt-edi-example

This repository contains a demo for event-driven infrastructure using Salt.

## Requirements

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

The last command might be tricky as Salt will mostly likely restore the original file content before you finish typing the command. :trollface:

## Some technical details

### Salt Master

A very important file is `/etc/salt/master.d/reactor.conf` which defines the following events on the bus and their corresponding reactor states that will be applied:

| Event | Description | State (`/srv/reactor`) |
| ----- | ----------- | ----- |
| `salt/auth` | new Minion tries to connect for the first time | [`auto-sign.sls`](ansible/templates/auto-sign.sls) |
| `salt/beacon/*/service/apache2` | any client sends a beacon regarding Apache2 service state change | [`restart_apache.sls`](ansible/templates/reactor_restart_apache.sls) |
| `salt/beacon/*/inotify//srv/www/htdocs/index.html` | change on website file | [`restore_website.sls`](ansible/templates/reactor_restore_website.sls) |

In addition, the reactor states accomplish the following tasks:

| Reactor state | Description |
| ------------- | ----------- |
| [`auto-sign.sls`](ansible/templates/auto-sign.sls) | automatically accepts minion key (*do __NOT__ use this on production*) |
| [`restart_apache.sls`](ansible/templates/reactor_restart_apache.sls) | applies state [`/srv/salt/restart_apache.sls`](ansible/templates/state_restart_apache.sls) which ensures that the service is started |
| [`restore_website.sls`](ansible/templates/state_restore_website.sls) | recovers website content with version from Salt Master ([`/srv/salt/website/index.html.j2`](ansible/templates/website_index.html.j2)) |

### Salt Minion

To ensure that the Salt Master is informed about Apache2 status and website changes, the Minion is configured to send beacons. This configuration is stored under [`/etc/salt/minion.d/beacons.conf`](ansible/templates/beacons.conf).

### Explanation

TODO: image

So what actually happens if the Apache2 service is stopped?

1. The Salt Master receives a beacon telling that `apache2` has been stopped
2. A new job is started that forces the state `restart_apache2` to be applied on `client`
3. The job's return message verifies the changed service state
4. The client on the other hand sends an updated beacon that the service is now started

What's taking place when the website content (`/srv/www/htdocs/index.html`) is overwritten?

1. The Salt Master receives a beacon telling that the website has been changed
2. A new job is started that forces the state `restore_website` to be applied on `client`
3. The job's return message verifies that the file has been restored
