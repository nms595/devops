# WordPress Steps 
- ifconfig
- sudo yum install httpd mariadb mariadb-server php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt php-xmlrpc unzip wget -y
- sudo systemctl start httpd
- sudo systemctl start mariadb
- sudo systemctl enable httpd
- sudo systemctl enable mariadb
- sudo mysql_secure_installation
- mysql -u root -p
    ```
    MariaDB [(none)]>CREATE DATABASE wordpress;
    MariaDB [(none)]>GRANT ALL PRIVILEGES on wordpress.* to 'user'@'localhost' identified by 'password';
    MariaDB [(none)]>FLUSH PRIVILEGES;
    MariaDB [(none)]>exit
    ```
- cd /tmp/
- wget http://wordpress.org/latest.tar.gz
- tar -xzvf latest.tar.gz
- sudo cp -avr wordpress/* /var/www/html/
- sudo mkdir /var/www/html/wp-content/uploads
- sudo chown -R apache:apache /var/www/html/
- sudo chmod -R 755 /var/www/html/
- cd /var/www/html/
- sudo mv wp-config-sample.php wp-config.php
- sudo vim wp-config.php

## Change the DB_NAME, DB_USER, and DB_PASSWORD variables as shown below:
    ```
    define('DB_NAME', 'wordpress');
    define('DB_USER', 'user');
    define('DB_PASSWORD', 'password');
    ```
- systemctl status httpd
- systemctl restart httpd
- sudo systemctl restart httpd
- curl ifconfig.co

