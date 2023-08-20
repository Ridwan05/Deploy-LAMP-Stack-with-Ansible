# Deploy Laravel App with Ansible

### In this project, I deployed Laravel app with Ansible

### Prerequisites
- AWS account
- EC2 instance
- Vscode with AWS cridentials installed
- Ansible Preinstalled on PC

### Create a script in file _postgres.sh_ to install postgres on the remote server

```
#!/usr/bin/bash

# remove postgres if it exist
#sudo apt-get --purge remove postgresql -y

# Update Server Package
sudo apt update

# Install Postgresql
sudo apt install postgresql postgresql-contrib -y

# Start postgresql service
sudo systemctl start postgresql.service

# Create password for postgres user
sudo -i -u postgres psql -c"ALTER user postgres WITH PASSWORD 'password'"

# Create Database
sudo -u postgres psql -c"SELECT 1 FROM pg_database WHERE datname = 'database_name'" | grep -q 1 || sudo -u postgres psql -c"CREATE DATABASE ridwan"
```

### Create template file _laravel.tpl_ and to configure host file.

```
 <VirtualHost *:80>
     ServerName ridwandemo.me
     ServerAlias www.ridwandemo.me
     ServerAdmin mymail@gmail.com
     DocumentRoot /var/www/html/Laravel/public

     <Directory /var/www/html/Laravel>
         AllowOverride All
     </Directory>
     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
 </VirtualHost>
```

### Create template file _laravel.tpl_ and _env.tpl_ to configure host file and db environment respectively

```
APP_NAME="Laravel Realworld Example App"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost
APP_PORT=3000

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=your_database
DB_USERNAME=postgres
DB_PASSWORD=your_password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

L5_SWAGGER_GENERATE_ALWAYS=true
SAIL_XDEBUG_MODE=develop,debug
SAIL_SKIP_CHECKS=true
```

### Create _host-inventory_ file and paste in the EC2 ip address

### Create playbook _laravel.yml_ file with the following scripts

```
---

- name: setup web server
  hosts: all

  tasks:
   - name: Add user ridwan
     ansible.builtin.user:
        name: ridwan
        comment: userridwan
        group: sudo
        groups: ssh
        createhome: yes       
        home: /home/ridwan    
        state: present

   - name: Update apt
     apt: update_cache=yes
     become: yes

   - name: Install Apache
     apt: name=apache2 state=latest
     become: yes

   - name: Install Git
     apt: name=git state=present
     become: yes

   - name: Install curl
     apt: name=curl state=present
     become: yes

   - name: install php and its dependencies
     shell: |
         apt install software-properties-common
         apt update
         apt-get install php8.1-fpm libapache2-mod-php php8.1-dev php8.1-zip php8.1-curl php8.1-mbstring php8.1-pgsql php8.1-gd php8.1-xml -y
     become: yes

   - name: Copy script to remote server
     copy:
       src: postgres.sh
       dest: /home/postgres.sh
     become: yes

   - name: Install postgres and create database
     command: bash /home/postgres.sh
     become: yes

   - name: download composer installer
     shell: |
       curl -sS https://getcomposer.org/installer | php
       mv composer.phar /usr/local/bin/composer
     become: yes

   - name: Take ownership of root folder and clone laravel source code
     shell: |
        cd to /var/www/html
        chown -R $USER /var/www/html
        git clone https://github.com/Ridwan05/Laravel.git temp
        mv temp/* /var/www/html/Laravel
        rm -rf temp
     become: yes

   - name: Change default Apache virtual host
     template:
      src: laravel.tpl
      dest: /etc/apache2/sites-available/Laravel.conf
     become: yes

   - name: Add .env file
     template:
      src: env.tpl
      dest: /var/www/html/Laravel/.env
     become: yes

   - name: Give Laravel Permissions
     shell: |
         chown -R :www-data /var/www/html/Laravel
         chmod -R 775 /var/www/html/Laravel
         chmod -R 775 /var/www/html/Laravel/storage
         chmod -R 775 /var/www/html/Laravel/bootstrap/cache
     become: yes

   - name: Install Laravel Dependencies
     shell: |
        cd /var/www/html/Laravel
        export COMPOSER_ALLOW_SUPERUSER=1; composer show;
        composer update --no-plugins --no-scripts

   - name: Connect Laravel to Database
     shell: |
       cd /var/www/html/Laravel
       php artisan key:generate
       php artisan config:cache
       php artisan migrate

   - name: Enable new config
     shell: |
        cd /var/www/html/Laravel
        a2dissite 000-default.conf
        a2ensite Laravel.conf
        a2enmod rewrite

   - name: restart apache
     service: name=apache2 state=restarted
     become: yes

   - name: Secure Apache with SSL Free Certificate
     shell: |
        cd /var/www/html/Laravel
        apt install python3-certbot-apache -y
        certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email ridohlah74@gmail.com -d www.ridwandemo.me
     become: yes

```
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
- I had issue running `composer install` from playbook because it should not be run as root, I tried using _become_ module but It didn't work. I found a solution with "COMPOSER_ALLOW_SUPERUSER".
