# restaurant_recommendation_website

CS 3265 Project 2 is a website that allows users to search for the restaurants in Europe by different filters.

Use MYSQL Workbench 8.0 for building our database.

This directory provides all the source codes for website. 

To extract the correct data from our database, please follow this instruction:
Step 1: Open EuroRestaurantDB.sql. 
Step 2: Navigate to the query of LOAD DATA INFILE '/Users/stephanielin/Desktop/CS3265/project2/tripadvisor_european_restaurants.csv' INTO TABLE euro_restuarant.mega_table, change the path to the path of the csv file on your device.
Step 3: Run every line of codes in EuroRestaurantDB.sql to make sure all features are created properly. 

Environment set-up instruction: 

Step 1: Go to MAMP directory, and move all of the files to the htdocs folder. Start the MAMP server and MySQL workbench. To establish the connection to the data file, check your username, password, network address and port from MySQL workbench home page. 

Step 2: Open the p2conn.php file and change the variable "$dbhost  = '127.0.0.1';" and "$dbhost . ';port=8889;" according to the parameters on your local machine. 

Step 3: Click MAMP -> Preferences -> Ports. You'll get your Apache Port number (at lease 2 digits)  

e.g.  my port number is 8888 so my URL is localhost:8888/CS3265Project2_Pei_Lin/index.html in the address bar. You need to channge the port number here, and this should take you to the home page of the application.

EuroRestaurantDB.sql: source database code
project.css: styling sheet for the frontpage UI/UX design
index.html: homepage, including the introduction of our website
p2conn.php: php file with variables that establish the connection to our database server;
getByGenInfo.php: webpage, it allows users to search restaurants' general information
getByVegFriendly.php: webpage, it allows users to search vegetarian friendly restaurants that have vegan options by country
insertRestaurantRate.php: webpage, it allows users to insert a rating for a restaurant
getByRating5.php: webpage, it allows users to search top 100 popular restaurants that have rating of 5 by country
ownerDeleteRestaurant.php: webpage, it allows the restaurant owners to delete the information about a restaurant
