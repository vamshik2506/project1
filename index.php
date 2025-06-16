<!DOCTYPE html>
<html>
<body>
<form method="POST">
  Name: <input type="text" name="firstname"><br>
  Email: <input type="email" name="email"><br>
  <input type="submit">
</form>
<?php
$servername = "${db_host}";
$username = "intel";
$password = "intel123";
$dbname = "intel";
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
if(isset($_POST['firstname']) && isset($_POST['email'])) {
  $firstname = $conn->real_escape_string($_POST['firstname']);
  $email = $conn->real_escape_string($_POST['email']);
  $sql = "INSERT INTO data (firstname, email) VALUES ('$firstname', '$email')";
  if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
  } else {
    echo "Error: " . $sql . "<br>" . $conn->error;
  }
  $conn->close();
}
?>
</body>
</html>
