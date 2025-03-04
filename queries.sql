-- This chapter presents complex SQL queries using clauses, functions, and operators 
-- to work with data in a relational database. Queries include GROUP BY, HAVING, 
-- START WITH, CONNECT BY, and ORDER BY clauses, as well as string functions, 
-- date functions, and miscellaneous functions (DECODE, NVL, CASE). 
-- Set operators, aggregate functions, and subqueries are also utilized.

-- 1.
-- Analysis of revenue and tickets sold per concert
-- This query calculates the total revenue, number of tickets sold, minimum, 
-- maximum, and average ticket prices for each concert. It uses GROUP BY to aggregate data 
-- and functions such as SUM() for total revenue, COUNT() for ticket count, MIN() and MAX() 
-- for extreme prices, and AVG() for the average price. The HAVING clause filters results 
-- to display only concerts with total revenue above 1000. Results are ordered 
-- in descending order by total revenue using ORDER BY.
SELECT 
    c.id_concert,
    c.nume_concert,
    COUNT(*) AS numar_bilete,
    SUM(tb.pret_bilet) AS venit_total,
    MIN(tb.pret_bilet) AS pret_min,
    MAX(tb.pret_bilet) AS pret_max,
    AVG(tb.pret_bilet) AS pret_mediu
FROM bilet b
JOIN tip_bilet tb ON b.id_tip_bilet = tb.id_tip_bilet
JOIN concert c    ON b.id_concert   = c.id_concert
GROUP BY 
    c.id_concert,
    c.nume_concert
HAVING 
    SUM(tb.pret_bilet) > 1000
ORDER BY 
    venit_total DESC;

-- 2.
-- Manipulating concert data with SQL functions
-- This query displays information about concerts, transforming the concert name
-- to lowercase using LOWER() and formatting the concert date with TO_CHAR(). 
-- It also calculates the date of the concert one month later using ADD_MONTHS() 
-- and determines the difference in months between the concert date and two reference dates: 
-- the current date (SYSDATE) and a fixed date, December 1, 2023 (MONTHS_BETWEEN).
SELECT
    LOWER(c.nume_concert) AS nume_concert_lower,
    TO_CHAR(c.data_ora_concert, 'DD-MON-YYYY HH24:MI') AS data_concert,
    TO_CHAR(ADD_MONTHS(c.data_ora_concert, 1), 'DD-MM-YYYY') AS data_plus_o_luna,
    MONTHS_BETWEEN(c.data_ora_concert, SYSDATE) AS dif_fata_de_azi,
    MONTHS_BETWEEN(TO_DATE('01-12-2023','DD-MM-YYYY'), c.data_ora_concert) AS dif_pana_la_1_dec_2023
FROM concert c;

-- 3.
-- Generating the hierarchy of genres and Rock artists
-- This query generates a fictional hierarchy of musical genres, starting from "Rock,"
-- and displays the artists who perform genres in this hierarchy. It uses START WITH
-- to establish the starting point and CONNECT BY NOCYCLE to define and prevent cycles
-- in hierarchical relationships. The hierarchy visualization is enhanced using LPAD()
-- to create indentations based on hierarchy levels (LEVEL). This query demonstrates
-- working with hierarchies in SQL and using string manipulation functions.
SELECT 
    LPAD(' ', LEVEL * 2, ' ') || NUME_GEN AS Hierarchy,
    NUME_ARTIST
FROM 
    GEN
JOIN 
    CANTA ON GEN.ID_GEN = CANTA.ID_GEN
JOIN 
    ARTIST ON CANTA.ID_ARTIST = ARTIST.ID_ARTIST
START WITH 
    NUME_GEN = 'Rock'
CONNECT BY NOCYCLE 
    PRIOR GEN.ID_GEN = CANTA.ID_GEN;

-- 4.
-- Analyzing and processing email addresses
-- This query extracts details from user emails, including:
-- - The email length
-- - The position of '@'
-- - The uppercase prefix (before '@')
-- - The lowercase domain (after '@')
-- Functions used: LENGTH(), INSTR(), SUBSTR(), UPPER(), LOWER().
SELECT
    prenume,
    nume_familie,
    email,
    LENGTH(email) AS email_length,
    INSTR(email, '@') AS at_position,
    UPPER(SUBSTR(email, 1, INSTR(email, '@') - 1)) AS prefix_upper,
    LOWER(SUBSTR(email, INSTR(email, '@') + 1)) AS domain_lower
FROM utilizator;

-- 5.
-- Processing and classifying ticket types
-- This query classifies ticket types based on their price.
-- It uses DECODE() for categorical classification and 
-- CASE statements for price-based classification.
SELECT
    t.id_tip_bilet,
    t.tip_bilet,
    t.pret_bilet,
    DECODE(t.tip_bilet,
           'VIP',       'Very Expensive',
           'Premium',   'Expensive',
           'Standard',  'Normal',
           'Early Bird','Early Promotion',
           'Student',   'Student Discount',
                        'Other') AS description_decode,
    NVL(t.tip_bilet, 'Unknown') AS ticket_type_nvl,
    NULLIF(t.tip_bilet, 'VIP') AS test_nullif,
    CASE
        WHEN t.pret_bilet >= 300 THEN 'Category A'
        WHEN t.pret_bilet >= 200 THEN 'Category B'
        ELSE 'Category C'
    END AS price_classification
FROM tip_bilet t;

-- 6.
-- Complete list of sold tickets with details
-- This query retrieves a list of all sold tickets, displaying:
-- - The full name of the user (concatenation of first and last name)
-- - The concert for which the ticket was purchased
-- - The ticket type
-- The results are sorted alphabetically by last name.
SELECT
    u.prenume || ' ' || u.nume_familie AS user_name,
    c.nume_concert,
    tb.tip_bilet
FROM bilet b
INNER JOIN utilizator u ON b.id_utilizator = u.id_utilizator
INNER JOIN concert c   ON b.id_concert   = c.id_concert
INNER JOIN tip_bilet tb ON b.id_tip_bilet = tb.id_tip_bilet
ORDER BY u.nume_familie;

-- 7.
-- Report categorizing users based on total ticket cost
-- This query groups users into two categories based on their total ticket spending:
-- - "Over 300 RON" for users who spent more than 300 RON
-- - "300 RON or less" for users who spent at most 300 RON
-- NVL() is used to replace NULL values with 0.
SELECT
    'Over 300 RON' AS category,
    u.id_utilizator,
    u.prenume,
    u.nume_familie,
    NVL(SUM(tb.pret_bilet), 0) AS total_ticket_value
FROM utilizator u
LEFT JOIN bilet b  ON u.id_utilizator = b.id_utilizator
LEFT JOIN tip_bilet tb ON b.id_tip_bilet = tb.id_tip_bilet
GROUP BY u.id_utilizator, u.prenume, u.nume_familie
HAVING NVL(SUM(tb.pret_bilet), 0) > 300

UNION ALL

SELECT
    '300 RON or less' AS category,
    u.id_utilizator,
    u.prenume,
    u.nume_familie,
    NVL(SUM(tb.pret_bilet), 0) AS total_ticket_value
FROM utilizator u
LEFT JOIN bilet b  ON u.id_utilizator = b.id_utilizator
LEFT JOIN tip_bilet tb ON b.id_tip_bilet = tb.id_tip_bilet
GROUP BY u.id_utilizator, u.prenume, u.nume_familie
HAVING NVL(SUM(tb.pret_bilet), 0) <= 300
ORDER BY category, total_ticket_value DESC;

-- 8.
-- Full list of concerts and associated artists, including missing data
-- This query retrieves all concerts and their associated artists.
-- FULL JOIN ensures that all concerts and artists are included, even if they are not linked.
-- The results are sorted by concert and artist ID.
SELECT
    c.id_concert,
    c.nume_concert,
    g.id_artist
FROM concert c
FULL JOIN gazduieste g ON c.id_concert = g.id_concert
ORDER BY c.id_concert, g.id_artist;

-- 9.
-- Full list of concerts and associated artists, including missing data
-- This query retrieves all concerts and their associated artists.
-- FULL JOIN ensures that all concerts and artists are included, even if they are not linked.
-- The results are sorted by concert and artist ID.
SELECT
    c.id_concert,
    c.nume_concert,
    g.id_artist
FROM concert c
FULL JOIN gazduieste g ON c.id_concert = g.id_concert
ORDER BY c.id_concert, g.id_artist;

-- 10.
-- Union of genres performed by two artists
-- This query retrieves a unique list of musical genres performed by two different artists.
-- The UNION operator is used to merge the results of two queries and eliminate duplicates.
-- Each query selects the genres associated with an artist using JOIN on the tables `canta` and `gen`, 
-- and filters the data based on the artist ID.
SELECT DISTINCT g.nume_gen
FROM canta c
JOIN gen g ON c.id_gen = g.id_gen
WHERE c.id_artist = 12
UNION
SELECT DISTINCT g.nume_gen
FROM canta c
JOIN gen g ON c.id_gen = g.id_gen
WHERE c.id_artist = 6;

-- 11.
-- Intersection of genres performed by two artists
-- This query finds the common musical genres performed by both artists.
-- The INTERSECT operator returns only the genres that appear in both queries.
-- Each selection extracts the genres associated with a specific artist using JOIN, 
-- and filters the results based on the artist's ID.
SELECT g.nume_gen
FROM canta c
JOIN gen g ON c.id_gen = g.id_gen
WHERE c.id_artist = 12
INTERSECT
SELECT g.nume_gen
FROM canta c
JOIN gen g ON c.id_gen = g.id_gen
WHERE c.id_artist = 6;

-- 12.
-- Difference in genres performed between two artists
-- This query retrieves the genres performed exclusively by the artist with id_artist = 12.
-- The MINUS operator calculates the difference between the datasets associated with both artists.
-- The tables `canta` and `gen` are joined, and the WHERE clause filters the genres for each artist.
SELECT g.nume_gen
FROM canta c
JOIN gen g ON c.id_gen = g.id_gen
WHERE c.id_artist = 12
MINUS
SELECT g.nume_gen
FROM canta c
JOIN gen g ON c.id_gen = g.id_gen
WHERE c.id_artist = 6;

-- 13.
-- Number of artists per concert
-- This query displays the number of artists participating in each concert.
-- A scalar subquery in the SELECT clause counts the records in the `GAZDUIESTE` table.
-- The COUNT(*) function is used with the WHERE clause to filter data based on concert ID.
SELECT
    c.id_concert,
    c.nume_concert,
    (
       SELECT COUNT(*)
       FROM gazduieste g
       WHERE g.id_concert = c.id_concert
    ) AS nr_artisti
FROM concert c;

-- 14.
-- Users who purchased more than 3 tickets
-- This query identifies users who have bought more than 2 tickets.
-- A subquery calculates the total number of tickets purchased by each user using COUNT(*) 
-- and the GROUP BY clause. 
-- The results are joined with the `utilizator` table to display user details.
SELECT 
    u.id_utilizator,
    u.prenume,
    u.nume_familie,
    sub.total_bilete
FROM
    ( SELECT b.id_utilizator, COUNT(*) AS total_bilete
      FROM bilet b
      GROUP BY b.id_utilizator
    ) sub
JOIN utilizator u ON u.id_utilizator = sub.id_utilizator
WHERE sub.total_bilete > 2
ORDER BY sub.total_bilete DESC;

-- 15.
-- Users with tickets for all concerts of the artist "Alternosfera"
-- This query identifies users who have tickets for all concerts where the artist "Alternosfera" performs.
-- The main subquery uses the MINUS operator to find the difference between 
-- concerts where the artist performs and concerts for which the users have tickets.
-- The NOT EXISTS clause confirms that there are no missing concerts.
-- Relationships between tables are handled using INNER JOIN, and filtering is performed based on the artist and user.
SELECT U.ID_UTILIZATOR, U.PRENUME, U.NUME_FAMILIE
FROM UTILIZATOR U
WHERE NOT EXISTS (
    SELECT ID_CONCERT
    FROM GAZDUIESTE G
    INNER JOIN ARTIST A ON G.ID_ARTIST = A.ID_ARTIST
    WHERE A.NUME_ARTIST = 'Alternosfera'
    MINUS
    SELECT B.ID_CONCERT
    FROM BILET B
    WHERE B.ID_UTILIZATOR = U.ID_UTILIZATOR
);



