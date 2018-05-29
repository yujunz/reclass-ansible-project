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

### Host variables

The full list of variables available to a specific host can be retrieved with
`reclass-ansible --host HOSTNAME`. For example:

``` yaml
__reclass__:
  applications:
  - ping
  classes:
  - node
  environment: ''
  name: minion-1
  node: _generated/minion-1
  timestamp: Tue May 29 09:28:13 2018
  uri: yaml_fs:///Users/yujunz/Workspace/reclass-ansible-project/inventory/nodes/_generated/minion-1.yml
ansible_ssh_common_args: -F .ssh_config
node:
  host: minion-1
  name: minion-1
```

Then you may use `{{ node.host }}` in Ansible playbook or templates.

The equivalence for Ansible group variable is the parameters defined in class.
For example:

``` yaml
applications:
  - ping
parameters:
  ansible_ssh_common_args: "-F .ssh_config"
```

It applies `ansible_ssh_common_args` to all nodes if it includes class `node`.

### Dump inventory

Use the following command to dump the whole inventory to console

``` shell
reclass --inventory
```

An example output is as following:

``` yaml
__reclass__:
  timestamp: Mon May 28 09:59:42 2018
applications:
  inventory:
  - localhost
  ping:
  - master
  - minion-1
  - minion-2
classes:
  inventory:
  - localhost
  node:
  - master
  - minion-1
  - minion-2
nodes:
  localhost:
    __reclass__:
      environment: base
      name: localhost
      node: ./localhost
      timestamp: Mon May 28 09:59:42 2018
      uri: yaml_fs:///Users/yujunz/Workspace/reclass-ansible-project/inventory/nodes/./localhost.yml
    applications:
    - inventory
    classes:
    - inventory
    environment: base
    parameters:
      _params:
        inventory_base_uri: inventory
      ansible_connection: local
      inventory:
        nodes:
        - host: minion-1
          name: minion-1
          user: ubuntu
        - host: minion-2
          name: minion-2
          user: ubuntu
        nodes_base_uri: inventory/nodes/_generated
  master:
    __reclass__:
      environment: base
      name: master
      node: ./master
      timestamp: Mon May 28 09:59:42 2018
      uri: yaml_fs:///Users/yujunz/Workspace/reclass-ansible-project/inventory/nodes/./master.yml
    applications:
    - ping
    classes:
    - node
    environment: base
    parameters:
      ansible_connection: local
      ansible_host: master
      ansible_port: 22
      ansible_ssh_common_args: ''
      ansible_user: ubuntu
  minion-1:
    __reclass__:
      environment: base
      name: minion-1
      node: _generated/minion-1
      timestamp: Mon May 28 09:59:42 2018
      uri: yaml_fs:///Users/yujunz/Workspace/reclass-ansible-project/inventory/nodes/_generated/minion-1.yml
    applications:
    - ping
    classes:
    - node
    environment: base
    parameters:
      ansible_ssh_common_args: -F .ssh_config
      node:
        host: minion-1
        name: minion-1
  minion-2:
    __reclass__:
      environment: base
      name: minion-2
      node: _generated/minion-2
      timestamp: Mon May 28 09:59:42 2018
      uri: yaml_fs:///Users/yujunz/Workspace/reclass-ansible-project/inventory/nodes/_generated/minion-2.yml
    applications:
    - ping
    classes:
    - node
    environment: base
    parameters:
      ansible_ssh_common_args: -F .ssh_config
      node:
        host: minion-2
        name: minion-2
```

It is quite useful to check the actual value of the parameters applied to a node.

## Reclass Essentials

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

The author provided a comprehensive document to describe the
[concept in reclass](https://reclass.pantsfullofunix.net/concepts.html).
It helps you to understand the design philosophy of reclass. The key points are
as below:

| Concept     	| Description                                                                                                         	|
|-------------	|---------------------------------------------------------------------------------------------------------------------	|
| node        	| A node, usually a computer in your infrastructure                                                                   	|
| class       	| A category, tag, feature, or role that applies to a node Classes may be nested, i.e. there can be a class hierarchy 	|
| application 	| A specific set of behaviour to apply                                                                                	|
| parameter   	| Node-specific variables, with inheritance throughout the class hierarchy.                                           	|

## Tips

The `inventory` role generate a `.ssh_config` file for the ease of accessing
target host.

``` shell
ssh -F .ssh_config minion-1
```
