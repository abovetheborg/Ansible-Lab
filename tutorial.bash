!#/bin/bash

ansible-galaxy collection init foo.bar
cd foo/bar/roles
ansible-galaxy role init my_role
printf -- '--- \n- name: Task is running from within the role\n\tansible.builtin.debug:\n\t\tmsg: "This is a task from my_role."' > my_role/tasks/main.yml
cd ..
mkdir -p playbooks
printf -- '---\n- name: Test new role from within this playbook\n\thosts: localhost\n\tgather_facts: false\n\ttasks:\n\t\t- name: Testing role\n\t\t\tansible.builtin.include_role:\n\t\t\t\tname: foo.bar.my_role\n\t\t\t\ttasks_from: main.yml' > playbooks/my_playbook.yml

mkdir -p extensions
cd extensions
molecule init scenario

