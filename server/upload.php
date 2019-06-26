<?php 
	$firstName = $_POST["firstName"];
	$lastName  = $_POST["lastName"];
	$userId = $_POST["userId"];

	$target_dir = "./img/";

	if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_dir.$_FILES["file"]["name"])) 
	{
		echo json_encode([
			"Message" => "The file ".basename($_FILES["file"]["name"])." has been uploaded",
			"Status" => "OK",
			"userId" => $_REQUEST["userId"],
			"firstName" => $_REQUEST["firstName"],
			"lastName" => $_REQUEST["lastName"]
		]);
	} else 
	{
		echo json_encode([
			"Message" => "There was an error while uploading",
			"Status" => "Error",
			"userId" => $_REQUEST["userId"]
		]);

		// if (isset($_POST)) {
		// 	echo "data is in $_POST";	
		// }
	}

	if (isset($_FILES["file"]["tmp_name"])) {
		echo "\n".$_FILES["file"]["name"];
		echo "\n".$_FILES["file"]["type"];
	}


?>