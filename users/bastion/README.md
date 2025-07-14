# Ansible script to create bastion users

This script creates a user on the bastion host and adds the user to the bastion group. The user is also added to the sudoers file.

## Usage

- Adding Publickeys of users
  
  - Publickeys are stored in the `pubkeys` directory. in having keys encrypted by ansible-vault and name same as username for bastion user.

- Adding user configurations for ansible variables in `vars` directory based on Environment stage name eg: `dev.yml`, `stage.yml` or `prod.yml`

 
  ```yaml
  # ./vars/dev.yml

  # bastion users
  users:
    - user1

  # which bastion user needs to provide sudo access
  sudo_users:
    - user1

  # name of the sudo group
  sudo_group: admin

  # remove any existing user from system
  remove_users:
    - john
  ```

    ```yaml
  # ./vars/stage.yml

  # bastion users
  users:
    - user1
    
  # which bastion user needs to provide sudo access
  sudo_users:
    - user1

  # name of the sudo group
  sudo_group: admin

  # remove any existing user from system
  remove_users:
    - john
  ```

## Running the script


```
_ENV=dev make bastion-users ansible_user=<DEFAULT_EC2_USER/BASTION_USER> ansible_ssh_private_key_file=<BASTION/EC2_USER PRIVATE_KEY>
```
