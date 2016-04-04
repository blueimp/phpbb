# phpBB Dockerfile

## Setup

### Passwords
Define passwords for the MySQL root user and the phpBB database user:

```sh
export MYSQL_ROOT_PASSWORD='password1'
export DBPASSWD='password2'
```

### Container start
Start the MySQL and phpBB containers:

```sh
docker-compose -p phpbb up -d
```

### MySQL
Enter the MySQL server CLI:

```sh
docker exec -it phpbb_mysql_1 mysql --password="$MYSQL_ROOT_PASSWORD"
```

Execute the following SQL script, replacing "password2" with the `$DBPASSWD`
value:

```sql
CREATE DATABASE phpbb
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;
CREATE USER phpbb
  IDENTIFIED BY 'password2';
GRANT ALL PRIVILEGES
  ON phpbb.*
  TO phpbb;
```

Exit the MySQL CLI (via `quit`).

### phpBB

#### Install directory
Enter the phpBB container:

```sh
docker exec -it phpbb_phpbb_1 bash
```

Download the phpBB package and add the install folder to the document root:

```sh
download-phpbb /tmp && mv /tmp/phpBB3/install /var/www/html/
```

Exit the phpBB container and open a browser with the docker hostname.

Follow the installation instructions, skipping the upload of `config.php`.  

#### Database configuration
Use the following database configuration, again replacing "password2" with the
`$DBPASSWD` value:

Setting                       | Value
------------------------------|----------
Database type                 | mysqli
Database server hostname      | mysql
Database server port          |
Database name                 | phpbb
Database username             | phpbb
Database password             | password2
Prefix for tables in database | phpbb_

#### Email configuration
Use the following Email settings to use Gmail as SMTP provider:

Setting                        | Value
-------------------------------|---------------------
Use SMTP server for e-mail     | Yes
SMTP server address            | tls://smtp.gmail.com
SMTP server port               | 465
Authentication method for SMTP | PLAIN
SMTP username                  | example@gmail.com
SMTP password                  | YourGmailPassword

Please note that you need to create an
[app password](https://security.google.com/settings/security/apppasswords)
if you use 2-Step Verification for your Google account.

#### Container recreation
Recreate the phpBB container:

```sh
docker-compose -p phpbb up -d --force-recreate phpbb
```

#### Database migration
After updating to a new phpBB version, run the following command to update the
database schema and increment the version number:

```sh
docker exec -it phpbb_phpbb_1 php bin/phpbbcli.php db:migrate
```

## License
Released under the [MIT license](http://www.opensource.org/licenses/MIT).

## Author
[Sebastian Tschan](https://blueimp.net/)
