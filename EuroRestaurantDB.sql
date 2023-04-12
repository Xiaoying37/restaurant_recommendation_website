-- Project2

# ------------------------------------------------------
# -------------------DATABASE CREATION------------------
# ------------------------------------------------------

DROP DATABASE IF EXISTS euro_restuarant;
CREATE DATABASE euro_restuarant;
USE euro_restuarant;

-- Create megatable to insert the orignial data
DROP TABLE IF EXISTS mega_table;
CREATE TABLE mega_table (
	restaurant_link VARCHAR(100),
    restaurant_name VARCHAR(500),
    original_location VARCHAR(500),
    country VARCHAR(20),
    region VARCHAR(45),
    province VARCHAR(60),
    city VARCHAR(60),
    address VARCHAR(500),
    latitude VARCHAR(15),
    longitude VARCHAR(15),
    claimed VARCHAR(10),
    awards VARCHAR(500),
    popularity_detailed VARCHAR(80),
    popularity_generic VARCHAR(80),
    top_tags VARCHAR(100),
    price_level VARCHAR(20),
    price_range VARCHAR(40),
    meals VARCHAR(100),
    cuisines VARCHAR(500),
    special_diets VARCHAR(80),
    features VARCHAR(800),
    vegetarian_friendly VARCHAR(1),
    vegan_options VARCHAR(1),
    gluten_free VARCHAR(1),
    original_open_hours VARCHAR(300),
    open_days_per_week VARCHAR(3),
    open_hours_per_week VARCHAR(20),
    working_shifts_per_week VARCHAR(20),
    avg_rating VARCHAR(3),
    total_reviews_count VARCHAR(10),
    default_language VARCHAR(20),
    reviews_count_in_default_language VARCHAR(10),
    excellent VARCHAR(10),
    very_good VARCHAR(10),
    average VARCHAR(10),
    poor VARCHAR(10),
    terrible VARCHAR(10),
    food VARCHAR(5),
    service VARCHAR(5),
    value_rating VARCHAR(5),
    atmosphere VARCHAR(5),
    keywords VARCHAR(300)
);

# ------------------------------------------------------
# ----------------------DATA INSERTION------------------
# ------------------------------------------------------

-- Load data into megatable
-- change it into your own path
LOAD DATA INFILE '/Users/stephanielin/Desktop/CS3265/project2/tripadvisor_european_restaurants.csv' INTO TABLE euro_restuarant.mega_table
    CHARACTER SET latin1
    FIELDS Terminated BY ',' 
    OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '\r\n'
    -- The first line is attribute names so ignore the first line
    IGNORE 1 ROWS;
    

# ------------------------------------------------------
# ---------------------Dependency Test------------------
# ------------------------------------------------------

-- To test whether there are restuarants with identical names. Turn out that there are many repeated names.
SELECT restaurant_name, count(*)
FROM mega_table
GROUP BY restaurant_name
HAVING count(*) > 1;

SELECT restaurant_name
FROM mega_table
GROUP BY restaurant_name
HAVING COUNT(DISTINCT restaurant_link) > 1;

-- To test whether there are restuarants with identical link. Turn out that none of them have indentical link. 
-- So we choose restaurant_link as primary key for later table.
SELECT restaurant_link, count(*)
FROM mega_table
GROUP BY restaurant_link
HAVING count(*) > 1;

SELECT restaurant_link
FROM mega_table
GROUP BY restaurant_link
HAVING COUNT(DISTINCT restaurant_name) > 1;

-- city, province -> country. FAIL
SELECT city, province
FROM mega_table
GROUP BY city, province
HAVING NOT (MIN(country) <=> MAX(country));

-- city, province, region -> country. SUCCEED.
SELECT city, province, region
FROM mega_table
GROUP BY city, province, region
HAVING NOT (MIN(country) <=> MAX(country));

-- address -> city. FAIL
SELECT address, COUNT(DISTINCT city)
FROM mega_table 
GROUP BY address
HAVING COUNT(DISTINCT city) > 1;

-- address -> latitude, longtitude. FAIL
SELECT address  
FROM mega_table 
GROUP BY address
HAVING COUNT(DISTINCT latitude) > 1 OR COUNT(DISTINCT longitude)>1;

-- price_range -> price_level. FAIL
SELECT price_range, count(price_level)
FROM mega_table
WHERE price_level != ''
GROUP BY price_range
HAVING COUNT(DISTINCT price_level) > 1;

-- vegan_options -> vegetarian_friendly. FAIL
SELECT vegan_options
FROM mega_table
GROUP BY vegan_options
HAVING COUNT(DISTINCT vegetarian_friendly) > 1;

# ------------------------------------------------------
# -----------------------DATA CLEANING------------------
# ------------------------------------------------------

SET SQL_SAFE_UPDATES = 0;

-- Keep only Dates and Hours in the attribute. Remove symbols like {, }, "
UPDATE mega_table
SET original_open_hours = REPLACE(original_open_hours, '{', '')
WHERE original_open_hours <> '';
UPDATE mega_table
SET original_open_hours = REPLACE(original_open_hours, '}', '')
WHERE original_open_hours <> '';
UPDATE mega_table
SET original_open_hours = REPLACE(original_open_hours, '"', '')
WHERE original_open_hours <> '';

-- In the mega table, the following attribues are varchar (easier to insert). 
-- However, these attributes are set into int or decmial, so we need to convert '' to null in order to insert. 
UPDATE mega_table
SET open_days_per_week = NULL
WHERE open_days_per_week = '';

UPDATE mega_table
SET open_hours_per_week = NULL
WHERE open_hours_per_week = '';

UPDATE mega_table
SET working_shifts_per_week = NULL
WHERE working_shifts_per_week = '';

UPDATE mega_table
SET avg_rating = NULL
WHERE avg_rating = '';

UPDATE mega_table
SET total_reviews_count = NULL
WHERE total_reviews_count = '';

UPDATE mega_table
SET reviews_count_in_default_language = NULL
WHERE reviews_count_in_default_language = '';

UPDATE mega_table
SET excellent = NULL
WHERE excellent = '';

UPDATE mega_table
SET very_good = NULL
WHERE very_good = '';

UPDATE mega_table
SET average = NULL
WHERE average = '';

UPDATE mega_table
SET poor = NULL
WHERE poor = '';

UPDATE mega_table
SET terrible = NULL
WHERE terrible = '';

UPDATE mega_table
SET food = NULL
WHERE food = '';

UPDATE mega_table
SET service = NULL
WHERE service = '';

UPDATE mega_table
SET value_rating = NULL
WHERE value_rating = '';

UPDATE mega_table
SET atmosphere = NULL
WHERE atmosphere = '';

# ------------------------------------------------------
# -----------------------DECOMPOSITION------------------
# ------------------------------------------------------

DROP TABLE IF EXISTS basic_info;
CREATE TABLE IF NOT EXISTS basic_info (
	restaurant_link VARCHAR(25) NOT NULL,
    restaurant_name VARCHAR(200) DEFAULT '',
    claimed VARCHAR(10) DEFAULT '',
    PRIMARY KEY (restaurant_link)
);

DROP TABLE IF EXISTS location;
CREATE TABLE IF NOT EXISTS location (
	restaurant_link VARCHAR(25) NOT NULL,
	country VARCHAR(20) DEFAULT '',
    latitude VARCHAR(15) DEFAULT '',
    longitude VARCHAR(15) DEFAULT '',
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_location FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS address_table;
CREATE TABLE IF NOT EXISTS address_table(
	restaurant_link VARCHAR(25) NOT NULL,
    region VARCHAR(45) DEFAULT '',
    province VARCHAR(60) DEFAULT '',
    city VARCHAR(60) DEFAULT '',
	address VARCHAR(500) DEFAULT '',
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_address FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS professional_evaluation;
CREATE TABLE IF NOT EXISTS professional_evaluation (
	restaurant_link VARCHAR(25) NOT NULL,
	popularity_detailed VARCHAR(80) DEFAULT '',
    popularity_generic VARCHAR(80) DEFAULT '',
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_prof FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

-- awards attributes have several values that are separated by comma
-- In order to obey 1NF rule, we create a saparate table for this attribute and will call split_awards procedure to split the values and then insert.
DROP TABLE IF EXISTS awards_table;
CREATE TABLE IF NOT EXISTS awards_table (
	restaurant_link VARCHAR(25) NOT NULL,
	awards VARCHAR(500) DEFAULT '',
    PRIMARY KEY (restaurant_link, awards),
	CONSTRAINT fk_link_awards FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

-- awards attributes have several values that are separated by comma
-- In order to obey 1NF rule, we create a saparate table for this attribute and will call split_res_features procedure to split the values and then insert.
DROP TABLE IF EXISTS res_features;
CREATE TABLE IF NOT EXISTS res_features (
	restaurant_link VARCHAR(25) NOT NULL,
	features VARCHAR(600) DEFAULT '',
    PRIMARY KEY (restaurant_link,features),
	CONSTRAINT fk_link_feat FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS price;
CREATE TABLE IF NOT EXISTS price (
	restaurant_link VARCHAR(25) NOT NULL,
	price_level VARCHAR(20) DEFAULT '',
    price_range VARCHAR(40) DEFAULT '',
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_price FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS special_option;
CREATE TABLE IF NOT EXISTS special_option (
	restaurant_link VARCHAR(25) NOT NULL,
    vegetarian_friendly VARCHAR(1) DEFAULT '',
    vegan_options VARCHAR(1) DEFAULT '',
    gluten_free VARCHAR(1) DEFAULT '',
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_option FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS hours;
CREATE TABLE IF NOT EXISTS hours (
	restaurant_link VARCHAR(25) NOT NULL,
-- divide the original_open_hours attribute in mega table into seven different date attributes to follow 1NF rule. 
    original_open_hours_Mon VARCHAR(100) DEFAULT '',
    original_open_hours_Tue VARCHAR(100) DEFAULT '',
    original_open_hours_Wed VARCHAR(100) DEFAULT '',
    original_open_hours_Thu VARCHAR(100) DEFAULT '',
    original_open_hours_Fri VARCHAR(100) DEFAULT '',
    original_open_hours_Sat VARCHAR(100) DEFAULT '',
    original_open_hours_Sun VARCHAR(100) DEFAULT '',
    open_days_per_week TINYINT UNSIGNED DEFAULT 0,
    open_hours_per_week DECIMAL(5,2) DEFAULT 0.0,
    working_shifts_per_week DECIMAL(4,2) DEFAULT 0.0,
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_hours FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS customer_rating;
CREATE TABLE IF NOT EXISTS customer_rating (
	restaurant_link VARCHAR(25) NOT NULL,
	avg_rating DECIMAL(2,1) DEFAULT 0.0,
    total_reviews_count INT UNSIGNED DEFAULT 0,
    default_language VARCHAR(20) DEFAULT '',
    reviews_count_in_default_language INT UNSIGNED DEFAULT 0,
    excellent INT UNSIGNED DEFAULT 0,
    very_good INT UNSIGNED DEFAULT 0,
    average INT UNSIGNED DEFAULT 0,
    poor INT UNSIGNED DEFAULT 0,
    terrible INT UNSIGNED DEFAULT 0,
    food DECIMAL(2,1) DEFAULT 0.0,
    service DECIMAL(2,1) DEFAULT 0.0,
    value_rating DECIMAL(2,1) DEFAULT 0.0,
    atmosphere DECIMAL(2,1) DEFAULT 0.0,
    PRIMARY KEY (restaurant_link),
	CONSTRAINT fk_link_cust FOREIGN KEY (restaurant_link)
		REFERENCES basic_info(restaurant_link)
        ON DELETE CASCADE
		ON UPDATE CASCADE
);

# ------------------------------------------------------
# ------------------------TRIGGERS----------------------
# ------------------------------------------------------

-- HOURS

DROP TRIGGER IF EXISTS hours_before_insert;

DELIMITER //

CREATE TRIGGER hours_before_insert
BEFORE INSERT
ON hours
FOR EACH ROW
BEGIN

-- We want only hours values so we remove other unnecessary characters

	-- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Mon <> '' THEN
        SET NEW.original_open_hours_Mon = REPLACE(NEW.original_open_hours_Mon, 'Mon: ', '');
        SET NEW.original_open_hours_Mon = REPLACE(NEW.original_open_hours_Mon, '[', '');
        SET NEW.original_open_hours_Mon = REPLACE(NEW.original_open_hours_Mon, ']', '');
        SET NEW.original_open_hours_Mon = REPLACE(NEW.original_open_hours_Mon, ', ', ' & ');
	END IF;
    
    -- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Tue <> '' THEN
        SET NEW.original_open_hours_Tue = REPLACE(NEW.original_open_hours_Tue, '[', '');
        SET NEW.original_open_hours_Tue = REPLACE(NEW.original_open_hours_Tue, ']', '');
        SET NEW.original_open_hours_Tue = REPLACE(NEW.original_open_hours_Tue, ', ', ' & ');
	END IF;
    
    -- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Wed <> '' THEN
        SET NEW.original_open_hours_Wed = REPLACE(NEW.original_open_hours_Wed, '[', '');
        SET NEW.original_open_hours_Wed = REPLACE(NEW.original_open_hours_Wed, ']', '');
        SET NEW.original_open_hours_Wed = REPLACE(NEW.original_open_hours_Wed, ', ', ' & ');
	END IF;
    
    -- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Thu <> '' THEN
        SET NEW.original_open_hours_Thu = REPLACE(NEW.original_open_hours_Thu, '[', '');
        SET NEW.original_open_hours_Thu = REPLACE(NEW.original_open_hours_Thu, ']', '');
        SET NEW.original_open_hours_Thu = REPLACE(NEW.original_open_hours_Thu, ', ', ' & ');
	END IF;
    
    -- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Fri <> '' THEN
        SET NEW.original_open_hours_Fri = REPLACE(NEW.original_open_hours_Fri, '[', '');
        SET NEW.original_open_hours_Fri = REPLACE(NEW.original_open_hours_Fri, ']', '');
        SET NEW.original_open_hours_Fri = REPLACE(NEW.original_open_hours_Fri, ', ', ' & ');
	END IF;
    
    -- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Sat <> '' THEN
        SET NEW.original_open_hours_Sat = REPLACE(NEW.original_open_hours_Sat, '[', '');
        SET NEW.original_open_hours_Sat = REPLACE(NEW.original_open_hours_Sat, ']', '');
        SET NEW.original_open_hours_Sat = REPLACE(NEW.original_open_hours_Sat, ', ', ' & ');
	END IF;
    
    -- As long as the variable is not empty string, we replace unnecessary characters
	IF NEW.original_open_hours_Sun <> '' THEN
        SET NEW.original_open_hours_Sun = REPLACE(NEW.original_open_hours_Sun, '[', '');
        SET NEW.original_open_hours_Sun = REPLACE(NEW.original_open_hours_Sun, ']', '');
        SET NEW.original_open_hours_Sun = REPLACE(NEW.original_open_hours_Sun, ', ', ' & ');
	END IF;

END //

DELIMITER ;

-- PRICE

DROP TRIGGER IF EXISTS price_before_insert;

DELIMITER //

-- Due to character set format when loading the original data, the orignal price symbol changes into strange characters
-- This trigger replaces all the strange characters with euro symbol when inserting data into price table
CREATE TRIGGER price_before_insert
BEFORE INSERT
ON price
FOR EACH ROW
BEGIN

	-- As long as the value is not empty string, we start the replacement process.
	IF NEW.price_level <> '' THEN
        SET NEW.price_level = REPLACE(NEW.price_level, 'â‚¬', '€');
	END IF;
    
    -- As long as the value is not empty string, we start the replacement process.
	IF NEW.price_range <> '' THEN
        SET NEW.price_range = REPLACE(NEW.price_range, 'â‚¬', '€');
	END IF;

END //

DELIMITER ; 

# ------------------------------------------------------
# ------------STORED PROCEDURES FOR INSERT--------------
# ------------------------------------------------------

-- split_awards

DROP PROCEDURE IF EXISTS split_awards;

DELIMITER //

-- The awards attribue in megta_table has comma separated values.
-- To follow 1NF rule, we split those values and insert them one by one. 
CREATE PROCEDURE split_awards()

BEGIN

	DECLARE stop_time INT;
	DECLARE i INT DEFAULT 2;
    DECLARE index_number INT DEFAULT 2;
    
    -- Find out the maximum number of commas among different values in awards attribute
    SET stop_time = (SELECT max(CHAR_LENGTH(awards) - CHAR_LENGTH(REPLACE(awards,',','')) + 1)
						FROM mega_table);
    
	-- To insert the value before the first comma or value that has no comma
    INSERT INTO awards_table
	SELECT restaurant_link, substring_index (awards,',',1 )
	FROM mega_table
    WHERE awards != '';

    loop_label: LOOP
    
		-- Stop when we reach the last comma
        IF i = stop_time THEN
			LEAVE loop_label;
		END IF;
    
		INSERT INTO awards_table
        -- substring and the value before a certain comma
		SELECT restaurant_link, SUBSTRING_INDEX(SUBSTRING_INDEX(awards,',', index_number),',', -1)
		FROM mega_table
		WHERE SUBSTRING_INDEX(SUBSTRING_INDEX(awards,',', index_number-1),',', -1) != SUBSTRING_INDEX(awards,',', -1);
        
        SET i = i + 1;
        SET index_number = index_number + 1;
        
	END LOOP;

END //

DELIMITER ;


-- split res_features

DROP PROCEDURE IF EXISTS split_res_features;

DELIMITER //

CREATE PROCEDURE split_res_features()

BEGIN

	DECLARE stop_time INT;
	DECLARE i INT DEFAULT 2;
    DECLARE index_number INT DEFAULT 2;
    
    -- Find out the maximum number of commas among different values in features attribute
    SET stop_time = (SELECT max(CHAR_LENGTH(features) - CHAR_LENGTH(REPLACE(features,',','')) + 1)
						FROM mega_table);
    
    -- To insert the value before the first comma or value that has no comma
	INSERT INTO res_features
	SELECT restaurant_link, substring_index (features,',',1 )
	FROM mega_table
	WHERE features != '';
    
    loop_label: LOOP
    
		-- Stop when we reach the last comma
		IF i = stop_time THEN
			LEAVE loop_label;
		END IF;
    
		INSERT INTO res_features
        -- substring and the value before a certain comma
		SELECT restaurant_link,SUBSTRING_INDEX(SUBSTRING_INDEX(features,',', index_number),',', -1)
		FROM mega_table
		WHERE SUBSTRING_INDEX(SUBSTRING_INDEX(features,',', index_number-1),',', -1) != SUBSTRING_INDEX(features,',', -1);
        
        SET i = i + 1;
        SET index_number = index_number + 1;
        
	END LOOP;

END //

DELIMITER ;

# ------------------------------------------------------
# ------------INSERT INTO DECOMPOSED TABLES-------------
# ------------------------------------------------------

INSERT INTO basic_info
	SELECT restaurant_link, 
		restaurant_name, 
		claimed
	FROM mega_table;
    
INSERT INTO location
	SELECT restaurant_link, 
    country, 
    latitude, 
    longitude
	FROM mega_table;
    
INSERT INTO address_table
	SELECT restaurant_link, 
    region, 
    province, 
    city, 
    address
	FROM mega_table;
    
INSERT INTO professional_evaluation
	SELECT restaurant_link, 
        popularity_detailed, 
        popularity_generic
	FROM mega_table;

INSERT INTO price
	SELECT restaurant_link, 
		price_level, 
        price_range
	FROM mega_table;
    
INSERT INTO special_option
	SELECT restaurant_link, 
		vegetarian_friendly, 
        vegan_options, 
        gluten_free
	FROM mega_table;

-- This insert takes about 50+ seconds to finish.
-- To avoid lost sql server connnection error, try increasing the DBMS connection read time out and connection keep-alive interval values. 
INSERT INTO hours
	SELECT restaurant_link,
		SUBSTRING_INDEX(original_open_hours , ', Tue', 1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(original_open_hours , ', Wed', 1), 'Tue:', -1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(original_open_hours , ', Thu', 1), 'Wed:', -1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(original_open_hours , ', Fri', 1), 'Thu:', -1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(original_open_hours , ', Sat', 1), 'Fri:', -1),
        SUBSTRING_INDEX(SUBSTRING_INDEX(original_open_hours , ', Sun', 1), 'Sat:', -1),
        SUBSTRING_INDEX(original_open_hours , 'Sun: ', -1),
        open_days_per_week, 
        open_hours_per_week, 
        working_shifts_per_week
	FROM mega_table;
    
INSERT INTO customer_rating
	SELECT restaurant_link, 
		avg_rating, 
        total_reviews_count, 
        default_language, 
        reviews_count_in_default_language, 
        excellent, 
        very_good, 
        average, 
        poor, 
        terrible, 
        food, 
        service, 
        value_rating, 
        atmosphere
	FROM mega_table;
    
CALL split_awards();

CALL split_res_features();
    
# ------------------------------------------------------
# --------------------------VIEWS-----------------------
# ------------------------------------------------------

-- show popular restuarants that have average rating of 5
DROP VIEW IF EXISTS res_avg_rating_5;
CREATE VIEW res_avg_rating_5 AS
SELECT restaurant_name, country, address, total_reviews_count, popularity_detailed, popularity_generic
FROM basic_info
	JOIN customer_rating ON basic_info.restaurant_link = customer_rating.restaurant_link
    JOIN professional_evaluation ON basic_info.restaurant_link = professional_evaluation.restaurant_link
    JOIN location ON basic_info.restaurant_link = location.restaurant_link
	JOIN address_table ON basic_info.restaurant_link = address_table.restaurant_link
WHERE avg_rating = 5.0
ORDER BY total_reviews_count DESC;

-- show restuarants that are both vegetarian friendly and provide vegan options
DROP VIEW IF EXISTS res_vege_vegan;
CREATE VIEW res_vege_vegan AS
SELECT restaurant_name, country, city, address
FROM basic_info
    JOIN special_option ON basic_info.restaurant_link = special_option.restaurant_link
    JOIN location ON basic_info.restaurant_link = location.restaurant_link
	JOIN address_table ON basic_info.restaurant_link = address_table.restaurant_link
WHERE vegetarian_friendly = 'Y' AND vegan_options = 'Y';

-- show restuarants that are vegetarian friendly
DROP VIEW IF EXISTS res_vege;
CREATE VIEW res_vege AS
SELECT restaurant_name, country, city, address
FROM basic_info
    JOIN special_option ON basic_info.restaurant_link = special_option.restaurant_link
    JOIN location ON basic_info.restaurant_link = location.restaurant_link
	JOIN address_table ON basic_info.restaurant_link = address_table.restaurant_link
WHERE vegetarian_friendly = 'Y';

-- show restuarants that provide vegan options
DROP VIEW IF EXISTS res_vegan;
CREATE VIEW res_vegan AS
SELECT restaurant_name, country, city, address
FROM basic_info
    JOIN special_option ON basic_info.restaurant_link = special_option.restaurant_link
    JOIN location ON basic_info.restaurant_link = location.restaurant_link
	JOIN address_table ON basic_info.restaurant_link = address_table.restaurant_link
WHERE vegan_options = 'Y';

# ------------------------------------------------------
# ------------------STORED PROCEDURES-------------------
# ------------------------------------------------------

-- Allow users to search vegetarian friendly restaurants that have vegan options by country
DROP PROCEDURE IF EXISTS search_vegan_vege;

DELIMITER //

CREATE PROCEDURE search_vegan_vege(IN country_name VARCHAR(100), city_name VARCHAR(100), IN vegan VARCHAR(3), IN vege VARCHAR(3))

BEGIN

	-- make sure the country name and city name users give match with the information in database
	IF country_name IN (SELECT country FROM location) AND city_name IN (SELECT city FROM address_table) THEN
    
		-- Search for restaurants that are both vegetarian friendly and provide vegan options using res_vege_vegan view
        IF vegan = 'Yes' AND vege = 'Yes' THEN
			SELECT restaurant_name, country, city, address
			FROM res_vege_vegan
			WHERE country = country_name AND city = city_name;
		END IF;
		
		-- search for restuarants that provide vegan options using res_vegan view
		IF vegan = 'Yes' AND vege = '/' THEN
			SELECT restaurant_name, country, city, address
			FROM res_vegan
			WHERE country = country_name AND city = city_name;
		END IF;
        
        -- search for restuarants that are vegetarian friendly using res_vege view
		IF vegan = '/' AND vege = 'Yes' THEN
			SELECT restaurant_name, country, city, address
			FROM res_vege
			WHERE country = country_name AND city = city_name;
		END IF;
        
	END IF;

END //

DELIMITER ;

-- TEST 
CALL search_vegan_vege('England', 'Ferndown', 'Yes', 'Yes');
CALL search_vegan_vege('England', 'Ferndown', 'Yes', '/');
CALL search_vegan_vege('England', 'Ferndown', '/', 'Yes');


-- Allow users to search restaurants' general information
DROP PROCEDURE IF EXISTS search_geninfo;

DELIMITER //

CREATE PROCEDURE search_geninfo (IN res_name VARCHAR(300))

BEGIN

	-- make sure the restaurant name users give matches with the restaurant name information in database
	IF res_name IN (SELECT restaurant_name FROM basic_info) THEN
		SELECT restaurant_name,
				address,
                price_level, 
                avg_rating, 
                open_days_per_week, 
                original_open_hours_Mon, 
				original_open_hours_Tue, 
				original_open_hours_Wed, 
				original_open_hours_Thu, 
				original_open_hours_Fri,
				original_open_hours_Sat,
				original_open_hours_Sun
		FROM basic_info
			JOIN address_table ON basic_info.restaurant_link = address_table.restaurant_link
			JOIN hours ON basic_info.restaurant_link = hours.restaurant_link
            JOIN price ON basic_info.restaurant_link = price.restaurant_link
            JOIN customer_rating ON basic_info.restaurant_link = customer_rating.restaurant_link
		WHERE restaurant_name = res_name;
	END IF;

END //

DELIMITER ;

-- TEST1 Successfully find
CALL search_geninfo('Le 147');
UPDATE customer_rating
SET avg_rating = 4.0
WHERE restaurant_link = 'g187175-d2560504';
CALL search_geninfo('XiaoyingLin');

SELECT *
FROM basic_info
WHERE restaurant_name = 'testrun';


-- Allow users to search top 100 popular restaurants that have average rating of 5 by country and city
DROP PROCEDURE IF EXISTS search_res_rating_5;

DELIMITER //

CREATE PROCEDURE search_res_rating_5(IN country_name VARCHAR(100), IN city_name VARCHAR(100))

BEGIN

	-- make sure the country name and city name users give match with the information in database
	IF country_name IN (SELECT country FROM location) AND city_name IN (SELECT city FROM address_table) THEN
		SELECT restaurant_name, address, total_reviews_count, popularity_detailed, popularity_generic
		FROM res_avg_rating_5
		WHERE country = country_name
        LIMIT 100;
	END IF;

END //

DELIMITER ;

-- TEST
CALL search_res_rating_5('France', 'Franconville');



-- Allow users to insert a rating for a restaurant
DROP PROCEDURE IF EXISTS cust_rate;

DELIMITER //

CREATE PROCEDURE cust_rate (IN restau_name VARCHAR(100), IN in_city VARCHAR(100), IN rating TINYINT)

BEGIN

    DECLARE updated_count INT UNSIGNED;
	DECLARE updated_rating DECIMAL(2,1);
    DECLARE current_count INT UNSIGNED;
    DECLARE current_rating DECIMAL(2,1);
	DECLARE link VARCHAR(100);

	-- make sure the restaurant name and city name users give match with the information in database
    -- make sure the rating provided is valid, within 1-5
	IF restau_name IN (SELECT restaurant_name FROM basic_info) AND in_city IN (SELECT city FROM address_table) AND rating IN (1,2,3,4,5) THEN
		
		-- find out the restaurant_link of the restaurant 
        SET link = (SELECT basic_info.restaurant_link 
					FROM basic_info
						JOIN address_table ON basic_info.restaurant_link = address_table.restaurant_link
                    WHERE restaurant_name = restau_name AND city = in_city);
        
        SET current_count = (SELECT total_reviews_count FROM customer_rating WHERE restaurant_link = link);
        
        SET current_rating = (SELECT avg_rating FROM customer_rating WHERE restaurant_link = link);
		
        -- total rating counts increases by 1 after each valid rating insertion
        SET updated_count = current_count + 1;
        -- calculate the new average rating
        SET updated_rating = ((current_rating * current_count) + rating) / updated_count;
        
        UPDATE customer_rating
        SET avg_rating  = updated_rating
        WHERE restaurant_link = link;
        
        UPDATE customer_rating
        SET total_reviews_count  = updated_count
        WHERE restaurant_link = link;
        
        -- updadate the corresponding rating categories count
        
        IF rating = 1 THEN
			UPDATE customer_rating
            SET terrible = terrible + 1
            WHERE restaurant_link = link;
		END IF;
            
		IF rating = 2 THEN
			UPDATE customer_rating
            SET poor = poor + 1
            WHERE restaurant_link = link;
		END IF;
            
		IF rating = 3 THEN
			UPDATE customer_rating
            SET average = average + 1
            WHERE restaurant_link = link;
		END IF;
            
		IF rating = 4 THEN
			UPDATE customer_rating
            SET very_good = very_good + 1
            WHERE restaurant_link = link;
		END IF;
            
		IF rating = 5 THEN
			UPDATE customer_rating
            SET excellent = excellent + 1
            WHERE restaurant_link = link;
		END IF;
        
        SELECT restaurant_name, avg_rating, total_reviews_count
        FROM basic_info
			JOIN customer_rating ON basic_info.restaurant_link = customer_rating.restaurant_link
		WHERE basic_info.restaurant_link = link;
        
	END IF;
        
END//

DELIMITER ; 

-- TEST
CALL cust_rate('Le Saint Jouvent','Saint-Jouvent',4);
CALL cust_rate('Le 147', 'Saint-Jouvent', 2);
CALL cust_rate('Le 147', 'Saint-Jouvent', 1);


-- 	Allow restaurant owners to delete the information about a restaurant
DROP PROCEDURE IF EXISTS delete_restaurant;

DELIMITER //

CREATE PROCEDURE delete_restaurant (IN user_link VARCHAR(100))

BEGIN

	-- make sure the restaurant link user enters is valid
	IF user_link IN (SELECT restaurant_link FROM basic_info) THEN
		DELETE FROM basic_info
        WHERE restaurant_link = user_link;
	END IF;
    
END //

DELIMITER ;

-- TEST
CALL delete_restaurant('g1005749-d1334370');



-- INSERT A NEW RESTAURANT
DROP PROCEDURE IF EXISTS insert_restaurant;

DELIMITER //

CREATE PROCEDURE insert_restaurant (IN user_link VARCHAR(100), IN user_name VARCHAR(500), IN user_country VARCHAR(20), IN user_city VARCHAR(60), IN user_address VARCHAR(500))

BEGIN

	-- make sure the restaruant_linnk doesn't exist in our database because restaurant link is different for different restaurant.
	IF user_link NOT IN (SELECT restaurant_link FROM basic_info) THEN 

		INSERT INTO basic_info(restaurant_link, restaurant_name)
		VALUES (user_link, user_name);
    
		INSERT INTO address_table(restaurant_link, city, address)
		VALUES (user_link, user_city, user_address);
    
		INSERT INTO location(restaurant_link, country)
		VALUES (user_link, user_country);
        
        INSERT INTO awards_table (restaurant_link)
        VALUES (user_link);
        
		INSERT INTO customer_rating (restaurant_link)
        VALUES (user_link);
        
        INSERT INTO hours(restaurant_link)
        VALUES (user_link);
        
        INSERT INTO price (restaurant_link)
        VALUES (user_link);
        
        INSERT INTO professional_evaluation (restaurant_link)
        VALUES (user_link);
        
        INSERT INTO res_features (restaurant_link)
        VALUES (user_link);
        
        INSERT INTO special_option (restaurant_link)
        VALUES (user_link);
        
	END IF;
    
END //

DELIMITER ;

-- TEST
CALL insert_restaurant('g87654234-c0307', 'StephanieLin', 'England', 'London', '2301 High Street London England');
CALL insert_restaurant('g87654234-c0308', 'StephanieLin1', 'England', 'London', '2301 High Street London England');

		