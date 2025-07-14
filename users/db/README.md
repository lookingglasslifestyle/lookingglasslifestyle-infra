# Using Ansible script to create database users

This script creates a user on the database host and adds the user to the database group.

Adding user configurations for ansible variables in `vars` directory based on Environment stage name eg: `dev.yml`, `stage.yml` or `prod.yml`

> Note: Don't remove any application user created

```yaml
# ./vars/dev.yml

# list of database users to be added
users:
  - user: backend
    password: user_pswd
  - user: john
    password: user_pswd
  - user: jim
    password: user_pswd
  - user: tim
    password: user_pswd

# provide readonly role to users
readonly_users:
  - tim

# provide readwrite role to users
readwrite_users:
  - backend
  - john
  - jim

# list of users to be deleted
remove_users:
  - demo
```

## use

```
_ENV=dev make db-users ansible_user=<BASTION_USER> DB_USER=<USER> DB_PASSWORD=<PASS> ansible_ssh_private_key_file=<BASTION_KEY>
```
