<?php
// If the all the variables are set when the Submit button is clicked...
if (isset($_POST['field_submit'])) {

    require_once("p2conn.php");

    $var_restaurant_link = $_POST['field_restaurant_link'];

    $query = "CALL delete_restaurant(:restaurant_link)";

    try
    {
      $prepared_stmt = $dbo->prepare($query);

      $prepared_stmt->bindValue(':restaurant_link', $var_restaurant_link, PDO::PARAM_STR);

        $result = $prepared_stmt->execute();

    }
    catch (PDOException $ex)
    { // Error in database processing.
      echo $sql . "<br>" . $error->getMessage(); // HTTP 500 - Internal Server Error
    }
}

?>

<html>
  <!-- Any thing inside the HEAD tags are not visible on page.-->
  <head>
    <!-- THe following is the stylesheet file. The CSS file decides look and feel -->
    <link rel="stylesheet" type="text/css" href="project.css" />
  </head>

  <!-- Everything inside the BODY tags are visible on page.-->
  <body>
     <!-- See the project.css file to see how is navbar stylized.-->
    <div id="navbar">
      <!-- See the project.css file to note how ul (unordered list) is stylized.-->
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

    <h1> During COVID-19, many restaurant owners have to shut down their stores...  </h1>
    <h3>     We're so sorry about this, and this page is to help you delete the info of your restaurant. </h3>
    <!-- This is the start of the form. This form has one text field and one button.
      See the project.css file to note how form is stylized.-->
    <form method="post">

      <label for="id_restaurant_link">Your Restaurant link</label>

      <input type="text" name="field_restaurant_link" id = "id_restaurant_link">

      <input type="submit" name="field_submit" value="Delete your Restaurant">
    </form>

    <?php
      if (isset($_POST['field_submit'])) {
        if ($result && $prepared_stmt->rowCount() > 0) { ?>

          <h3>Restaurant was deleted successfully.</h3>
    <?php
        } else {
    ?>
          <h3> Sorry, there was an error. Restaurant data was not deleted. </h3>
    <?php
        }
      }
    ?>

         <img id='i2' src= "restaurant_interior.jpeg" />

         <l2> Locally sourced / Crafted with Love.</l2>

          <footer>
             	<quote>Image credit: commons.wikimedia.org </quote>
          </footer>
  </body>
</html>