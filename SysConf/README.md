# Introduction
Ansible configuration to setup virtual machines to host various web services and supporting resources. 

## Usage

- Install the public ssh key for a `matadmin` user with SUDO rights that don't require a password on the hosts being 
worked on.
- Have the private ssh key for the `matadmin` user available for ssh into hte hosts being worked on.
- Install ansible on the admin workstation

  * `pipx install ansible`
  * `pipx inject ansible passlib`

### Test SSH Connectivity

`ansible web01 -m ping -i inventory.ini`

### Everything

Run `ansible-playbook site.yml -i inventory.ini` from the `SysConf` directory.

## Implements

- Installs a set of common packages and configuration settings for Ubuntu VMs generally with the `common` role.

  * Installs PyEnv in `/usr/local/python3` for use by other implementations.

- Installs nginx and other elements for hosting static web content and acting as a reverse proxy for other application
  servers.
