/* ------------------------------------------------------------------------------------------------------------------------------ 
|																																|
|													STUDENT PERFORMANCE ANALYSIS   											    |
|																																|
-------------------------------------------------------------------------------------------------------------------------------*/

USE STUDENTS;

SHOW TABLES;


DESCRIBE STUDENTS;



SELECT 
    COLUMN_NAME 
FROM 
    INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_NAME = 'STUDENTS';
    
/*
------------------------------------------------------
ATTRIBUTES OF STUDENTS DATASETS:
------------------------------------------------------
SCHOOL - STUDENT'S SCHOOL (BINARY: "GP" - GABRIEL PEREIRA OR "MS" - MOUSINHO DA SILVEIRA)
SEX - STUDENT'S SEX (BINARY: "F" - FEMALE OR "M" - MALE)
AGE - STUDENT'S AGE (NUMERIC: FROM 15 TO 22)
ADDRESS_TYPE - STUDENT'S HOME ADDRESS TYPE (BINARY: "URBAN" OR "RURAL")
FAMILY_SIZE - FAMILY SIZE (BINARY: "LESS OR EQUAL TO 3" OR "GREATER THAN 3")
PARENT_STATUS - PARENT'S COHABITATION STATUS (BINARY: "LIVING TOGETHER" OR "APART")
MOTHER_EDUCATION - MOTHER'S EDUCATION (ORDINAL: "NONE", "PRIMARY EDUCATION (4TH GRADE)", "5TH TO 9TH GRADE", "SECONDARY EDUCATION" OR "HIGHER EDUCATION")
FATHER_EDUCATION - FATHER'S EDUCATION (ORDINAL: "NONE", "PRIMARY EDUCATION (4TH GRADE)", "5TH TO 9TH GRADE", "SECONDARY EDUCATION" OR "HIGHER EDUCATION")
MOTHER_JOB - MOTHER'S JOB (NOMINAL: "TEACHER", "HEALTH" CARE RELATED, CIVIL "SERVICES" (E.G. ADMINISTRATIVE OR POLICE), "AT_HOME" OR "OTHER")
FATHER_JOB - FATHER'S JOB (NOMINAL: "TEACHER", "HEALTH" CARE RELATED, CIVIL "SERVICES" (E.G. ADMINISTRATIVE OR POLICE), "AT_HOME" OR "OTHER")
REASON - REASON TO CHOOSE THIS SCHOOL (NOMINAL: CLOSE TO "HOME", SCHOOL "REPUTATION", "COURSE" PREFERENCE OR "OTHER")
GUARDIAN - STUDENT'S GUARDIAN (NOMINAL: "MOTHER", "FATHER" OR "OTHER")
TRAVEL_TIME - HOME TO SCHOOL TRAVEL TIME (ORDINAL: "<15 MIN.", "15 TO 30 MIN.", "30 MIN. TO 1 HOUR", OR 4 - ">1 HOUR")
STUDY_TIME - WEEKLY STUDY TIME (ORDINAL: 1 - "<2 HOURS", "2 TO 5 HOURS", "5 TO 10 HOURS", OR ">10 HOURS")
CLASS_FAILURES - NUMBER OF PAST CLASS FAILURES (NUMERIC: N IF 1<=N<3, ELSE 4)
SCHOOL_SUPPORT - EXTRA EDUCATIONAL SUPPORT (BINARY: YES OR NO)
FAMILY_SUPPORT - FAMILY EDUCATIONAL SUPPORT (BINARY: YES OR NO)
EXTRA_PAID_CLASSES - EXTRA PAID CLASSES WITHIN THE COURSE SUBJECT (MATH OR PORTUGUESE) (BINARY: YES OR NO)
ACTIVITIES - EXTRA-CURRICULAR ACTIVITIES (BINARY: YES OR NO)
NURSERY - ATTENDED NURSERY SCHOOL (BINARY: YES OR NO)
HIGHER_ED - WANTS TO TAKE HIGHER EDUCATION (BINARY: YES OR NO)
INTERNET - INTERNET ACCESS AT HOME (BINARY: YES OR NO)
ROMANTIC_RELATIONSHIP - WITH A ROMANTIC RELATIONSHIP (BINARY: YES OR NO)
FAMILY_RELATIONSHIP - QUALITY OF FAMILY RELATIONSHIPS (NUMERIC: FROM 1 - VERY BAD TO 5 - EXCELLENT)
FREE_TIME - FREE TIME AFTER SCHOOL (NUMERIC: FROM 1 - VERY LOW TO 5 - VERY HIGH)
SOCIAL - GOING OUT WITH FRIENDS (NUMERIC: FROM 1 - VERY LOW TO 5 - VERY HIGH)
WEEKDAY_ALCOHOL - WORKDAY ALCOHOL CONSUMPTION (NUMERIC: FROM 1 - VERY LOW TO 5 - VERY HIGH)
WEEKEND_ALCOHOL - WEEKEND ALCOHOL CONSUMPTION (NUMERIC: FROM 1 - VERY LOW TO 5 - VERY HIGH)
HEALTH - CURRENT HEALTH STATUS (NUMERIC: FROM 1 - VERY BAD TO 5 - VERY GOOD)
ABSENCES - NUMBER OF SCHOOL ABSENCES (NUMERIC: FROM 0 TO 93)
*/




/* ---------------------------------------------------------------------- 
|																		|
|							 DATA ANALYSIS								|
|																		|
-----------------------------------------------------------------------*/


-- 1. BASIC STATISTICS
SELECT
    AVG(AGE) AS AVERAGE_AGE,
    MAX(AGE) AS MAX_AGE,
    MIN(AGE) AS MIN_AGE,
    AVG(FINAL_GRADE) AS AVERAGE_FINAL_GRADE
FROM STUDENTS;

-- 2. PERFORMANCE BY GENDER
SELECT
    SEX,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SEX;


-- 3. INFLUENCE OF STUDY TIME.
SELECT
    STUDY_TIME,
    ROUND(AVG(FINAL_GRADE),2) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY STUDY_TIME;


-- 4. CORRELATION BETWEEN ALCOHOL CONSUMPTION AND PERFORMANCE:
 SELECT
    WEEKDAY_ALCOHOL,
    WEEKEND_ALCOHOL,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY WEEKDAY_ALCOHOL, WEEKEND_ALCOHOL;



-- 5.EFFECT OF ABSENCES ON PERFORMANCE

SELECT
    ABSENCES,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ABSENCES
ORDER BY ABSENCES;


 
-- 6.IMPACT OF PARENTAL EDUCATION.
SELECT
    MOTHER_EDUCATION,
    FATHER_EDUCATION,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY MOTHER_EDUCATION, FATHER_EDUCATION
ORDER BY 
    CASE 
        WHEN MOTHER_EDUCATION = 'NONE' OR FATHER_EDUCATION = 'NONE' THEN 1 
        ELSE 0 
    END,
    FATHER_EDUCATION,
    MOTHER_EDUCATION;

-- 7. PERFORMANCE BY AGE GROUP
SELECT
    AGE,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY AGE;

-- 8. IMPACT OF FAMILY SIZE ON PERFORMANCE
SELECT
    FAMILY_SIZE,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY FAMILY_SIZE;



-- 9. INFLUENCE OF PARENTAL JOBS ON STUDENT PERFORMANCE.
SELECT
    MOTHER_JOB,
    FATHER_JOB,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY MOTHER_JOB, FATHER_JOB;



-- 10. AVERAGE STUDENT GRADES BY MOTHER'S EMPLOYMENT STATUS
SELECT
    CASE 
        WHEN MOTHER_JOB = 'AT_HOME' THEN 'AT HOME'
        ELSE 'OTHER JOBS'
    END AS MOTHER_JOB_CATEGORY,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY MOTHER_JOB_CATEGORY;

-- 11. SCHOOL DIFFERENCES IN PERFORMANCE
SELECT
    SCHOOL,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SCHOOL;

-- 12. RELATIONSHIP BETWEEN FREE TIME AND ACADEMIC PERFORMANCE. 
SELECT
    FREE_TIME,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY FREE_TIME;

-- 13. COMPARISON OF PERFORMANCE BETWEEN STUDENTS LIVING IN URBAN VS RURAL AREAS.
SELECT
    ADDRESS_TYPE,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ADDRESS_TYPE;

-- 14. EFFECT OF ROMANTIC RELATIONSHIPS ON ACADEMIC PERFORMANCE.
SELECT
    ROMANTIC_RELATIONSHIP,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ROMANTIC_RELATIONSHIP;


-- 15. CORRELATION BETWEEN HEALTH STATUS AND GRADES.
SELECT
    HEALTH,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY HEALTH;


-- 16. PERFORMANCE TREND OVER TIME (PERIOD GRADES VS FINAL GRADE).
SELECT
    GRADE_1,
    GRADE_2,
    ROUND(AVG(FINAL_GRADE),2) AS AVERAGE_FINAL_GRADE
FROM STUDENTS
GROUP BY GRADE_1, GRADE_2
HAVING AVERAGE_FINAL_GRADE >7
ORDER BY AVERAGE_FINAL_GRADE DESC;

-- 17. AGGREGATE PERFORMANCE BY PARENTAL EDUCATION LEVEL.
SELECT
    MOTHER_EDUCATION,
    FATHER_EDUCATION,
    COUNT(*) AS NUMBER_OF_STUDENTS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY MOTHER_EDUCATION, FATHER_EDUCATION
ORDER BY 
    CASE 
        WHEN MOTHER_EDUCATION = 'NONE' OR FATHER_EDUCATION = 'NONE' THEN 1 
        ELSE 0 
    END,
    FATHER_EDUCATION,
    MOTHER_EDUCATION;

-- 18. EFFECT OF CLASS FAILURES ON CURRENT PERFORMANCE. 
SELECT
    CLASS_FAILURES,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY CLASS_FAILURES;

-- 19. ANALYSIS OF SCHOOL SUPPORT ON ACADEMIC PERFORMANCE.
SELECT
    SCHOOL_SUPPORT,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SCHOOL_SUPPORT;


-- 20. IMPACT OF EXTRA PAID CLASSES ON PERFORMANCE. 
SELECT
    EXTRA_PAID_CLASSES,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY EXTRA_PAID_CLASSES;
-- (THE EXTRA PAID CLASS SIGNIFICANTLY INCREASES THE AVERAGE FINAL GRADE)

-- 21. CORRELATION BETWEEN FAMILY SUPPORT AND STUDENT PERFORMANCE.
SELECT
    FAMILY_SUPPORT,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY FAMILY_SUPPORT;

-- 22. PERFORMANCE ANALYSIS BASED ON THE CHOICE_REASON FOR CHOOSING SCHOOL.
SELECT
    SCHOOL_CHOICE_REASON,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SCHOOL_CHOICE_REASON;


-- 23. INFLUENCE OF NURSERY SCHOOL ATTENDANCE ON PERFORMANCE. 
SELECT
    NURSERY_SCHOOL,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY NURSERY_SCHOOL;

-- 24. EFFECT OF HAVING INTERNET AT HOME ON GRADES.
SELECT
    INTERNET_ACCESS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY INTERNET_ACCESS;


-- 25. PERFORMANCE ANALYSIS BASED ON THE REASON FOR CHOOSING SCHOOL.
SELECT
    SCHOOL_CHOICE_REASON, COUNT(*) AS NO_OF_STUDENTS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SCHOOL_CHOICE_REASON
ORDER BY AVERAGE_GRADE;

-- 26. INFLUENCE OF EXTRA-CURRICULAR ACTIVITIES ON ACADEMIC PERFORMANCE.ALTER
SELECT
    ACTIVITIES,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ACTIVITIES;


-- 27. CORRELATION BETWEEN FAMILY RELATIONSHIP QUALITY AND ACADEMIC PERFORMANCE.
SELECT
    FAMILY_RELATIONSHIP,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY FAMILY_RELATIONSHIP;


-- 28. SOCIAL LIFE (GOING OUT) VS ACADEMIC PERFORMANCE. 
SELECT
    SOCIAL,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SOCIAL;


-- 29. COMPLEX ANALYSIS OF MULTIPLE FACTORS (E.G., STUDY TIME, ABSENCES, ALCOHOL CONSUMPTION).
SELECT
    STUDY_TIME,
    ABSENCES,
    WEEKDAY_ALCOHOL,
    WEEKEND_ALCOHOL,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY STUDY_TIME, ABSENCES, WEEKDAY_ALCOHOL, WEEKEND_ALCOHOL;

-- 30. COMPARATIVE ANALYSIS OF STUDENTS WITH/WITHOUT ROMANTIC RELATIONSHIPS ACROSS VARIOUS FACTORS.ALTER

SELECT
    ROMANTIC_RELATIONSHIP,
    AVG(AGE) AS AVERAGE_AGE,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE,
    AVG(WEEKDAY_ALCOHOL) AS AVERAGE_WEEKDAY_ALCOHOL,
    AVG(WEEKEND_ALCOHOL) AS AVERAGE_WEEKEND_ALCOHOL
FROM STUDENTS
GROUP BY ROMANTIC_RELATIONSHIP;


-- 31. INFLUENCE OF GUARDIAN TYPE ON STUDENT PERFORMANCE.ALTER
SELECT
    GUARDIAN,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY GUARDIAN;

-- 32. ANALYSIS OF ABSENTEEISM PATTERNS IN RELATION TO FINAL GRADES.
SELECT
    CASE
        WHEN ABSENCES BETWEEN 0 AND 10 THEN '0-10'
        WHEN ABSENCES BETWEEN 11 AND 20 THEN '11-20'
        ELSE '21+'
    END AS ABSENCE_CATEGORY,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ABSENCE_CATEGORY;


-- 33. PERFORMANCE ANALYSIS BASED ON COMBINATION OF PERSONAL AND FAMILY FACTORS.
SELECT
    SEX,
    AGE,
    FAMILY_SIZE,
    PARENT_STATUS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SEX, AGE, FAMILY_SIZE, PARENT_STATUS;



-- 34. AGGREGATE PERFORMANCE ANALYSIS BASED ON LIFESTYLE AND PERSONAL CHOICES.
SELECT
    ROMANTIC_RELATIONSHIP,
    ACTIVITIES,
    INTERNET_ACCESS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ROMANTIC_RELATIONSHIP, ACTIVITIES, INTERNET_ACCESS;




-- 35. PERFORMANCE ANALYSIS BY GENDER AND AGE GROUP WITH AVERAGE ABSENCES. 
SELECT
    SEX,
    CASE 
        WHEN AGE <= 16 THEN '15-16'
        WHEN AGE <= 18 THEN '17-18'
        ELSE '19+'
    END AS AGE_GROUP,
    ROUND(AVG(FINAL_GRADE),2) AS AVERAGE_GRADE,
    AVG(ABSENCES) AS AVERAGE_ABSENCES
FROM STUDENTS
GROUP BY SEX, AGE_GROUP
ORDER BY AVERAGE_GRADE DESC;

-- 36. COMPARATIVE STUDY TIME ANALYSIS BY PARENTAL EDUCATION LEVEL. 
SELECT
    PARENT_STATUS,
    MOTHER_EDUCATION,
    FATHER_EDUCATION,
    STUDY_TIME,
    SCHOOL_SUPPORT,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY PARENT_STATUS, MOTHER_EDUCATION, FATHER_EDUCATION, STUDY_TIME, SCHOOL_SUPPORT;
-- (COMBINE WITH ANOTHER SIMLAR QUERY)


-- 37. PERFORMANCE BASED ON A COMBINATION OF SOCIAL FACTORS AND STUDY HABITS.
SELECT
    CASE 
        WHEN SOCIAL BETWEEN 1 AND 3 THEN 'LOW'
        ELSE 'HIGH'
    END AS SOCIAL_LIFE,
    CASE 
        WHEN STUDY_TIME <= 2 THEN 'LOW'
        ELSE 'HIGH'
    END AS STUDY_TIME,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY SOCIAL_LIFE, STUDY_TIME
ORDER BY AVERAGE_GRADE DESC;



-- 38. CORRELATION BETWEEN ALCOHOL CONSUMPTION, HEALTH, AND PERFORMANCE.
SELECT
    WEEKDAY_ALCOHOL,
    WEEKEND_ALCOHOL,
    HEALTH,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY WEEKDAY_ALCOHOL, WEEKEND_ALCOHOL, HEALTH
ORDER BY HEALTH DESC;


-- 39. COMBINING CURRENT PERFORMANCE WITH PAST FAILURES.
SELECT
    CLASS_FAILURES,
    AVG(FINAL_GRADE) AS AVERAGE_FINAL_GRADE,
    COUNT(*) AS NUMBER_OF_STUDENTS
FROM STUDENTS
GROUP BY CLASS_FAILURES
HAVING COUNT(*) > 5;


-- 40. SUBQUERY ANALYSIS OF TOP PERFORMERS BY VARIOUS CRITERIA
SELECT
    SEX,
    ADDRESS_TYPE,
    COUNT(*) AS NO_OF_STUDENTS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
WHERE FINAL_GRADE >= (SELECT AVG(FINAL_GRADE) FROM STUDENTS)
GROUP BY SEX, ADDRESS_TYPE;



-- 41. IMPACT OF EXTRA-CURRICULAR ACTIVITIES AND PAID CLASSES ON GRADES:
SELECT
    ACTIVITIES,
    EXTRA_PAID_CLASSES,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY ACTIVITIES, EXTRA_PAID_CLASSES;


-- 42. PERFORMANCE ANALYSIS OF STUDENTS WITH DIFFERENT LEVELS OF FAMILY SUPPORT AND HEALTH.
SELECT
    FAMILY_SUPPORT,
    HEALTH,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM STUDENTS
GROUP BY FAMILY_SUPPORT, HEALTH;



-- 43. IN-DEPTH ANALYSIS OF ABSENTEEISM AND ACADEMIC PERFORMANCE.
SELECT
    CASE 
        WHEN ABSENCES <= 5 THEN '0-5'
        WHEN ABSENCES <= 10 THEN '6-10'
        WHEN ABSENCES <= 20 THEN '11-20'
        ELSE '20+'
    END AS ABSENCE_CATEGORY,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE,
    COUNT(*) AS STUDENT_COUNT
FROM STUDENTS
GROUP BY ABSENCE_CATEGORY;


-- 44. RANKING STUDENTS BY PERFORMANCE WITHIN EACH SCHOOL.
WITH RANKED_STUDENTS AS (
    SELECT
        SCHOOL,
        SEX,
        AGE,
        FINAL_GRADE,
        RANK() OVER (PARTITION BY SCHOOL ORDER BY FINAL_GRADE DESC) AS RANK_IN_SCHOOL
    FROM STUDENTS
)
SELECT
    SCHOOL,
    SEX,
    AGE,
    FINAL_GRADE,
    RANK_IN_SCHOOL
FROM RANKED_STUDENTS
WHERE RANK_IN_SCHOOL <= 5;
USE STUDENTS;


-- 45. GRADE IMPROVEMENT ANALYSIS:
WITH GRADE_IMPROVEMENTS AS (
    SELECT
        STUDENT_ID,  
        GRADE_2,
        FINAL_GRADE,
        GRADE_2 - GRADE_1 AS IMPROVEMENT_GRADE_1_TO_2,
        FINAL_GRADE - GRADE_2 AS IMPROVEMENT_GRADE_2_TO_FINAL
    FROM STUDENTS
)
SELECT *
FROM GRADE_IMPROVEMENTS
WHERE IMPROVEMENT_GRADE_1_TO_2 > 0 AND IMPROVEMENT_GRADE_2_TO_FINAL > 0;


-- 46. GRADE DECREMENT ANALYSIS:
WITH GRADE_IMPROVEMENTS AS (
    SELECT
        STUDENT_ID,  -- REPLACE WITH ACTUAL UNIQUE IDENTIFIER COLUMN NAME
        GRADE_1,
        GRADE_2,
        FINAL_GRADE,
        GRADE_2 - GRADE_1 AS DECLINE_GRADE_1_TO_2,
        FINAL_GRADE - GRADE_2 AS DECLINE_GRADE_2_TO_FINAL
    FROM STUDENTS
)
SELECT *
FROM GRADE_IMPROVEMENTS
WHERE DECLINE_GRADE_1_TO_2 <0 AND DECLINE_GRADE_2_TO_FINAL <0;

-- 189 STUDENTS THE PERFORMERNCE CONSECUTIVELY DECREASES




-- 47. GRADE CONSTANT ANALYSIS.
WITH GRADE_IMPROVEMENTS AS (
    SELECT
        STUDENT_ID,  -- REPLACE WITH ACTUAL UNIQUE IDENTIFIER COLUMN NAME
        GRADE_1,
        GRADE_2,
        FINAL_GRADE,
        GRADE_2 - GRADE_1 AS CONSTANT_GRADE_1_TO_2,
        FINAL_GRADE - GRADE_2 AS CONSTANT_GRADE_2_TO_FINAL
    FROM STUDENTS
)
SELECT *
FROM GRADE_IMPROVEMENTS
WHERE CONSTANT_GRADE_1_TO_2 = 0 AND CONSTANT_GRADE_2_TO_FINAL =0;

-- THERE ARE 78 STUDENTS SECURED LESS DURING GRADE_1 AND GRADE_2 BUT SCORED GOOD MARKS IN FINAL.



-- 48. GRADE ANALYSIS
WITH GRADE_IMPROVEMENTS AS (
    SELECT
        STUDENT_ID,  -- REPLACE WITH ACTUAL UNIQUE IDENTIFIER COLUMN NAME
        GRADE_1,
        GRADE_2,
        FINAL_GRADE,
        GRADE_2 - GRADE_1 AS GRADE_1_TO_2,
        FINAL_GRADE - GRADE_2 AS GRADE_2_TO_FINAL
    FROM STUDENTS
),
IMPROVEMENT_GRADES AS (
    SELECT *
    FROM GRADE_IMPROVEMENTS
    WHERE GRADE_1_TO_2 > 0 AND GRADE_2_TO_FINAL > 0
),
REMAIN_CONSTANT_GRADES AS (
    SELECT *
    FROM GRADE_IMPROVEMENTS
    WHERE GRADE_1_TO_2 = 0 AND GRADE_2_TO_FINAL = 0
),
DECLINE_GRADES AS (
    SELECT *
    FROM GRADE_IMPROVEMENTS
    WHERE GRADE_1_TO_2 < 0 AND GRADE_2_TO_FINAL < 0
),
FINAL_GRADE_IMPROVEMENT AS (
    SELECT *
    FROM GRADE_IMPROVEMENTS
    WHERE GRADE_1_TO_2 <= 0 AND GRADE_2_TO_FINAL > 0
)

SELECT 
    (SELECT COUNT(*) FROM IMPROVEMENT_GRADES) AS COUNT_IMPROVEMENT,
    (SELECT COUNT(*) FROM REMAIN_CONSTANT_GRADES) AS COUNT_CONSTANT,
    (SELECT COUNT(*) FROM DECLINE_GRADES) AS COUNT_DECLINE,
    (SELECT COUNT(*) FROM FINAL_GRADE_IMPROVEMENT) AS COUNT_FINAL_GRADE_IMPROVEMENT;



-- 49. CORRELATION ANALYSIS BETWEEN STUDY TIME AND GRADE IMPROVEMENT.
SELECT
    STUDY_TIME,
    AVG(GRADE_2 - GRADE_1) AS AVERAGE_IMPROVEMENT_FROM_1_TO_2,
    AVG(FINAL_GRADE - GRADE_2) AS AVERAGE_IMPROVEMENT_FROM_2_TO_FINAL
FROM STUDENTS
GROUP BY STUDY_TIME;


-- 50. ANALYSIS OF INTERNET ACCESS IMPACT ON DIFFERENT AGE GROUPS:
SELECT
    AGE_GROUP,
    INTERNET_ACCESS,
    AVG(FINAL_GRADE) AS AVERAGE_GRADE
FROM (
    SELECT
        AGE,
        CASE 
            WHEN AGE <= 16 THEN '15-16'
            WHEN AGE <= 18 THEN '17-18'
            ELSE '19+'
        END AS AGE_GROUP,
        INTERNET_ACCESS,
        FINAL_GRADE
    FROM STUDENTS
) AS AGEGROUPED
GROUP BY AGE_GROUP, INTERNET_ACCESS;

SELECT CLASS_FAILURES, COUNT(*) FROM STUDENTS
GROUP BY CLASS_FAILURES;



/* ---------------------------------------------------------------------- 
|																		|
|							 CONCLUSION									|
|																		|
-----------------------------------------------------------------------*/

/*
•	MALE STUDENTS HAVE HIGHER AVERAGE GRADES (10.91) THAN FEMALE STUDENTS (9.97), INDICATING A GENDER GAP IN ACADEMIC PERFORMANCE.
•	INCREASED STUDY TIME CORRELATES WITH HIGHER GRADES, PARTICULARLY FOR STUDENTS STUDYING OVER 5 HOURS WEEKLY, WITH AVERAGE GRADES OF 11.40 AND 11.26 FOR 5-10 HOURS AND OVER 10 HOURS, RESPECTIVELY.
•	ALCOHOL CONSUMPTION SHOWS A COMPLEX RELATIONSHIP WITH ACADEMIC PERFORMANCE WITHOUT A CLEAR LINEAR TREND.
•	STUDENTS WITH ONE ABSENCE HAVE AN UNUSUALLY HIGH AVERAGE GRADE OF 13.00, SUGGESTING NON-LINEAR EFFECTS OF ABSENTEEISM ON GRADES.
•	STUDENTS WITH PARENTS HAVING HIGHER EDUCATION LEVELS ACHIEVE HIGHER AVERAGE GRADES, ABOVE 11.65.
•	STUDENTS FROM SMALLER FAMILIES (THREE OR FEWER MEMBERS) HAVE SLIGHTLY HIGHER AVERAGE GRADES (11.00) THAN THOSE FROM LARGER FAMILIES.
•	PARENTAL JOB COMBINATIONS, LIKE HEALTH AND SERVICES, ARE ASSOCIATED WITH HIGHER STUDENT GRADES (AVERAGE OF 12.4).
•	INTERNET ACCESS AT HOME IS LINKED TO HIGHER AVERAGE STUDENT GRADES (10.6170) COMPARED TO THOSE WITHOUT INTERNET (9.4091).
•	AVERAGE GRADES VARY BETWEEN SCHOOLS, WITH STUDENTS FROM GP SCHOOL AVERAGING 10.49 COMPARED TO 9.8478 AT MS SCHOOL.
•	HIGHER HEALTH STATUS AND BETTER FAMILY RELATIONSHIP QUALITY CORRELATE WITH INCREASED ACADEMIC PERFORMANCE.
•	PARTICIPATION IN EXTRACURRICULAR ACTIVITIES IS ASSOCIATED WITH SLIGHTLY HIGHER STUDENT GRADES (10.4876).
•	ATTENDING EXTRA PAID CLASSES RELATES TO HIGHER AVERAGE GRADES (10.9227) THAN STUDENTS WHO DO NOT ATTEND SUCH CLASSES (9.9860).
•	STUDENTS NOT IN ROMANTIC RELATIONSHIPS HAVE HIGHER AVERAGE GRADES (10.8365) THAN THOSE IN RELATIONSHIPS (9.5758).
•	A BALANCED SOCIAL LIFE, REMARKABLY RATED 2 AND 5, CORRELATES WITH HIGHER AVERAGE GRADES (11.1942 AND 11.3000, RESPECTIVELY).
*/

