<?php

require 'connect.php';

$con = db_connect();

if (isset($_POST['id'])) {
  $id = mysql_real_escape_string($_POST['id']);
  $check = mysqli_query($con, "SELECT * FROM data WHERE id='$id'");
  if (mysqli_num_rows($check) > 0) {
    $row = mysqli_fetch_array($check);
    mysqli_query($con, "DELETE FROM data WHERE id='$id'");
    echo $row['store'];
  }else{
    echo "no data";
  }
}else{
  echo "connection fail";
}

?>