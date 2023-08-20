# Deploy Laravel App with Ansible

### In this project, I deployed Laravel app with Ansible

### Prerequisites
- AWS account
- EC2 instance
- Vscode with AWS cridentials installed
- Ansible Preinstalled on PC

### I created a script _postgres.sh_ to install postgres on the remote server

### I created two template files _laravel.tpl_ and _env.tpl_ to configure host file and db environment respectively

### I created _host-inventory_ and playbook _laravel.yml_

### The playbook is configured to perform the following tasks:
- create a user and work as that user
- install apache
- install git
- install curl
- install php and it's dependencies
- download and install composer
- grant all neccessary permissions
- install laravel dependencies
- restart apache
- Secure Apache with SSL Free Certificate

### The app can be reached at www.ridwandemo.me

### Issues
- I had issue running `composer install` from playbook because it should not be run as root, I tried using _become_ module but It didn't work. 
