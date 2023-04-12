
<?php

//Allow users to search restaurants' general information
if (isset($_POST['field_submit'])) {

    require_once("p2conn.php");

    $var_res_name = $_POST['field_res_name'];

    $query = "CALL search_geninfo(:res_name)"; //call the procedure

 try
    {
      $prepared_stmt = $dbo->prepare($query);
      $prepared_stmt->bindValue(':res_name', $var_res_name, PDO::PARAM_STR);
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
    <link rel="stylesheet" type="text/css" href="//cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css"/>

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

    <h1> Hi, friends! Hope you are having a wonderful trip so far. Search the restaurants in Europe here.</h1>

    <form method="post">

      <label for="res_name">Restaurant Name</label>
      <input type="text" name="field_res_name" id ="id_res_name">

      <input type="submit" name="field_submit" value="Search" >
      <r> Enter a restaurant name. </r>

    </form>
    <?php
      if (isset($_POST['field_submit'])) {
        if ($result && $prepared_stmt->rowCount() > 0) { ?>

              <h2>Results</h2>

              <table>
                <thead>
                  <tr>
                    <th>Restaurant Name</th>
                    <th>Address</th>
                    <th>Price Level</th>
                    <th>Average rating</th>
                    <th>Open Days per Week</th>
                    <th>Open Hours on Monday</th>
                    <th>Open Hours on Tuesday</th>
                    <th>Open Hours on Wednesday</th>
                    <th>Open Hours on Thursday</th>
                    <th>Open Hours on Friday</th>
                    <th>Open Hours on Saturday</th>
                    <th>Open Hours on Sunday</th>
                  </tr>
                </thead>
                <tbody>

                  <?php foreach ($result as $row) { ?>

                    <tr>
                      <td><?php echo $row["restaurant_name"]; ?></td>
                      <td><?php echo $row["address"]; ?></td>
                      <td><?php echo $row["price_level"]; ?></td>
                      <td><?php echo $row["avg_rating"]; ?></td>
                      <td><?php echo $row["open_days_per_week"]; ?></td>
                      <td><?php echo $row["original_open_hours_Mon"]; ?></td>
                      <td><?php echo $row["original_open_hours_Tue"]; ?></td>
                      <td><?php echo $row["original_open_hours_Wed"]; ?></td>
                      <td><?php echo $row["original_open_hours_Thu"]; ?></td>
                      <td><?php echo $row["original_open_hours_Fri"]; ?></td>
                      <td><?php echo $row["original_open_hours_Sat"]; ?></td>
                      <td><?php echo $row["original_open_hours_Sun"]; ?></td>

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
          Sorry, no results found for this restaurant.
        <?php }
    } ?>


    <img id='i2' src= "restaurantNuevo.jpeg" />

    		<l2> Locally sourced / Crafted with Love.</l2>

    		<footer>
    			<quote>Image credit: commons.wikimedia.org </quote>
    		</footer>

  </body>
</html>






