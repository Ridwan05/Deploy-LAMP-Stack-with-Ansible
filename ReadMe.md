# AltShool Second Semester Exam

## In this exercise, I deployed Laravel app with Ansible

## I created a script _postgres.sh_ to install postgres on the remote server

## I created two template files _laravel.tpl_ and _env.tpl_ to configure host file and db environment respectively

## I created _host-inventory_ and playbook _laravel.yml_

## The playbook is configured to perform the following task:
- create a user
- install apache
- install git
- install curl
- install php and it's dependencies
- download and install composer
- grant all neccessary permission
- install laravel dependencies
- restart apache
- Secure Apache with SSL Free Certificate
