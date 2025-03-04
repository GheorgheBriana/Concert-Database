-- This chapter presents complex SQL queries using clauses, functions, and operators 
-- to work with data in a relational database. Queries include GROUP BY, HAVING, 
-- START WITH, CONNECT BY, and ORDER BY clauses, as well as string functions, 
-- date functions, and miscellaneous functions (DECODE, NVL, CASE). 
-- Set operators, aggregate functions, and subqueries are also utilized.

-- 7.1 Analysis of revenue and tickets sold per concert
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

-- 7.2 Manipulating concert data with SQL functions
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

-- 7.3 Generating the hierarchy of genres and Rock artists
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

-- The rest of the queries follow the same format with explanations as comments above the SQL statements.
