<?php

$dbms = 'phpbb\\db\\driver\\mysqli';
$dbhost = $_ENV['DBHOST'];
$dbport = $_ENV['DBPORT'];
$dbname = $_ENV['DBNAME'];
$dbuser = $_ENV['DBUSER'];
$dbpasswd = $_ENV['DBPASSWD'];
$table_prefix = $_ENV['TABLE_PREFIX'];
$phpbb_adm_relative_path = 'adm/';
$acm_type = 'phpbb\\cache\\driver\\file';

@define('PHPBB_INSTALLED', true);
// @define('PHPBB_DISPLAY_LOAD_TIME', true);
@define('PHPBB_ENVIRONMENT', 'production');
// @define('DEBUG_CONTAINER', true);
