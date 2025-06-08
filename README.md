# molecule_poc
My hello world for setting up Molecule

# Tutorial
Making sure I can follow the tutorial here:
https://ansible.readthedocs.io/projects/molecule/getting-started/#inspecting-the-moleculeyml


Jeff Geerling: https://www.youtube.com/watch?v=FaXVZ60o8L8&t=2105s

```
molecule init scenario
```
This comment initialize the a molecule scenario called default
foo/bar/extensions/molecule/default

Docker must be installed

## Troubleshooting

If you encounter a permission error when running `destroy.yml` or Molecule commands with Docker, it is likely because your user does not have permission to access the Docker daemon.  
You can resolve this by either:

- Running the command with `sudo`, e.g.:
  ```
  sudo molecule destroy
  ```
- Or, adding your user to the `docker` group (then log out and back in):
  ```
  sudo usermod -aG docker $USER
  ```

  I need to chang molecule so that it uses docker.