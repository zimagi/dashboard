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
	fwrite($error, 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
	exit(1);
}
if (!$mysql->query('SELECT * FROM `users`')) {
	if (!$mysql->query('CREATE TABLE IF NOT EXISTS `config` (
		path VARCHAR(100) NOT NULL,
		data TEXT NOT NULL,
		PRIMARY KEY (`path`)
)')) {
		fwrite($error, 'MySQL "CREATE TABLE" Error: ' . $mysql->error . "\n");
		$mysql->close();
		exit(1);
	}
	echo '';
} else {
	$result = $mysql->query('SELECT * FROM `config` WHERE path = \'' . $mysql->real_escape_string($argv[6]) . '\'');
	if ($result->num_rows > 0) {
		echo $result->fetch_assoc()['data'];
	} else {
		echo '';
	}
}
$mysql->close();
