#!/bin/bash

cd ~/git/Ansible-Lab
rm -rf collections

# molecule doesn't play well with being in the gitignore list
rm .gitignore # do not commit this change :)

# with a virtual environment activated
pip install -r requirements.txt

# Docker is required for molecule
#sudo snap install docker
sudo apt-get -y install docker.io
sudo groupadd docker
sudo gpasswd -a $USER docker
#sudo newgrp docker
docker run hello-world


# https://github.com/ansible/molecule/issues/4040
mkdir -p collections/ansible_collections
cd collections/ansible_collections

export ANSIBLE_COLLECTIONS_PATH=~/git/Ansible-Lab/collections
echo $ANSIBLE_COLLECTIONS_PATH

ansible-galaxy collection init foo.bar
cd foo/bar/roles
ansible-galaxy role init my_role

cat << EOF > my_role/tasks/main.yml
---
- name: Task is running from within the role
  ansible.builtin.debug:
    msg: "This is a task from my_role."
EOF

cd ..
mkdir -p playbooks

cat << EOF > playbooks/my_playbook.yml
---
- name: Test new role from within this playbook
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Testing role
      ansible.builtin.include_role:
        name: foo.bar.my_role
        tasks_from: main.yml
EOF

mkdir -p extensions
cd extensions
molecule init scenario

cat << EOF > molecule/default/converge.yml
---
- name: Include a playbook from a collection
  ansible.builtin.import_playbook: foo.bar.my_playbook
EOF

cat << 'EOF' > molecule/default/molecule.yml
---
driver:
  name: docker
platforms:
  - name: instance
    image: docker.io/library/ubuntu:latest
provisioner:
  name: ansible
  config_options:
    defaults:
      collections_path: ${ANSIBLE_COLLECTIONS_PATH}
EOF