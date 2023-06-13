<?php

if (isset($_POST['field_submit'])) {

    require_once("p2conn.php");

    $var_restaurant_link = $_POST['field_restaurant_link'];
    $var_restaurant_name = $_POST['field_restaurant_name'];
    $var_country = $_POST['field_country'];
    $var_city = $_POST['field_city'];
    $var_address = $_POST['field_address'];


    $query = "CALL insert_restaurant(:restaurant_link, :restaurant_name, :country, :city, :address)";

    try
    {
      $prepared_stmt = $dbo->prepare($query);
      $prepared_stmt->bindValue(':restaurant_link', $var_restaurant_link, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':restaurant_name', $var_restaurant_name, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':country', $var_country, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':city', $var_city, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':address', $var_address, PDO::PARAM_STR);
      $result = $prepared_stmt->execute();

    }
    catch (PDOException $ex)
    { // Error in database processing.
      echo $sql . "<br>" . $error->getMessage(); // HTTP 500 - Internal Server Error
    }
}

?>

<html>
  <head>
    <!-- THe following is the stylesheet file. The CSS file decides look and feel -->
    <link rel="stylesheet" type="text/css" href="project.css" />
  </head> 

  <body>
    <div id="navbar">
      <ul>
        <li><a href="index.html">Home</a></li>
        <li><a href="getByGenInfo.php">Search Restaurants</a></li>
        <li><a href="insertRestaurantRate.php">Rate your Favourite Restaurants</a></li>
        <li><a href="getByVegFriendly.php">Are you a Vegetarian?</a></li>
        <li><a href="getByRating5.php">Top Rating Restaurants</a></li>
        <li><a href="insertRestaurant.php">Insert Your New Restaurant</a></li>
        <li><a href="ownerDeleteRestaurant.php">Delete Your Restaurant Info</a></li>
      </ul>
    </div>

<h1> Insert Restaurant </h1>

    <form method="post">
    	<label for="id_restaurant_link">Restaurant Link</label>
    	<input type="text" name="field_restaurant_link" id="id_restaurant_link">

    	<label for="id_restaurant_name">Restaurant Name</label>
    	<input type="text" name="field_restaurant_name" id="id_restaurant_name">

    	<label for="id_country">Country</label>
    	<input type="text" name="field_country" id="id_country">

    	<label for="id_city">City</label>
    	<input type="text" name="field_city" id="id_city">

    	<label for="id_address">Address</label>
    	<input type="text" name="field_address" id="id_address">

    	<input type="submit" name="field_submit" value="Submit">

    </form>
    <?php
      if (isset($_POST['field_submit'])) {
        if ($result && $prepared_stmt->rowCount() > 0) { ?>
          <h3>Restaurant was inserted successfully.</h3>
    <?php 
        } else { 
    ?>
          <h3> Sorry, there was an error. Please check the restaurant link you entered. </h3>
    <?php 
        }
      } 
    ?>


    
  </body>
</html>