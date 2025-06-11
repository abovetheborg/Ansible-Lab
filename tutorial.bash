#!/bin/bash

# https://github.com/ansible/molecule/issues/4040
mkdir -p collections/ansible_collections
cd collections/ansible_collections

export ANSIBLE_COLLECTIONS_PATH=~/git/Ansible-Lab/collections
echo $ANSIBLE_COLLECTIONS_PATH

ansible-galaxy collection init foo.bar
cd foo/bar/roles
ansible-galaxy role init my_role
#printf -- '--- \n- name: Task is running from within the role\n  ansible.builtin.debug:\n    msg: "This is a task from my_role."' > my_role/tasks/main.yml
cat << EOF > my_role/tasks/main.yml
---
- name: Task is running from within the role
  ansible.builtin.debug:
    msg: "This is a task from my_role."
EOF

cd ..
mkdir -p playbooks
#printf -- '---\n- name: Test new role from within this playbook\n  hosts: localhost\n  gather_facts: false\n  tasks:\n    - name: Testing role\n      ansible.builtin.include_role:\n        name: foo.bar.my_role\n        tasks_from: main.yml' > playbooks/my_playbook.yml
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

cat << EOF >> molecule/default/molecule.yml
provisioner:
  name: ansible
  config_options:
    defaults:
      collections_path: ${ANSIBLE_COLLECTIONS_PATH}
EOF