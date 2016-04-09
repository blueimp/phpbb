# phpBB Dockerfile

## Setup
This setup guide assumes that the `docker-compose.yml` of this repository is
available in the current directory.

### Hostname
Set the `SERVER_NAME` variable to the fully qualified domain name of your
server:

```sh
export SERVER_NAME='dev.test'
```

This is used as `hostname` option for the phpBB Docker container.

### SSL files
> If you don't require HTTPS, skip this section and remove the SSL volume mount
from the `phpbb` container definition in `docker-compose.yml`.

Create the `ssl` directory:

```sh
mkdir ssl
```

For development, generate a private key file and an associated self-signed
certificate, with the Common Name option matching the `SERVER_NAME` variable set
previously:

```sh
openssl req -nodes -x509 -newkey rsa:2048 \
  -subj "/C=/ST=/L=/O=/OU=/CN=$SERVER_NAME" \
  -keyout ssl/default.key \
  -out ssl/default.crt
```

For a production system, retrieve an SSL certificate for your domain signed by
an official Certificate Authority. Combine the issued certificate and any
intermediate certificates into a file called `default.crt` and put it into the
`ssl` directory. Add the private key used for the certificate signing request as
`default.key`:

- `ssl/default.crt`
- `ssl/default.key`

### Database options
Define passwords for the MySQL root user and the phpBB database user:

```sh
export MYSQL_ROOT_PASSWORD='password1'
export DBPASSWD='password2'
```

The following settings are defined as default in the phpBB Dockerfile, but can
also be provided via environment variables configured in `docker-compose.yml`:

```sh
DBHOST='mysql'
DBPORT= # Defaults to 3306 in phpBB
DBNAME='phpbb'
DBUSER='phpbb'
TABLE_PREFIX='phpbb_'
```

### Scheduled backups to Amazon S3
> If you don't require scheduled backups to Amazon S3, skip this section and
remove the `backup` container definition in `docker-compose.yml`.

Define a Bucket name and AWS credentials for scheduled backups to Amazon S3:

```sh
export S3_BUCKET='phpbb-backup'
export AWS_ACCESS_KEY_ID='XXXXXXXXXXXXXXXXXXXX'
export AWS_SECRET_ACCESS_KEY='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
```

You can make use of the sample
[S3 backup IAM policy](https://github.com/blueimp/phpbb-s3-backup/blob/master/iam-policy.json),
replacing the `phpbb-backup` S3 Bucket name with your own.

The backups are scheduled for 4am (local server time) each night by default.  
To define a different schedule, override the `BACKUP_SCHEDULE` environment
variable for the `backup` container:

```yml
backup:
  # ...
  environment:
    - BACKUP_SCHEDULE='0 4 * * *'
  # ...
```

The syntax follows the crontab format:

```sh
# Crontab format:
# .---------- minute (0-59)
# | .-------- hour (0-23)
# | | .------ day of month (1-31)
# | | | .---- month (1-12 / jan,feb,mar,apr,may,jun,jul,aug,sept,oct,nov,dec)
# | | | | .-- day of week (0-6 / sun,mon,tue,wed,thu,fri,sat)
# | | | | |
# * * * * * command [args...]
```

To provide additional options to the
[mysqldump](https://dev.mysql.com/doc/refman/5.6/en/mysqldump.html) command,
which is used for the database backup, set the `MYSQLDUMP_OPTS` environment
variable for the `backup` container:

```yml
backup:
  # ...
  environment:
    - MYSQLDUMP_OPTS=''
  # ...
```

The following options will be provided automatically:

```sh
host="${DBHOST:-mysql}"
port="${DBPORT:-3306}"
user="${DBUSER:-phpbb}"
password="$DBPASSWD"
databases="${DBNAME:-phpbb}"
```

To override the datetime prefix for the database backup, override the
`DATE_FORMAT` environment variable for the `backup` container:

```yml
backup:
  # ...
  environment:
    - DATE_FORMAT='%Y-%m-%dT%H-%M-%SZ_'
  # ...
```

To override the options passed to the
[aws s3 cp](https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html)
command for the database backup, override the `DB_CP_OPTS` environment variable
for the `backup` container:

```yml
backup:
  # ...
  environment:
    - DB_CP_OPTS=''
  # ...
```

To override the options passed to the
[aws s3 sync](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html)
command for the directory backups, override the `DIR_SYNC_OPTS` environment
variable for the `backup` container:

```yml
backup:
  # ...
  environment:
    - DIR_SYNC_OPTS='--size-only --exclude .htaccess --exclude index.htm'
  # ...
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
Inside of the phpBB container, download the phpBB package and add the install
folder to the document root:

```sh
docker exec -it phpbb_phpbb_1 sh -c \
  'download-phpbb /tmp && mv /tmp/phpBB3/install /var/www/html/'
```

Open a browser with the server URL:

```sh
open "http://$SERVER_NAME"
```

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
