#!/bin/bash

ansible-galaxy collection init foo.bar
cd foo/bar/roles
ansible-galaxy role init my_role
printf -- '--- \n- name: Task is running from within the role\n  ansible.builtin.debug:\n    msg: "This is a task from my_role."' > my_role/tasks/main.yml
cd ..
mkdir -p playbooks
printf -- '---\n- name: Test new role from within this playbook\n  hosts: localhost\n  gather_facts: false\n  tasks:\n    - name: Testing role\n      ansible.builtin.include_role:\n        name: foo.bar.my_role\n        tasks_from: main.yml' > playbooks/my_playbook.yml

mkdir -p extensions
cd extensions
molecule init scenario

