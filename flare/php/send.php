<?php

require 'connect.php';

$con = db_connect();

if (isset($_POST['id']) && isset($_POST['data'])) {
  $id = mysql_real_escape_string($_POST['id']);
  $data = mysql_real_escape_string($_POST['data']);
    
  $check = mysqli_query($con, "SELECT * FROM data WHERE id='$id'");
  if (mysqli_num_rows($check) > 0) {
    mysqli_query($con, "DELETE FROM data WHERE id='$id'");
  }
  
  $result = mysqli_query($con, "INSERT INTO data (id, store) VALUES ('$id', '$data')");
  if ($result) {
    echo "true";
  }else{
    echo "connection fail";
    //echo mysqli_error($con);
  }
}else{
  echo "connection fail";
}
?>