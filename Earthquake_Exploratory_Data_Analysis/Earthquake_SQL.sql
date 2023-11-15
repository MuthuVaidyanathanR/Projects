/* ------------------------------------------------------------------------------------------------------------------------------ 
|																																|
|			Seismic Surveillance: An In-Depth Analysis of Earthquake Trends and Patterns in the Indian Subcontinent   		    |
|																																|
-------------------------------------------------------------------------------------------------------------------------------*/




/* ---------------------------------------------------------------------- 
|																		|
|						I. DATA EXPLORATION								|
|																		|
-----------------------------------------------------------------------*/

-- 1. Creating and Using Database.
CREATE DATABASE EARTHQUAKE;
USE EARTHQUAKE;

--  Sets up the Earthquake database and selects it for use.


-- 2. Data Exploration and Viewing Tables.
 
SHOW TABLES;
DESCRIBE Earthquakes;


SELECT * FROM Jan_1997_to_dec_1999;
SELECT * FROM Jan_2000_to_may_2003;
SELECT * FROM Jun_2003_to_may_2012;
SELECT * FROM Jun_2012_to_may_2020;
SELECT * FROM Jun_2020_to_Dec_2022;


SHOW TABLES;

/* ---------------------------------------------------------------------- 
|																		|
|						II. DATA PREPROCESSING							|
|																		|
----------------------------------------------------------------------- */
-- 1. Creating a Combined Table.

-- Combining Earthquake Records into a Single Table, Create a combined table.  
START TRANSACTION;

CREATE TABLE Earthquakes AS
	SELECT * FROM Jan_1997_to_dec_1999 
		UNION ALL 
	SELECT * FROM Jan_2000_to_may_2003 
		UNION ALL 
	SELECT * FROM Jun_2003_to_may_2012 
		UNION ALL 
	SELECT * FROM Jun_2012_to_may_2020 
		UNION ALL 
	SELECT * FROM Jun_2020_to_Dec_2022;
COMMIT;

-- This combines multiple earthquake data tables into a single unified table.

SELECT * FROM EARTHQUAKES;

-- 2. Schema Enhancement by Adding New Columns.
START TRANSACTION;
ALTER TABLE earthquakes
ADD COLUMN Scales VARCHAR(255),
ADD COLUMN Distance VARCHAR(255),
ADD COLUMN Direction VARCHAR(255),
ADD COLUMN City VARCHAR(255),
ADD COLUMN Region VARCHAR(255),
ADD COLUMN Country VARCHAR(255);
COMMIT;
-- Expanding earthquakes table schema with additional columns.



-- 3. Index Creation for Optimization.

CREATE INDEX IDX_MAGNITUDE_DEPTH ON EARTHQUAKES (MAGNITUDE, DEPTH);

--  Creating Index an index on Magnitude and Depth columns to improve query performance




/* ---------------------------------------------------------------------- 
|																		|
|						III. DATA CLEANING								|
|																		|
----------------------------------------------------------------------- */

-- 1. Data Extraction and Standardization from Location Information.
SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;
UPDATE EARTHQUAKES 
SET 
    DISTANCE = TRIM(SUBSTRING_INDEX(LOCATION, ' ', 1)),
    DIRECTION = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(LOCATION, ' ', 2), ' ', - 1)),
    CITY = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(LOCATION, 'OF ', - 1), ',',    1)),
    REGION = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(LOCATION, ', ', - 2), ',', 1)),
    COUNTRY = TRIM(SUBSTRING_INDEX(LOCATION, ', ', - 1));
 COMMIT;      
  /* 
  -- To extract and clean specific geographical data, including distance, direction, city, region, and country.
  -- Each of these new fields is populated by parsing and trimming relevant sub-strings from the location.
  */
  
  
-- 2. Correcting Country and Region Fields.
START TRANSACTION;
UPDATE EARTHQUAKES 
SET 
    COUNTRY = CASE
        WHEN COUNTRY REGEXP '^[0-9]' THEN TRIM(SUBSTRING_INDEX(LOCATION, ',', - 1))
        ELSE COUNTRY
    END,
    REGION = CASE
        WHEN COUNTRY REGEXP '^[0-9]'
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(LOCATION, ',', - 2), ',', 1))
        ELSE REGION
    END;
COMMIT; 
 /*
 Updates the COUNTRY and REGION columns to correct records where COUNTRY starts with a numeric value, which indicates incorrect data.
 It uses the LOCATION field to appropriately reassign values to these columns.
 */
-- UPDATING SCALES

-- 3. Updating Scales Based on Magnitude.
START TRANSACTION;
UPDATE EARTHQUAKES
SET SCALES = REGEXP_REPLACE(MAGNITUDE, '[^A-Za-z]', '');
COMMIT;
/*
To extract any alphabetical characters from the MAGNITUDE column to create a new SCALES column, which presumably represents some categorical scale based on magnitude.
*/

-- 4. Handling Missing Scales.
START TRANSACTION;
UPDATE EARTHQUAKES
SET SCALES = 'Unknown'
WHERE SCALES IS NULL OR SCALES = '';
COMMIT;
/*
Ensures that any empty or null entries in the SCALES column are filled with a default value of 'Unknown', thereby maintaining data consistency.
*/


-- 5.Cleaning the Distance Column.

-- cleaning the Distance column
START TRANSACTION;
UPDATE EARTHQUAKES
SET DISTANCE = REGEXP_REPLACE(DISTANCE, '[A-Za-z]', '');
COMMIT;
-- Cleaning  the DISTANCE column by removing any alphabetical characters, likely standardizing it to numeric values for consistent analysis.

-- 6. Verifying the Country Column Post-Cleaning.
SELECT * FROM EARTHQUAKES
WHERE COUNTRY REGEXP'^[0-9]';

/*
 Checks the COUNTRY column after the cleaning process to ensure that no records still have numeric values, which would indicate remaining data inaccuracies.
*/


-- 7. Identifying Inaccurate Country Entries.
-- Identifying and Rectifying Misclassified Country Entries
SELECT * FROM EARTHQUAKES
WHERE COUNTRY NOT REGEXP 'India|Afghanistan|Nepal|Pakistan|Myanmar|Kyrgyzstan|Malaysia|Bangladesh|Bhutan|China|Maldives|Mongolia|Oman|Seychelles|Sri Lanka|Tajikistan|Uzbekistan|Turkmenistan|Thailand';

/*
Identifies records where the country field does not match a predefined list of expected country names. 
This step is crucial for pinpointing data that might be misclassified or incorrectly entered.
*/



-- 8. Listing Unique Non-Conforming Country Fields.
SELECT DISTINCT COUNTRY FROM EARTHQUAKES
WHERE COUNTRY NOT REGEXP 'India|Afghanistan|Nepal|Pakistan|Myanmar|Kyrgyzstan|Malaysia|Bangladesh|Bhutan|China|Maldives|Mongolia|Oman|Seychelles|Sri Lanka|Tajikistan|Uzbekistan|Turkmenistan|Thailand';
/*
Extracts a list of distinct 'country' values that do not conform to the expected set of country names.
It is helps in understanding the extent and nature of the data irregularities.
*/


-- 9. Correcting Region Based on Country Anomalies.
SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;
UPDATE EARTHQUAKES
SET REGION = CASE
    WHEN COUNTRY NOT REGEXP'India|Afghanistan|Nepal|Pakistan|Myanmar|Kyrgyzstan|Malaysia|Bangladesh|Bhutan|China|Maldives|Mongolia|Oman|Seychelles|Sri Lanka|Tajikistan|Uzbekistan|Turkmenistan|Thailand' THEN Country
    ELSE REGION END;
COMMIT;    
-- Updates the region field to what is currently in the country field. To correct mislabeled geographical data.



-- 10. Standardizing Misclassified Country Names to 'India'.
START TRANSACTION;
UPDATE EARTHQUAKES
SET COUNTRY = CASE
    WHEN COUNTRY NOT REGEXP'India|Afghanistan|Nepal|Pakistan|Myanmar|Kyrgyzstan|Malaysia|Bangladesh|Bhutan|China|Maldives|Mongolia|Oman|Seychelles|Sri Lanka|Tajikistan|Uzbekistan|Turkmenistan|Thailand' THEN "India"
    ELSE COUNTRY
END;
COMMIT;
/*
For records where the country field contains values not matching any known country names (likely due to misclassification), 
the country field is standardized to "India". 
*/



-- 11. Identifying and Addressing Inaccurate Region Entries.

SELECT DISTINCT REGION FROM EARTHQUAKES
WHERE REGION NOT REGEXP'^[0-9]'  AND COUNTRY = "INDIA";

SELECT * FROM EARTHQUAKES
WHERE REGION REGEXP'^[0-9]' AND COUNTRY = "INDIA";
--  Identify records where the region field might contain numerical values or other inaccuracies, specifically focusing on the records related to India



-- 12. Aggregating City Data for Inaccurate Region Records.

-- Aggregation of City Data for Records with Inaccurate Region Names.

SELECT DISTINCT CITY, COUNT(*) AS COUNT FROM EARTHQUAKES
WHERE REGION REGEXP'^[0-9]' AND COUNTRY = "INDIA"
GROUP BY CITY;
-- Aggregates city data for records with numerical or incorrect region names, helping to understand the distribution and count of such records.



-- 13. Updating Region Based on City Information.
START TRANSACTION;
UPDATE EARTHQUAKES
SET REGION = 
				CASE 
                WHEN CITY REGEXP'Kolkata|Darjeeling' THEN "West Bengal"
                WHEN City REGEXP"Akola|Mumbai" THEN "Maharashtra"
                WHEN city = "Agartala" THEN "Tripura"
                WHEN City = "Alchi(Leh)" THEN "Jammu and Kashmir"
                WHEN city = "Aizawal" THEN "Mizoram" 
                WHEN city = "Kavaratti" THEN "Lakshadweep Island"
                WHEN city = "New Delhi" THEN "New Delhi"
                WHEN city = "Agra" THEN "Uttar Pradesh"
                ELSE Region
                END;
COMMIT;                
-- Updating the region field based on the corresponding city information, ensuring that each earthquake record is categorized correctly.




-- 14. Standardizing Region Names.
START TRANSACTION;
UPDATE EARTHQUAKES
SET REGION = CASE 
				WHEN REGION = "Jammu & Kashmir" THEN "Jammu and Kashmir"
                WHEN REGION = "Lakshsdweep Island" THEN "Lakshadweep Island"
                ELSE REGION
                END;
COMMIT;
-- Standardizes the names of regions to ensure consistency across the dataset.

-- cleaning Non Indian region in region column

-- 15. Identification of Non-Indian Records with Numerical Region Values.
SELECT * FROM EARTHQUAKES
WHERE REGION REGEXP'^[0-9]' AND COUNTRY <> "INDIA";

-- Finds records where the region field contains numerical values and the country is not India.


-- 16. Aggregation of City Data for Non-Indian Regions.

SELECT DISTINCT CITY, COUNT(*), COUNTRY AS COUNT FROM EARTHQUAKES
WHERE REGION REGEXP'^[0-9]' AND COUNTRY <> "INDIA"
GROUP BY CITY, COUNTRY;

-- Aggregation helps understand the distribution and count of non-Indian records with numerical regions, grouped by city and country.



-- 17. Standardizing Non-Indian Region Entries.
START TRANSACTION;
UPDATE EARTHQUAKES
SET REGION = CASE
    WHEN REGION REGEXP'^[0-9]' THEN "Non_Indian"
    ELSE REGION
    END;
COMMIT;
-- Updatinng the region field for non-Indian records that contain numerical values, replacing them with a standard label "Non_Indian"
    
    
-- 18. Cleaning the Magnitude Column.
START TRANSACTION;
UPDATE EARTHQUAKES
SET MAGNITUDE = REGEXP_REPLACE(MAGNITUDE, '[\\[\\]a-zA-Z]', '');
COMMIT;
-- Cleaning the magnitude column by removing any non-numeric characters. To ensures that the magnitude field contains only numerical values.
    
    
-- 19. Optimizing Earthquake Table Structure by Dropping Redundant Column.
START TRANSACTION;
ALTER TABLE EARTHQUAKES
DROP COLUMN LOCATION;
COMMIT;
/*
The removal of Location column likely follows data restructuring where the information previously held in Location has been parsed into more specific columns.
*/



-- 20. Reviewing Table Schema Post-Modification.
DESCRIBE EARTHQUAKES;

-- After altering the table structure, this query provides a detailed description of the updated schema of the earthquakes table.


-- 21. Adjusting SQL Mode for Enhanced Query Flexibility
SET SQL_MODE=(SELECT REPLACE(@@SQL_MODE,'ONLY_FULL_GROUP_BY',''));



/* ---------------------------------------------------------------------- 
|																		|
|						IV. DATA VALIDATION								|
|																		|
----------------------------------------------------------------------- */

-- 1. Checking for Geographical Data.
SELECT COUNT(*) FROM EARTHQUAKES
WHERE CITY IS NULL OR REGION IS NULL OR COUNTRY IS NULL OR MAGNITUDE IS NULL OR DEPTH IS NULL;

-- 2. Finding Inconsistencies in Region Classification for Indian Records.
SELECT COUNT(*) FROM EARTHQUAKES
WHERE REGION = 'NON_INDIAN' AND COUNTRY = 'INDIA';

-- 3. Detecting Numerical Values in Direction Column.
SELECT COUNT(*) FROM EARTHQUAKES
WHERE DIRECTION REGEXP'^[0-9]';

-- 4. Counting Earthquakes by Region Excluding Non-Indian Entries.
SELECT DISTINCT REGION FROM EARTHQUAKES
WHERE REGION <> "NON_INDIAN"
GROUP BY REGION
ORDER BY REGION ASC;

-- 5. Verifying Null Values in Key Geographical Columns.
SELECT COUNT(*) FROM EARTHQUAKES WHERE City IS NULL OR Region IS NULL or Country IS NULL;

-- 6. Validate the range of values.
SELECT COUNT(*) FROM EARTHQUAKES WHERE Magnitude NOT BETWEEN 0 AND 10;

-- 7. Checking for Invalid Negative Depth Values.
SELECT COUNT(*) FROM EARTHQUAKES WHERE Depth < 0;


SELECT * FROM Earthquakes;

/* ---------------------------------------------------------------------- 
|																		|
|						V. DATA ANALYSIS								|
|																		|
----------------------------------------------------------------------- */

-- 1. What countries are there in Indian Sub-continent?
SELECT DISTINCT COUNTRY
FROM EARTHQUAKES
ORDER BY COUNTRY;

 -- 19 countries present in Indian territory.
 
  
-- 2. Get basic statistics for numerical columns like Depth and Magnitude.
SELECT 
    MIN(DEPTH) AS MIN_DEPTH, 
    MAX(DEPTH) AS MAX_DEPTH, 
    ROUND(AVG(DEPTH),2) AS AVG_DEPTH, 
    MIN(MAGNITUDE) AS MIN_MAGNITUDE, 
    MAX(MAGNITUDE) AS MAX_MAGNITUDE, 
    ROUND(AVG(MAGNITUDE),2) AS AVG_MAGNITUDE
FROM EARTHQUAKES;

/* Insights: 
-- The depth range from 0 to 700 km suggests a mix of shallow crustal and deeper subduction zone earthquakes.
-- An average earthquake depth of 43.1 km indicates a prevalence of intermediate-depth seismic events, hinting at complex tectonic interactions.
-- Magnitudes ranging from 1.0 to 9.3 cover a broad spectrum of seismic activity, from barely perceptible tremors to catastrophic events.
-- The average magnitude of 3.86 points to most minor earthquakes, typically felt but rarely causing substantial damage.
-- High-magnitude earthquakes emphasize the critical need for comprehensive earthquake preparedness and risk mitigation strategies.
*/


-- 3. Count the number of earthquakes by country.
SELECT DISTINCT COUNTRY,
	   COUNT(*) AS NO_OF_EARTHQUAKES
FROM EARTHQUAKES
GROUP BY COUNTRY
ORDER BY NO_OF_EARTHQUAKES DESC;

/* Insights: 
-- The depth range from 0 to 700 km suggests a mix of shallow crustal and deeper subduction zone earthquakes.
-- An average earthquake depth of 43.1 km indicates a prevalence of intermediate-depth seismic events, hinting at complex tectonic interactions.
-- Magnitudes ranging from 1.0 to 9.3 cover a broad spectrum of seismic activity, from barely perceptible tremors to catastrophic events.
-- The average magnitude of 3.86 points to most minor earthquakes, typically felt but rarely causing substantial damage.
-- High-magnitude earthquakes emphasise the critical need for comprehensive earthquake preparedness and risk mitigation strategies.
*/

-- Amoung 19 countries, India experiences higher frequencies of 17047, followed by Afghanistan as 6142.


-- 4. Find the number of earthquakes within different magnitude ranges.
SELECT 
    CASE 
        WHEN MAGNITUDE BETWEEN 0 AND 1.9 THEN '0-1.9'
        WHEN MAGNITUDE BETWEEN 2 AND 3.9 THEN '2-3.9'
        WHEN MAGNITUDE BETWEEN 4 AND 4.9 THEN '4-4.9'
        WHEN MAGNITUDE >= 5 THEN '5+'
        ELSE 'UNKNOWN'
    END AS MAGNITUDE_RANGE,
    COUNT(*) AS EARTHQUAKE_COUNT
FROM EARTHQUAKES
GROUP BY MAGNITUDE_RANGE
ORDER BY MAGNITUDE_RANGE;

/* Insights: 
-- The data indicates a typical trend where lower magnitude earthquakes occur more frequently than higher magnitude ones.
-- The high number of earthquakes in the 2-3.9 range suggests a lot of minor tectonic activity, 
	while the significant count of 4-4.9 magnitude earthquakes indicates a notable amount of moderate seismic activity.
-- The 5+ magnitude earthquakes, though fewer, represent a significant risk due to their potential for damage.
*/

-- 5. Analyze the number of earthquakes over time (e.g., yearly or monthly).
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- Run above query before running the query Below.
SELECT 
    YEAR(ORIGIN_TIME) AS "YEAR",
    SUM(MONTH(ORIGIN_TIME) = 1) AS JAN,
    SUM(MONTH(ORIGIN_TIME) = 2) AS FEB,
    SUM(MONTH(ORIGIN_TIME) = 3) AS MAR,
    SUM(MONTH(ORIGIN_TIME) = 4) AS APR,
    SUM(MONTH(ORIGIN_TIME) = 5) AS MAY,
    SUM(MONTH(ORIGIN_TIME) = 6) AS JUN,
    SUM(MONTH(ORIGIN_TIME) = 7) AS JUL,
    SUM(MONTH(ORIGIN_TIME) = 8) AS AUG,
    SUM(MONTH(ORIGIN_TIME) = 9) AS SEP,
    SUM(MONTH(ORIGIN_TIME) = 10) AS OCT,
    SUM(MONTH(ORIGIN_TIME) = 11) AS NOV,
    SUM(MONTH(ORIGIN_TIME) = 12) AS "DEC",
    COUNT(*) AS TOTAL,
    MAX(MAGNITUDE) AS HIGHEST_MAGNITUDE,
    ROUND(AVG(MAGNITUDE),2) AS AVG_MAGNITUDE
FROM EARTHQUAKES
GROUP BY YEAR
ORDER BY YEAR;

/* Insights: 
-- There's a significant fluctuation in the annual earthquake counts, with peaks at certain years, suggesting variable seismic activity or changes in detection/reporting over time.
-- The highest magnitude recorded is 9.3, indicating the presence of very powerful earthquakes in the region, albeit infrequently.
-- There are years with notably high average magnitudes, which could correspond to years with major seismic events affecting the annual average.
*/



-- 6. Investigate the distribution of earthquake depths for top 10.
SELECT 
    DEPTH, 
    COUNT(*) AS DEPTHCOUNT 
FROM EARTHQUAKES
GROUP BY DEPTH
ORDER BY DEPTHCOUNT DESC
LIMIT 10;

/* Insights: 
-- January and February of 2001 and May of 2015 had exceptionally high counts, which could be worth investigating for potential seasonal 
    influences or unique geophysical events that occurred during those periods.
-- The highest magnitude of 9.3 was recorded in 2004. Such an extreme event is rare and is typically associated with significant tectonic events
    like megathrust earthquakes, which can cause widespread damage and trigger tsunamis.
-- The average magnitude remains relatively steady around the mid-3.0’s throughout the years, indicative of a consistent release of
    seismic energy through numerous more minor earthquakes rather than fewer larger ones.
*/


-- 7. Analyze earthquakes by region, specifically for India.
SELECT 
    REGION, 
    COUNT(*) AS EARTHQUAKES_IN_REGION
FROM EARTHQUAKES
WHERE COUNTRY = 'INDIA'
GROUP BY REGION
ORDER BY EARTHQUAKES_IN_REGION DESC;


/* Insights: 
-- Andaman and Nicobar Islands, Gujarat, Jammu and Kashmir, and Uttarakhand show notably high earthquake counts, 
    indicating significant seismic risk or active tectonic plates in these regions.
-- Regions with high seismicity, like the Andaman and Nicobar Islands and the Himalayan belt (including Jammu and Kashmir, Uttarakhand, and Himachal Pradesh), 
    are known for their tectonic complexity, which could explain the higher frequency of earthquakes.
-- Regions like Goa, Jharkhand, and Lakshadweep Island have significantly lower earthquake occurrences,
    which might correlate with their geologic settings being less prone to seismic activities. 
*/

-- 8. Change in Average Magnitude of Earthquakes Over Decades
SELECT 
  CONCAT(LEFT(YEAR(ORIGIN_TIME), 3), '0S') AS DECADE, 
  ROUND(AVG(MAGNITUDE),2) AS AVG_MAGNITUDE
FROM EARTHQUAKES
GROUP BY DECADE;


/* Insights: 
-- Earthquake magnitudes remained relatively consistent over decades,
	with a slight peak in the 2010s; early 2020s data suggests a minor decrease in average magnitude.
*/ 

-- 9. Identify the largest earthquakes recorded.
SELECT 
    ORIGIN_TIME,
    LATITUDE,
    LONGITUDE,
    DEPTH,
    MAGNITUDE,
    CITY,
    REGION,
    COUNTRY
FROM
    EARTHQUAKES
ORDER BY MAGNITUDE DESC
LIMIT 10;

/* Insights: 
-- The Andaman and Nicobar Islands are recurrently listed, indicating a highly seismic region, likely due to subduction zone activities.
-- The earthquakes listed are significantly strong, with magnitudes ranging from 7.4 to 9.3, highlighting the potential for significant seismic events in these regions.
-- The list includes events from different countries, suggesting seismic risks are not confined to one region but 
    are spread across the Indian subcontinent and surrounding areas.
*/


-- 10. Explore the relationship between depth and magnitude.
SELECT 
    DEPTH, ROUND(AVG(MAGNITUDE), 2) AS AVG_MAGNITUDE
FROM
    EARTHQUAKES
GROUP BY DEPTH
HAVING COUNT(*) > 10
ORDER BY AVG_MAGNITUDE DESC
LIMIT 10;

/* Insights: 
-- Depths like 123 km and 199 km show higher average magnitudes, which may suggest that deeper earthquakes tend to be stronger.
-- Similar average magnitudes across various depths (like 116 km and 158 km with an average magnitude of 4.67) 
    suggest that seismic potential can vary significantly at specific depth ranges.
*/



-- 11. Average Earthquake Magnitude and Frequency by Hour of Day in India.
SELECT 
    COUNTRY,
    COUNT(*) AS TOTAL_EARTHQUAKES,
    ROUND(AVG(MAGNITUDE),2) AS AVG_MAGNITUDE,
    MAX(DEPTH) AS MAX_DEPTH
FROM EARTHQUAKES
WHERE MAGNITUDE > 4.5
GROUP BY COUNTRY
ORDER BY TOTAL_EARTHQUAKES DESC, AVG_MAGNITUDE DESC;

/* Insights: 
-- India tops the list in frequency (3460 earthquakes) and significant depth (max depth 462 km), reflecting its active tectonics and high seismic risk.
-- The maximum depths vary widely, with Afghanistan reporting earthquakes as deep as 476 km, which is unusually deep and could suggest subduction-related activities.
-- Countries like Nepal and Bhutan have higher average magnitudes (>5) despite fewer events, possibly indicating more powerful seismic events in the Himalayan region.
*/


-- 12. Analysis of Major Earthquake Intervals by City and Country.
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SELECT 
    E1.ORIGIN_TIME AS FIRST_QUAKE_TIME, 
    MIN(E2.ORIGIN_TIME) AS NEXT_MAJOR_QUAKE_TIME, E1.MAGNITUDE AS FIRST_QUAKE, E2.MAGNITUDE AS NEXT_MAJOR_QUAKE, E1.CITY, E1.COUNTRY,
    TIMESTAMPDIFF(DAY, E1.ORIGIN_TIME, MIN(E2.ORIGIN_TIME)) AS DAYS_BETWEEN_QUAKES
FROM EARTHQUAKES E1
INNER JOIN EARTHQUAKES E2 ON E1.ORIGIN_TIME < E2.ORIGIN_TIME AND E2.MAGNITUDE >= 6
WHERE E1.MAGNITUDE >= 6
GROUP BY E1.ORIGIN_TIME
ORDER BY DAYS_BETWEEN_QUAKES;


/* Insights: 
-- The zero days between quakes indicate that significant earthquakes can occur rapidly,
     highlighting seismic activity's unpredictability and dynamic nature.
-- Campbell Bay is a hotspot for significant earthquakes, with aftershock sequences occurring on the same day, 
     reflecting complex seismic behaviour and persistent risk.
*/



-- 13. Yearly Increase in Earthquake Counts
SELECT 
  YEAR(ORIGIN_TIME) AS YEAR, 
  COUNT(*) AS EARTHQUAKE_COUNT,
  COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(ORIGIN_TIME)) AS YEARLY_INCREASE
FROM EARTHQUAKES
GROUP BY YEAR;


/* Insights: 
--  The earthquake counts fluctuate significantly from year to year. Notably, 2001 and 2005 illustrate significant increases in earthquakes.
--  After a peak year, there is often a sharp decrease, as seen in 2002 and 2006, which could indicate aftershock sequences in previous years inflating counts.
-- A notable increase in 2020 could suggest either a rise in seismic activity or changes in detection sensitivity, possibly combined with more comprehensive reporting.
*/



-- 14. Rank Earthquakes by Magnitude Within Each Country
WITH EARTHQUAKE_RANK AS (
  SELECT 
    COUNTRY, 
    ORIGIN_TIME, 
    MAGNITUDE,
    DENSE_RANK() OVER (PARTITION BY COUNTRY ORDER BY MAGNITUDE DESC) AS MAGNITUDE_RANK
  FROM EARTHQUAKES
)
SELECT 
  COUNTRY, 
  MAX(CASE WHEN MAGNITUDE_RANK = 1 THEN MAGNITUDE END) AS HIGHEST_MAGNITUDE,
  MAX(CASE WHEN MAGNITUDE_RANK = 2 THEN MAGNITUDE END) AS SECOND_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN MAGNITUDE_RANK = 3 THEN MAGNITUDE END) AS THIRD_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN MAGNITUDE_RANK = 4 THEN MAGNITUDE END) AS FOURTH_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN MAGNITUDE_RANK = 5 THEN MAGNITUDE END) AS FIFTH_HIGHEST_MAGNITUDE
FROM EARTHQUAKE_RANK
GROUP BY COUNTRY;

/* Insights: 
-- India, Afghanistan, and Malaysia show notably high magnitudes, which may correspond to significant fault lines or subduction zones in these areas.
-- For most countries, there is a gradual decrease in magnitude from the highest to the fifth highest, which is typical as more significant earthquakes are less frequent.
-- The countries with the highest magnitudes represent areas with greater seismic risk, which can affect disaster preparedness and building codes.
*/


-- 15. Average Magnitude of Top 5 Largest Earthquakes Each Year
WITH RANKED_EARTHQUAKES AS (SELECT 
    YEAR(ORIGIN_TIME) AS YEAR, 
    MAGNITUDE,
    RANK() OVER (PARTITION BY YEAR(ORIGIN_TIME) ORDER BY MAGNITUDE DESC) AS "RNK"
  FROM EARTHQUAKES)
SELECT 
  YEAR, 
  ROUND(AVG(MAGNITUDE),2) AS AVG_TOP_5_MAGNITUDE
FROM RANKED_EARTHQUAKES
WHERE RNK <= 5
GROUP BY YEAR
ORDER BY AVG_TOP_5_MAGNITUDE DESC;

/* Insights: 
-- 2005, 2015, and 2004 stand out with the highest average top 5 magnitudes, suggesting periods of significant tectonic stress release or major seismic events.
-- Years 2005, 2015, and 2004 had the highest average magnitudes, with a downward trend into 2022, suggesting periods of intense seismic activity and persistent risk.
*/



-- 16. Moving Average of Earthquake Magnitudes
SELECT 
  ORIGIN_TIME, 
  MAGNITUDE,
  ROUND(AVG(MAGNITUDE) OVER (ORDER BY ORIGIN_TIME ROWS BETWEEN 10 PRECEDING AND CURRENT ROW),2) AS MOVING_AVG_MAGNITUDE
FROM EARTHQUAKES;

/* Insights: 
-- Moving averages smooth magnitude data, revealing underlying seismic trends, indicating periods of increased or decreased activity, 
    and aiding in understanding and forecasting seismic patterns.​
*/



-- 17. Count of Earthquakes Before and After a Specific Date
SELECT 
  (SELECT COUNT(*) FROM EARTHQUAKES WHERE ORIGIN_TIME < '2000-01-01') AS BEFORE_2000,
  (SELECT COUNT(*) FROM EARTHQUAKES WHERE ORIGIN_TIME >= '2000-01-01') AS AFTER_2000;


/* Insights: 
-- The drastic increase in reported earthquakes after 2000 may indicate improvements in seismic detection technology and reporting practices.
-- Potential environmental and geophysical changes may have contributed to the increase in seismic activity.
*/


-- 18. Most Frequent Depth Range of Earthquakes
SELECT DEPTH_RANGE, COUNT(*) AS FREQUENCY
FROM (
  SELECT 
    CASE
      WHEN DEPTH < 10 THEN '0-10 KM'
      WHEN DEPTH BETWEEN 10 AND 50 THEN '10-50 KM'
      ELSE 'OVER 50 KM'
    END AS DEPTH_RANGE
  FROM EARTHQUAKES
) AS DEPTHCATEGORIES
GROUP BY DEPTH_RANGE
ORDER BY FREQUENCY DESC
LIMIT 1;


/* Insights: 
-- The 10-50 km depth range is typically associated with crustal earthquakes, which occur within the Earth's crust, rather than deeper subduction zone earthquakes.
-- Earthquakes at this depth can significantly impact the surface, often being felt more strongly and potentially causing more damage than deeper earthquakes.
*/



-- 19. Countries with Increasing Earthquake Magnitudes
WITH AVGMAGNITUDE AS (
  SELECT 
    COUNTRY,
    YEAR(ORIGIN_TIME) AS YR,
    AVG(MAGNITUDE) AS AVG_MAGNITUDE
  FROM EARTHQUAKES
  GROUP BY COUNTRY, YEAR(ORIGIN_TIME)
), MAGNITUDECHANGE AS (
  SELECT 
    COUNTRY, 
    YR AS YEAR, 
    AVG_MAGNITUDE,
    (AVG_MAGNITUDE - LAG(AVG_MAGNITUDE) OVER (PARTITION BY COUNTRY ORDER BY YR)) AS INCREASE
  FROM AVGMAGNITUDE
)
SELECT *
FROM MAGNITUDECHANGE
WHERE INCREASE > 0;


/* Insights: 
-- The increases in average magnitudes across different years and countries indicate variability in seismicity, 
	which a range of geophysical factors could influence.
-- Not all years show an increase; this suggests that the geological processes leading to earthquakes can vary significantly yearly.
-- For some countries, there are significant jumps in average magnitude from one year to the next, which could point to 
	major seismic events or changes in seismic patterns.
*/



-- 20. Percentage of Earthquakes in Each Magnitude Category by Country
SELECT 
  COUNTRY,
  COUNT(CASE WHEN MAGNITUDE_CATEGORY = 'LOW' THEN 1 END) AS LOW_COUNT,
  100.0 * COUNT(CASE WHEN MAGNITUDE_CATEGORY = 'LOW' THEN 1 END) / SUM(COUNT(*)) OVER (PARTITION BY COUNTRY) AS LOW_PERCENTAGE,
  COUNT(CASE WHEN MAGNITUDE_CATEGORY = 'MODERATE' THEN 1 END) AS MODERATE_COUNT,
  100.0 * COUNT(CASE WHEN MAGNITUDE_CATEGORY = 'MODERATE' THEN 1 END) / SUM(COUNT(*)) OVER (PARTITION BY COUNTRY) AS MODERATE_PERCENTAGE,
  COUNT(CASE WHEN MAGNITUDE_CATEGORY = 'HIGH' THEN 1 END) AS HIGH_COUNT,
  100.0 * COUNT(CASE WHEN MAGNITUDE_CATEGORY = 'HIGH' THEN 1 END) / SUM(COUNT(*)) OVER (PARTITION BY COUNTRY) AS HIGH_PERCENTAGE
FROM (
  SELECT 
    COUNTRY, 
    CASE
      WHEN MAGNITUDE < 3 THEN 'LOW'
      WHEN MAGNITUDE BETWEEN 3 AND 6 THEN 'MODERATE'
      ELSE 'HIGH'
    END AS MAGNITUDE_CATEGORY
  FROM EARTHQUAKES
) AS CATEGORIZED
GROUP BY COUNTRY;

/* Insights:
--  Across all countries, the overwhelming majority of earthquakes fall into the 'moderate' category, which typically includes magnitudes between 3 and 6.
--  There's a deficient percentage of 'high' magnitude earthquakes, which is expected given that higher magnitude earthquakes are less frequent.
--  India has a relatively higher percentage of 'low' magnitude earthquakes, indicating a broad range of seismic activity.
*/



-- 21. Difference in Average Magnitude Between Consecutive Earthquakes
 SELECT 
  ORIGIN_TIME, 
  MAGNITUDE,
  ROUND(MAGNITUDE - LAG(MAGNITUDE) OVER (ORDER BY ORIGIN_TIME),2) AS MAGNITUDE_DIFFERENCE
FROM EARTHQUAKES;

/* Insights: 
-- There's a noticeable increase in earthquake counts post-2000, suggesting an increase in seismic activity 
	or an improvement in detection methods and reporting.
-- Most earthquakes occur within a depth range of 10-50 km, typically associated with earthquakes within
	tectonic plates (intraplate earthquakes) as opposed to deeper subduction zone events.
-- Certain countries show a year-over-year increase in average earthquake magnitudes, which could point towards a build-up of tectonic stress in those regions.
-- Post-2000, there's a significant rise in earthquake detection, with fluctuations in average yearly magnitudes, most earthquakes occurring at shallow depths, 
	and some regions showing increasing trends in magnitudes, indicating varying seismic stress accumulation globally.
*/



-- 22. Top 3 Largest Earthquakes in Each Region 
WITH RANKED_MAGNITUDES AS (
  SELECT 
    REGION, 
    ORIGIN_TIME, 
    MAGNITUDE,
    DENSE_RANK() OVER (PARTITION BY REGION ORDER BY MAGNITUDE DESC) AS RNK
  FROM EARTHQUAKES
  WHERE COUNTRY = 'INDIA'
)
SELECT 
  REGION,
  MAX(CASE WHEN RNK = 1 THEN MAGNITUDE END) AS HIGHEST_MAGNITUDE,
  MAX(CASE WHEN RNK = 1 THEN ORIGIN_TIME END) AS TIME_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN RNK = 2 THEN MAGNITUDE END) AS SECOND_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN RNK = 2 THEN ORIGIN_TIME END) AS TIME_SECOND_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN RNK = 3 THEN MAGNITUDE END) AS THIRD_HIGHEST_MAGNITUDE,
  MAX(CASE WHEN RNK = 3 THEN ORIGIN_TIME END) AS TIME_THIRD_HIGHEST_MAGNITUDE
FROM RANKED_MAGNITUDES
WHERE RNK <= 3
GROUP BY REGION;


/* Insights: 
-- The Andaman and Nicobar Islands have experienced the strongest earthquakes in the country, 
	magnitudes significantly higher than those on the mainland.
-- Regions like Andhra Pradesh, Goa, and Chandigarh have relatively lower magnitudes of earthquakes,
	which may suggest lower seismic risk or more stable tectonic conditions.
-- Andaman and Nicobar Islands lead with the highest earthquake magnitudes in India; northeastern states follow,
	while central regions experience moderate seismic activity, highlighting varied tectonic dynamics across the country 
*/



-- 23. Earthquakes with Magnitude Greater Than the Annual Average
SELECT 
  ORIGIN_TIME, 
  MAGNITUDE
FROM EARTHQUAKES
WHERE MAGNITUDE > (
  SELECT AVG(MAGNITUDE) FROM EARTHQUAKES WHERE YEAR(ORIGIN_TIME) = YEAR(EARTHQUAKES.ORIGIN_TIME)
);

/* Insights: 
-- Earthquakes with magnitudes above the annual average can indicate more significant tectonic activity or stress accumulation in those years.
-- A higher number of such earthquakes could suggest an increasing trend in seismic activity or the potential for more significant events in that region.
-- The geographical distribution of these above-average magnitude earthquakes points to specific fault lines or tectonic boundaries 
	that are more active or pose a higher risk.
--  Indicates a significant seismic activity exceeding annual average magnitudes, potentially signalling increased tectonic stress
	and necessitating enhanced earthquake preparedness strategies.
*/



-- 24. Countries with the Most Severe Earthquakes Each Year
SELECT 
  YEAR, 
  COUNTRY, 
  MAX_MAGNITUDE
FROM (
  SELECT 
    YEAR(ORIGIN_TIME) AS YEAR, 
    COUNTRY, 
    MAX(MAGNITUDE) AS MAX_MAGNITUDE,
    RANK() OVER (PARTITION BY YEAR(ORIGIN_TIME) ORDER BY MAX(MAGNITUDE) DESC) AS RNK
  FROM EARTHQUAKES
  GROUP BY YEAR, COUNTRY
) AS RANKED
WHERE RNK = 1;

/* Insights: 
-- India and Afghanistan appear frequently in the dataset, indicating they are regions with recurrent high-magnitude earthquakes, 
	likely due to the tectonic plate boundaries, they are on
-- The highest magnitude earthquake recorded in this data set is 9.3 in India for the year 2004, 
	which is significantly higher than other entries, pointing to a significant seismic event.
-- Nepal's appearance in 2015 with a magnitude of 7.9 is consistent with the devastating Gorkha earthquake that
	occurred in April 2015, reflecting its impact on the historical records.
*/

-- 25. Proportion of Earthquakes by Depth Range for Each Country
WITH DEPTH_CATEGORIZED AS ( SELECT 
    COUNTRY, 
    CASE
      WHEN DEPTH < 10 THEN '0-10 KM'
      WHEN DEPTH BETWEEN 10 AND 50 THEN '10-50 KM'
      ELSE 'OVER 50 KM'
    END AS DEPTH_RANGE
  FROM EARTHQUAKES)
SELECT 
  COUNTRY,
  COUNT(CASE WHEN DEPTH_RANGE = '0-10 KM' THEN 1 END) AS COUNT_0_10_KM,
  100.0 * COUNT(CASE WHEN DEPTH_RANGE = '0-10 KM' THEN 1 END) / SUM(COUNT(*)) OVER (PARTITION BY COUNTRY) AS PERCENTAGE_0_10_KM,
  COUNT(CASE WHEN DEPTH_RANGE = '10-50 KM' THEN 1 END) AS COUNT_10_50_KM,
  100.0 * COUNT(CASE WHEN DEPTH_RANGE = '10-50 KM' THEN 1 END) / SUM(COUNT(*)) OVER (PARTITION BY COUNTRY) AS PERCENTAGE_10_50_KM,
  COUNT(CASE WHEN DEPTH_RANGE = 'OVER 50 KM' THEN 1 END) AS COUNT_OVER_50_KM,
  100.0 * COUNT(CASE WHEN DEPTH_RANGE = 'OVER 50 KM' THEN 1 END) / SUM(COUNT(*)) OVER (PARTITION BY COUNTRY) AS PERCENTAGE_OVER_50_KM
FROM DEPTH_CATEGORIZED
GROUP BY COUNTRY;

/* Insights: 
-- Most earthquakes in Afghanistan, with nearly 60%, occur at depths over 50 km, suggesting tectonic activities at greater depths in this region.
-- Bangladesh, Bhutan, and India have significant earthquakes occurring within the 10-50 km depth range,
	indicating that most seismic activity in these areas does not extend to intense levels.
-- India has a substantial number of shallow earthquakes (0-10 km depth), comprising over 16% of its total,
	which could imply a higher potential for surface damage due to the proximity of these quakes to the surface.
-- Countries like the Maldives and Oman, with nearly 90% of earthquakes at depths of 10-50 km, 
	suggest a consistent depth pattern for seismic events in these regions.
*/


-- 26. Average Time Interval Between Consecutive Earthquakes in Each Country 
WITH INTERVALS AS (
SELECT 
    COUNTRY, 
    DATEDIFF(ORIGIN_TIME, LAG(ORIGIN_TIME) OVER (PARTITION BY COUNTRY ORDER BY ORIGIN_TIME)) AS DAYS_BETWEEN
  FROM EARTHQUAKES
  )

SELECT 
  COUNTRY, 
  CEIL(AVG(DAYS_BETWEEN)) AS AVG_DAYS_BETWEEN
FROM INTERVALS
WHERE DAYS_BETWEEN IS NOT NULL
GROUP BY COUNTRY
ORDER BY AVG_DAYS_BETWEEN ASC;

/* Insights: 
-- India and Afghanistan experience persistent seismic activity, with average intervals of 1 and 2 days, respectively. 
-- This indicates a high level of tectonic movement and stress accumulation in these regions.
-- Countries like Pakistan, Nepal, and Malaysia also show relatively short average intervals between earthquakes, suggesting regular seismic activity.
-- Countries with the most extended intervals, such as Bangladesh, Sri Lanka, and Seychelles, could suggest that they are either less prone 
	to earthquakes or that only significant seismic events are recorded.
*/



-- 27. Earthquakes Occurring on the Same Day Across Different Years
SELECT 
  DAY,
  SUM(CASE WHEN MONTH = 1 THEN OCCURRENCES ELSE 0 END) AS JAN,
  SUM(CASE WHEN MONTH = 2 THEN OCCURRENCES ELSE 0 END) AS FEB,
  SUM(CASE WHEN MONTH = 3 THEN OCCURRENCES ELSE 0 END) AS MAR,
  SUM(CASE WHEN MONTH = 4 THEN OCCURRENCES ELSE 0 END) AS APR,
  SUM(CASE WHEN MONTH = 5 THEN OCCURRENCES ELSE 0 END) AS MAY,
  SUM(CASE WHEN MONTH = 6 THEN OCCURRENCES ELSE 0 END) AS JUN,
  SUM(CASE WHEN MONTH = 7 THEN OCCURRENCES ELSE 0 END) AS JUL,
  SUM(CASE WHEN MONTH = 8 THEN OCCURRENCES ELSE 0 END) AS AUG,
  SUM(CASE WHEN MONTH = 9 THEN OCCURRENCES ELSE 0 END) AS SEP,
  SUM(CASE WHEN MONTH = 10 THEN OCCURRENCES ELSE 0 END) AS OCT,
  SUM(CASE WHEN MONTH = 11 THEN OCCURRENCES ELSE 0 END) AS NOV,
  SUM(CASE WHEN MONTH = 12 THEN OCCURRENCES ELSE 0 END) AS "DEC"
FROM (
  SELECT 
    DAY(ORIGIN_TIME) AS DAY, 
    MONTH(ORIGIN_TIME) AS MONTH, 
    COUNT(*) AS OCCURRENCES
  FROM EARTHQUAKES
  GROUP BY DAY(ORIGIN_TIME), MONTH(ORIGIN_TIME)
  HAVING COUNT(*) > 1
) AS DAILYOCCURRENCES
GROUP BY DAY
ORDER BY DAY;

/* Insights: 
-- It suggests a non-uniform distribution of earthquake occurrences across the calendar year with varying frequencies on specific days of each month.
-- Some days show an exceptionally high number of earthquakes, such as the 9th of October and the 10th of November, 
	suggesting a possible pattern or seasonal geological activity that could merit further investigation.
-- Despite being the shortest month, February has days with relatively high earthquake occurrences,
	indicating that earthquake activity is not correlated with the length of the month.
-- The first day of the month across several months appears to have a consistently high number of earthquakes,
	which could be an artefact of reporting or a genuine geological pattern.
*/


-- 28. Indian city-wise Distribution of Earthquakes Above a 6.0 Magnitude
SELECT 
  CITY, REGION,
  COUNT(*) AS HIGH_MAGNITUDE_QUAKE_COUNT
FROM EARTHQUAKES
WHERE MAGNITUDE > 6.0 AND COUNTRY = "INDIA"
GROUP BY CITY
ORDER BY HIGH_MAGNITUDE_QUAKE_COUNT DESC;

/* Insights: 
-- Campbell Bay in the Andaman and Nicobar Islands region has experienced the highest number of significant earthquakes,
	suggesting it's a highly seismically active area.
-- The Andaman and Nicobar Islands show more high-magnitude earthquakes than mainland regions, 
	which is consistent with the tectonic settings of island regions.
-- The occurrence of high-magnitude earthquakes in regions like Arunachal Pradesh and Uttarakhand aligns with the known seismic zones of the Himalayan belt, 
	indicating tectonic stress accumulation and release.
-- The presence of high-magnitude earthquakes in Gujarat (Dwarka and Rajkot) points to the seismic risks in western India, 
	historically known for devastating earthquakes.
-- The distribution of cities with single occurrences across different regions suggests that high-magnitude seismic activity in India
	is widespread and not confined to a single geographic fault system.
*/


-- 29. Countries with Increasing Average Earthquake Depth Over Years
WITH AVERAGEDEPTHS AS (
  SELECT 
    COUNTRY, 
    YEAR(ORIGIN_TIME) AS YEAR, 
    AVG(DEPTH) AS AVG_DEPTH
  FROM EARTHQUAKES
  GROUP BY COUNTRY, YEAR(ORIGIN_TIME)
), 
DEPTHCHANGE AS (SELECT 
    COUNTRY, 
    YEAR, 
    AVG_DEPTH,
    AVG_DEPTH - LAG(AVG_DEPTH) OVER (PARTITION BY COUNTRY ORDER BY YEAR) AS DEPTH_INCREASE
  FROM AVERAGEDEPTHS)
SELECT *
FROM DEPTHCHANGE
WHERE DEPTH_INCREASE > 0;

/* Insights: 
-- Afghanistan, Malaysia, and Nepal show significant year-to-year increases in average earthquake depth, which could indicate changes in seismic activity
	patterns or detection capabilities.
-- The substantial depth increases in Afghanistan during the early 2000s and again in 2014 suggest a possible shift in tectonic activity.
-- Malaysia's average earthquake depth showed a marked increase in 2020, which could warrant further geological investigation to understand the underlying factors.
-- Periodic increases in the average depth in countries like Pakistan and India may be linked to the complex tectonics of the region, 
	influenced by the collision of the Indian and Eurasian plates.
-- The data for Turkmenistan and Uzbekistan reflect significant depth increases at certain intervals, possibly connected to the regional geodynamics of Central Asia.
*/


-- 30. Cities Most Frequently Affected by High Magnitude Earthquakes
SELECT 
  CITY, REGION, COUNTRY, 
  COUNT(*) AS HIGH_MAGNITUDE_QUAKE_COUNT
FROM EARTHQUAKES
WHERE MAGNITUDE > 6.5
GROUP BY CITY
ORDER BY HIGH_MAGNITUDE_QUAKE_COUNT DESC
LIMIT 5;

/* Insights: 
-- Campbell Bay in India's Andaman and Nicobar Islands is the most earthquake-prone city listed, with 11 high-magnitude earthquakes.
-- Non-Indian cities like Fayzabad in Afghanistan and Kathmandu in Nepal indicate a wider regional seismic activity in South Asia.
-- The varied geographical distribution of these cities suggests tectonic complexities affecting the Indian subcontinent and surrounding areas.
*/


-- 31. Correlation Between Magnitude and Depth
WITH AVERAGE_VALUES AS (
  SELECT 
    MAGNITUDE, 
    DEPTH, 
    AVG(MAGNITUDE) OVER () AS AVG_MAGNITUDE, 
    AVG(DEPTH) OVER () AS AVG_DEPTH 
  FROM EARTHQUAKES
)
SELECT 
  ROUND(((SUM((MAGNITUDE - AVG_MAGNITUDE) * (DEPTH - AVG_DEPTH)) / COUNT(*)) / 
  (STDDEV_SAMP(MAGNITUDE) * STDDEV_SAMP(DEPTH))),3) AS MAGNITUDE_DEPTH_CORRELATION
FROM AVERAGE_VALUES;

/* Insights: 
-- As the magnitude of earthquakes increases, there is a tendency for the depth to grow as well, but the relationship is relatively weak.
-- The weak correlation suggests that depth may influence magnitude, but it is not a strong predictor.
*/



-- 32. Average Earthquake Magnitude and Frequency by Hour of Day in India Territory
SELECT 
    HOUR(ORIGIN_TIME) AS HOUR_OF_DAY,
    ROUND(AVG(MAGNITUDE),2) AS AVERAGE_MAGNITUDE,
    COUNT(*) AS NUMBER_OF_EARTHQUAKES
FROM EARTHQUAKES
GROUP BY HOUR_OF_DAY

HAVING AVERAGE_MAGNITUDE >= 3
ORDER BY HOUR_OF_DAY;

/* Insights: 
-- Earthquakes don't significantly vary in average magnitude throughout the day, hovering around 3.8 to 3.9.
-- Slightly higher average magnitudes are observed during early morning, precisely at 7, 8, and 9 AM.
-- There's a consistent occurrence of earthquakes throughout the day, with no specific hour showing extreme variation in frequency.
*/


-- 33. Analyze the number of earthquakes over time of India (e.g., yearly or monthly).
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT 
    YEAR(ORIGIN_TIME) AS "YEAR",
    SUM(MONTH(ORIGIN_TIME) = 1) AS JAN,
    SUM(MONTH(ORIGIN_TIME) = 2) AS FEB,
    SUM(MONTH(ORIGIN_TIME) = 3) AS MAR,
    SUM(MONTH(ORIGIN_TIME) = 4) AS APR,
    SUM(MONTH(ORIGIN_TIME) = 5) AS MAY,
    SUM(MONTH(ORIGIN_TIME) = 6) AS JUN,
    SUM(MONTH(ORIGIN_TIME) = 7) AS JUL,
    SUM(MONTH(ORIGIN_TIME) = 8) AS AUG,
    SUM(MONTH(ORIGIN_TIME) = 9) AS SEP,
    SUM(MONTH(ORIGIN_TIME) = 10) AS OCT,
    SUM(MONTH(ORIGIN_TIME) = 11) AS NOV,
    SUM(MONTH(ORIGIN_TIME) = 12) AS "DEC",
    COUNT(*) AS TOTAL,
    MAX(MAGNITUDE) AS HIGHEST_MAGNITUDE,
    ROUND(AVG(MAGNITUDE),2) AS AVG_MAGNITUDE
FROM EARTHQUAKES
WHERE COUNTRY = 'India'
GROUP BY YEAR
ORDER BY YEAR;

/* Insights: 
-- There's significant annual variability in earthquake counts and magnitudes, with some years experiencing high activity and others much lower.
-- Years like 2001 and 2005 stand out with many earthquakes (1566 and 1555 respectively) and higher magnitudes (7.7 and 7.3 highest magnitude respectively).
-- Despite fluctuations, there doesn't appear to be a clear increasing or decreasing long-term trend in the total number of earthquakes per year.
-- The average magnitude of earthquakes yearly mainly fluctuates between 3.2 and 4.2, indicating a predominance of light to moderate earthquakes.
*/


-- 34. Earthquakes Occurring on the Same Day Across Different Years of India
WITH DAILY_OCCURRENCES AS 
(
  SELECT 
    DAY(ORIGIN_TIME) AS DAY, 
    MONTH(ORIGIN_TIME) AS MONTH, 
    COUNT(*) AS OCCURRENCES
  FROM EARTHQUAKES
  WHERE COUNTRY = 'India'
  GROUP BY DAY(ORIGIN_TIME), MONTH(ORIGIN_TIME)
  HAVING COUNT(*) > 1
) 
SELECT 
  DAY,
  SUM(CASE WHEN MONTH = 1 THEN OCCURRENCES ELSE 0 END) AS JANUARY,
  SUM(CASE WHEN MONTH = 2 THEN OCCURRENCES ELSE 0 END) AS FEBRUARY,
  SUM(CASE WHEN MONTH = 3 THEN OCCURRENCES ELSE 0 END) AS MARCH,
  SUM(CASE WHEN MONTH = 4 THEN OCCURRENCES ELSE 0 END) AS APRIL,
  SUM(CASE WHEN MONTH = 5 THEN OCCURRENCES ELSE 0 END) AS MAY,
  SUM(CASE WHEN MONTH = 6 THEN OCCURRENCES ELSE 0 END) AS JUNE,
  SUM(CASE WHEN MONTH = 7 THEN OCCURRENCES ELSE 0 END) AS JULY,
  SUM(CASE WHEN MONTH = 8 THEN OCCURRENCES ELSE 0 END) AS AUGUST,
  SUM(CASE WHEN MONTH = 9 THEN OCCURRENCES ELSE 0 END) AS SEPTEMBER,
  SUM(CASE WHEN MONTH = 10 THEN OCCURRENCES ELSE 0 END) AS OCTOBER,
  SUM(CASE WHEN MONTH = 11 THEN OCCURRENCES ELSE 0 END) AS NOVEMBER,
  SUM(CASE WHEN MONTH = 12 THEN OCCURRENCES ELSE 0 END) AS DECEMBER
FROM DAILY_OCCURRENCES
GROUP BY DAY
ORDER BY DAY;

/* Insights: 
-- Earthquake occurrences do not seem to follow a distinct pattern across the days of the month, suggesting randomness in seismic activity.
-- Certain days show notably higher numbers, like the 27th, 28th, and 29th across various months, but without a clear temporal trend or seasonality.
-- The data shows variability in earthquake occurrences from month to month and is likely influenced by complex geological factors rather than simple cyclical patterns.
-- Days with extremely high counts, such as 129 on the 27th of January or 126 on the 28th, could be due to specific large events or clusters of seismic activity.
*/


-- 35. Average Earthquake Magnitude and Frequency by Hour of Day in India
SELECT 
    HOUR(ORIGIN_TIME) AS HOUR_OF_DAY,
    ROUND(AVG(MAGNITUDE),2) AS AVERAGE_MAGNITUDE,
    COUNT(*) AS NUMBER_OF_EARTHQUAKES
FROM EARTHQUAKES
WHERE COUNTRY = 'India'
GROUP BY HOUR_OF_DAY
ORDER BY HOUR_OF_DAY;

/* Insights: 
-- The average magnitude of earthquakes remains relatively consistent across different hours of the day, with slight fluctuations but no significant peaks or troughs.
-- The early morning hours (1-3 AM) do not significantly decrease earthquakes, indicating that seismic activity is not tied to daily human activities.
-- Late evening tonight (7 PM-11 PM) shows a slight increase in average magnitude, but this is not a definitive trend and requires more data for confirmation.
-- The highest frequency of earthquakes occurs at 8 PM, with a notable magnitude as well; this could be due to specific seismic patterns or mere coincidence.
-- Hours with the highest magnitudes (3.77 to 3.8) are 7, 8, 9, and 19, which could be random or may indicate geophysical processes that are more active during these times.
*/


/* --------------------------------------------------------------------------------------------------------------------------------*/
