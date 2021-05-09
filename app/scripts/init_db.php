<?php
#
# Parameters:
#
#   [1]: Server Host name / IP
#   [2]: Server Port
#   [3]: Database Root Password
#   [4]: Database User
#   [5]: Database Name
#
$error = fopen('php://stderr', 'w');
$maxTries = 10;
do {
	$mysql = new mysqli($argv[1], 'root', $argv[3], '', (int)$argv[2]);
	if ($mysql->connect_error) {
		fwrite($error, 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(3);
	}
} while ($mysql->connect_error);

if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($argv[5]) . '` ' .
		'DEFAULT CHARACTER SET = \'utf8\' DEFAULT COLLATE \'utf8_general_ci\'')) {
	fwrite($error, 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}
if (!$mysql->query('GRANT ALL ON ' . $mysql->real_escape_string($argv[5]) . '.* ' .
		'TO \'' . $argv[4] . '\'@\'%\'')) {
	fwrite($error, 'MySQL "GRANT ALL" Error: ' . $mysql->error . "\n");
	$mysql->close();
	exit(1);
}
$mysql->close();
