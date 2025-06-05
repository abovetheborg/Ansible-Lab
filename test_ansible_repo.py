import os
import shutil
import subprocess
from git import Repo

REPO_URL = "https://github.com/abovetheborg/Ansible-Lab-Tester.git"  # Replace with your repo
CLONE_DIR = "/tmp/ansible-role-example"

def clone_repo(repo_url, clone_dir):
    if os.path.exists(clone_dir):
        shutil.rmtree(clone_dir)
    Repo.clone_from(repo_url, clone_dir)

def run_molecule_test(clone_dir):
    subprocess.run(["molecule", "test"], cwd=clone_dir, check=True)

if __name__ == "__main__":
    clone_repo(REPO_URL, CLONE_DIR)
    # run_molecule_test(CLONE_DIR)
