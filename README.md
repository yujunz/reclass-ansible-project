# Ansible with Reclass Inventory

This project gives an example on how to use [reclass](http://reclass.pantsfullofunix.net/) to manage [Ansible](https://www.ansible.com/) inventory and variables.

## Installation

It is recommended to install it in a virtual environement using [pipenv](https://docs.pipenv.org/).

``` shell
pip install pipenv
pipenv install
pipenv shell
```

## Usage

### List inventory

``` shell
$ ./reclass-ansible --list
inventory:
- localhost
inventory_hosts:
- localhost
node:
- master
- minion-1
- minion-2
ping_hosts:
- master
- minion-1
- minion-2
```

It will return all hosts automatically grouped by classes (`inventory`, `node`)
or applications (`ping_hosts`, `inventory_hosts`).

### Apply a role to target hosts

``` shell
ansible-role ping --hosts localhost
```

`ansible-role` is a wrapper of `ansible-playbook` provided by [ansible-toolbox](https://github.com/larsks/ansible-toolbox). It allows you to apply an ansible
role to targets without creating a playbook.

### Static inventory

The way to add a new host is creating a yaml file in `inventory/nodes`. You may
follow the example code in `inventory/nodes/master.yml`.

``` yaml
classes:
  - node
parameters:
  ansible_ssh_common_args: ""
  ansible_connection: local
  ansible_host: master
  ansible_user: ubuntu
  ansible_port: 22
```

The parameters will be converted to ansible varibles by `reclass-ansible`.
Therefore, declare your host variables in the node definition.

### Dynamic inventory

The role `inventory` is an example for generating a list of hosts from specified
template. It is useful when those hosts share similar configuration.

``` shell
ansible-role inventory
```

NOTE: by default, `ansible-role` will select localhost as default target and
generate the nodes in `inventory/nodes/_generated`.

### Group variables

The group variables in Ansible are defined in a class,

For example, `inventory/classes/node.yml`

``` yaml
applications:
  - ping
parameters:
  ansible_ssh_common_args: "-F .ssh_config"
```

It applies `ansible_ssh_common_args` to all nodes if it includes class `node`

### Dump inventory

Use the following command to dump the whole inventory to console

``` shell
reclass --inventory
```

It is quite useful to check the actual value of the parameters applied to a node.

## Reclass essentials

The parameters are organized in reclass which is an “external node classifier”
(ENC) as can be used with automation tools. There are two directories in reclass
inventory, `classes` and `nodes`.

- `nodes` defines the targets you are modeling
- `classes` defines the category, tag and whatever used to classify the nodes

The classes are organized hierachically and the parameters can be overridden by
the descendants.

For example, we assign `node` class to `master` to share the common parameters
and applications but need a different value for `ansible_ssh_common_args`. Then
we just simply assign a new value `ansible_ssh_common_args` in `master`
definition.

## Tips

The `inventory` role generate a `.ssh_config` file for the ease of accessing
target host.

``` shell
ssh -F .ssh_config minion-1
```
