<?php
function db_connect() {
  $con = new mysqli('ip or url of the database', 'username', 'yourpassword', 'database'); 
  if (!$con)
    return false;
  return $con;
}
?>