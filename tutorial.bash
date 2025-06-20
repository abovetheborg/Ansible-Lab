#!/bin/bash

cd ~/git/Ansible-Lab
rm -rf collections

# molecule doesn't play well with being in the gitignore list
rm .gitignore # do not commit this change :)

# with a virtual environment activated
pip install -r requirements.txt

# Docker is required for molecule
#sudo snap install docker
# sudo apt-get -y install docker.io
# sudo groupadd docker
# sudo gpasswd -a $USER docker
# #sudo newgrp docker
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
dependency:
  name: galaxy
  options:
    requirements-file: requirements.yml
driver:
  name: docker
platforms:
  - name: instance
    image: docker.io/library/ubuntu:latest
    pre_build_image: true
provisioner:
  name: ansible
  config_options:
    defaults:
      collections_path: ${ANSIBLE_COLLECTIONS_PATH}
EOF

cat << 'EOF' > molecule/default/create.yml
- name: Create
  hosts: localhost
  gather_facts: false
  vars:
    molecule_inventory:
      all:
        hosts: {}
        molecule: {}
  tasks:
    - name: Create a container
      community.docker.docker_container:
        name: "{{ item.name }}"
        image: "{{ item.image }}"
        state: started
        command: sleep 1d
        log_driver: json-file
      register: result
      loop: "{{ molecule_yml.platforms }}"

    - name: Print some info
      ansible.builtin.debug:
        msg: "{{ result.results }}"

    - name: Fail if container is not running
      when: >
        item.container.State.ExitCode != 0 or
        not item.container.State.Running
      ansible.builtin.include_tasks:
        file: tasks/create-fail.yml
      loop: "{{ result.results }}"
      loop_control:
        label: "{{ item.container.Name }}"

    - name: Add container to molecule_inventory
      vars:
        inventory_partial_yaml: |
          all:
            children:
              molecule:
                hosts:
                  "{{ item.name }}":
                    ansible_connection: community.docker.docker
      ansible.builtin.set_fact:
        molecule_inventory: >
          {{ molecule_inventory | combine(inventory_partial_yaml | from_yaml, recursive=true) }}
      loop: "{{ molecule_yml.platforms }}"
      loop_control:
        label: "{{ item.name }}"

    - name: Dump molecule_inventory
      ansible.builtin.copy:
        content: |
          {{ molecule_inventory | to_yaml }}
        dest: "{{ molecule_ephemeral_directory }}/inventory/molecule_inventory.yml"
        mode: "0600"

    - name: Force inventory refresh
      ansible.builtin.meta: refresh_inventory

    - name: Fail if molecule group is missing
      ansible.builtin.assert:
        that: "'molecule' in groups"
        fail_msg: |
          molecule group was not found inside inventory groups: {{ groups }}
      run_once: true # noqa: run-once[task]

# we want to avoid errors like "Failed to create temporary directory"
- name: Validate that inventory was refreshed
  hosts: molecule
  gather_facts: false
  tasks:
    - name: Check uname
      ansible.builtin.raw: uname -a
      register: result
      changed_when: false

    - name: Display uname info
      ansible.builtin.debug:
        msg: "{{ result.stdout }}"
EOF