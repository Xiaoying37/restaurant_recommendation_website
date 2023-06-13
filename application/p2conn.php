<?php

$dbhost = '127.0.0.1'; // localhost
$dbuname = 'root';
$dbpass = 'root';
$dbname = 'euro_restuarant'; //Database name


//$dbo = new PDO('mysql:host=abc.com;port=8889;dbname=$dbname, $dbuname, $dbpass);
// remember to change the port number

$dbo = new PDO('mysql:host=' . $dbhost . ';port=3306;dbname=' . $dbname, $dbuname, $dbpass);

?>
