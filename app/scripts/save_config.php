<?php
#
# Parameters:
#
#   [1]: Server Host name / IP
#   [2]: Server Port
#   [3]: Database User
# 	[4]: Database User Password
#   [5]: Database Name
# 	[6]: Configuration Path
#
$error = fopen('php://stderr', 'w');
$mysql = new mysqli($argv[1], $argv[3], $argv[4], $argv[5], (int)$argv[2]);
if ($mysql->connect_error) {
	fwrite($error, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
	exit(1);
}

$config_name = "/var/www/html/" . $argv[6];
$config = fread(fopen($config_name, 'r'), filesize($config_name));

if (!$mysql->query('INSERT INTO `config` (path, data) VALUES (\'' . $mysql->real_escape_string($argv[6]) . '\', \'' 
		. $mysql->real_escape_string($config) . '\')')) {
	fwrite($error, "\n" . 'MySQL "INSERT INTO config" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}
$mysql->close();
