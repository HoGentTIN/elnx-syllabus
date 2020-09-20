<html>
<head>
<title>Demo</title>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;900&display=swap" rel="stylesheet">
<style>
table, th, td {
  border-bottom: 1px solid black;
  padding: 10px;
  border-collapse: collapse;
  text-align: center;
}
.center {
  margin-left: auto;
  margin-right: auto;
}
h1 {
  text-align: center;
  font-size: 50px;
}
* {
  font-family: Montserrat;
  font-size: 20px;
  
}
</style>
</head>
<body>
<h1>Database Query Demo</h1>

<?php
// Variables
$db_host='192.168.56.73';
$db_user='demo_user';
$db_name='demo';
$db_password='ArfovWap_OwkUfeaf4';
$db_table='demo_tbl';

// Connecting, selecting database
$connection = new mysqli($db_host, $db_user, $db_password, $db_name);

if ($connection->connect_error) {
	die("<p>Could not connect to database server:</p>" . $connection->connect_error);
}

// Performing SQL query
$query = "SELECT * FROM $db_table";
$result = $connection->query($query);

// Printing results in HTML
echo "<table class=\"center\">\n\t<tr><th>id</th><th>name</th></tr>\n";
while ($row = $result->fetch_assoc()) {
    echo "\t<tr>\n";
    echo "\t\t<td>" . $row["id"] . "</td>\n";
    echo "\t\t<td>" . $row["name"] . "</td>\n";
    echo "\t</tr>\n";
}
echo "</table>\n";

// Free resultset
$result->close();
// Closing connection
$connection->close();
?>
</body>
