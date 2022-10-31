 <VirtualHost *:80>
     ServerName ridwandemo.me
     ServerAlias www.ridwandemo.me
     ServerAdmin ridohlah74@gmail.com
     DocumentRoot /var/www/html/Laravel/public

     <Directory /var/www/html/Laravel>
         AllowOverride All
     </Directory>
     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
 </VirtualHost>
