
<?php

//Allow users to search restaurants that have rating of 5 by country
if (isset($_POST['field_submit'])) {

    require_once("p2conn.php");

    $var_restau_name = $_POST['field_restau_name'];
    $var_in_city = $_POST['field_in_city'];
    $var_rating = $_POST['field_rating'];

    $query = "CALL cust_rate(:restau_name, :in_city, :rating)";

 try
    {
      $prepared_stmt = $dbo->prepare($query);
      $prepared_stmt->bindValue(':restau_name', $var_restau_name, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':in_city', $var_in_city, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':rating', $var_rating, PDO::PARAM_STR);
      $prepared_stmt->execute();
      $result = $prepared_stmt->fetchAll();

    }
    catch (PDOException $ex)
    { // Error in database processing.
      echo $sql . "<br>" . $error->getMessage(); // HTTP 500 - Internal Server Error
    }
}
?>

<html>
  <head>
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

    <h1> We'd love to hear your voice!</h1>

    <form method="post">

      <label for="id_restau_name">Restaurant Name</label>
      <input type="text" name="field_restau_name" id ="id_restau_name">

      <label for="id_in_city">City Name</label>
      <input type="text" name="field_in_city" id ="id_in_city">

      <label for="id_rating">Rate it Here! (1-5) </label>
      <input type="text" name="field_rating" id ="id_rating">

      <input type="submit" name="field_submit" value="Enter">

    </form>
    <?php
      if (isset($_POST['field_submit'])) {
        if ($result && $prepared_stmt->rowCount() > 0) { ?>

              <h2>Updated Ratings:</h2>

              <table>
                <thead>
                  <tr>
                    <th>Restaurant Name</th>
                    <th>Average Rating</th>
                    <th>Total Reviews Count</th>

                  </tr>
                </thead>
                <tbody>

                  <?php foreach ($result as $row) { ?>

                    <tr>
                      <td><?php echo $row["restaurant_name"]; ?></td>
                      <td><?php echo $row["avg_rating"]; ?></td>
                      <td><?php echo $row["total_reviews_count"]; ?></td>

                    </tr>
                  <?php } ?>
                </tbody>
            </table>
            <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
            <script type="text/javascript" src="//cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
            <script>
            $(document).ready(function() {
                $('#specTable').DataTable();
            });
            </script>

        <?php } else { ?>
          Sorry, no restaurants found for <?php echo $_POST['field_restau_name']; ?> in <?php echo $_POST['field_in_city']; ?> (city). Make sure that the first letter you use in the city name is uppercase.
        <?php }
    } ?>


    <img id='i2' src= "insert_rate_pic.jpg" />

    		<l2> Locally sourced / Crafted with Love.</l2>

    		<footer>
    			<quote>Image credit: commons.wikimedia.org </quote>
    		</footer>

  </body>
</html>






