
<?php

//Allow users to search vegetarian friendly restaurants that have vegan options by country
if (isset($_POST['field_submit'])) {

    require_once("p2conn.php");

    $var_country_name= $_POST['field_country_name'];
    $var_city_name= $_POST['field_city_name'];
    $var_vegan= $_POST['field_vegan'];
    $var_vege= $_POST['field_vege'];

    $query = "CALL search_vegan_vege(:country_name, :city_name, :vegan, :vege)"; //call the procedure

 try
    {
      $prepared_stmt = $dbo->prepare($query);
      $prepared_stmt->bindValue(':country_name', $var_country_name, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':city_name', $var_city_name, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':vegan', $var_vegan, PDO::PARAM_STR);
      $prepared_stmt->bindValue(':vege', $var_vege, PDO::PARAM_STR);
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

    <h1> Vegetarians can also enjoy the food in European cities! </h1>

<form method="post">

      <label for="id_country_name">Country Name</label>
      <input type="text" name="field_country_name" id ="id_country_name">

       <label for="id_city_name">City Name</label>
        <input type="text" name="field_city_name" id ="id_city_name">

       <label for="id_vegan">Option 1: Restaurants that are vegetarian-friendly. Enter "Yes" or "/". </label>
       <input type="text" name="field_vegan" id ="id_vegan">

       <label for="id_vege">Option 2: Restaurants that provide the vegan options. Enter "Yes" or "/".</label>
       <input type="text" name="field_vege" id ="id_vege">

      <input type="submit" name="field_submit" value="Search">

    </form>
    <?php
      if (isset($_POST['field_submit'])) {
        if ($result && $prepared_stmt->rowCount() > 0) { ?>

              <h2>Results</h2>

              <table>
                <thead>
                  <tr>
                    <th>Restaurant Name</th>
                    <th>Country</th>
                    <th>City</th>
                    <th>Address</th>
                  </tr>
                </thead>
                <tbody>

                  <?php foreach ($result as $row) { ?>

                    <tr>
                      <td><?php echo $row["restaurant_name"]; ?></td>
                      <td><?php echo $row["city"]; ?></td>
                      <td><?php echo $row["country"]; ?></td>
                      <td><?php echo $row["address"]; ?></td>

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
          Sorry, no results found for <?php echo $_POST['field_city_name']; ?> (city) in <?php echo $_POST['field_country_name']; ?> (country).
        <?php }
    } ?>


    <img id='i2' src= "ItalianResPic.jpeg" />


    		<l2> Locally sourced / Crafted with Love.</l2>

    		<footer>
    			<quote>Image credit: commons.wikimedia.org </quote>
    		</footer>
  </body>
</html>






