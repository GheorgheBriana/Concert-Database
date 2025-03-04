-- 1.
-- This procedure organizes data from the TIP_BILET table into three types of collections(index-by table, varray, nested table)
-- calculates the total and average ticket prices, and displays tickets with prices above 50. 
-- All relevant messages are stored in the MESAJE table, and errors are handled.

CREATE OR REPLACE PROCEDURE GESTIONARE_BILETE IS
    -- Varray for ticket type (name)
    TYPE t_bilet_denumire_varray IS VARRAY(10) OF VARCHAR2(50);

    -- Nested table for ticket price
    TYPE t_bilet_pret_nested IS TABLE OF NUMBER;

    -- Index-by table for ticket ID
    TYPE t_bilet_index_by IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    v_bilet_id      t_bilet_index_by;
    v_bilet_denum   t_bilet_denumire_varray;
    v_bilet_pret    t_bilet_pret_nested;

    CURSOR c_tip_bilet IS
        SELECT ID_TIP_BILET, TIP_BILET, PRET_BILET
        FROM TIP_BILET
        ORDER BY ID_TIP_BILET;

    i BINARY_INTEGER := 0;
    pret_total NUMBER := 0;

    -- Auxiliary variables for messages
    v_mesaj VARCHAR2(255);
    v_user VARCHAR2(40);
BEGIN
    -- Get the current user
    v_user := USER;

    -- Initialize collections
    v_bilet_denum := t_bilet_denumire_varray();
    v_bilet_pret := t_bilet_pret_nested();

    -- Iterate through TIP_BILET table
    FOR j IN c_tip_bilet LOOP
        i := i + 1;

        -- Add ticket ID
        v_bilet_id(i) := j.ID_TIP_BILET;

        -- Add ticket name (if there is space in varray)
        IF v_bilet_denum.COUNT < v_bilet_denum.LIMIT THEN
            v_bilet_denum.EXTEND;
            v_bilet_denum(v_bilet_denum.COUNT) := j.TIP_BILET;
        END IF;

        -- Add ticket price
        v_bilet_pret.EXTEND;
        v_bilet_pret(v_bilet_pret.COUNT) := j.PRET_BILET;

        -- Calculate total price
        pret_total := pret_total + j.PRET_BILET;
    END LOOP;

    -- Construct message and insert into the MESAJE table
    v_mesaj := 'Loaded ' || i || ' ticket types into collections.';
    INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
    VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'I', v_user, SYSDATE);
    DBMS_OUTPUT.PUT_LINE(v_mesaj);

    -- Display average price and insert message
    IF i > 0 THEN
        v_mesaj := 'Calculated average price: ' || (pret_total / i);
        INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'I', v_user, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(v_mesaj);
    ELSE
        v_mesaj := 'No tickets found for price calculation.';
        INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'W', v_user, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(v_mesaj);
    END IF;

    -- Display tickets with price above 50 and insert messages
    FOR k IN 1..v_bilet_pret.COUNT LOOP
        IF v_bilet_pret(k) > 50 THEN
            v_mesaj := 'ID: ' || v_bilet_id(k) || 
                       ', Name: ' || v_bilet_denum(k) || 
                       ', Price: ' || v_bilet_pret(k);
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'I', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
        END IF;
    END LOOP;

    -- Handle possible errors and insert messages
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_mesaj := 'No data found in the TIP_BILET table.';
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'E', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
        WHEN OTHERS THEN
            v_mesaj := 'An error occurred: ' || SQLERRM;
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'E', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
END;
/

-- Call procedure
EXEC GESTIONARE_BILETE;

-- ---------------------------------------------------- --
-- 2.
/*
This stored procedure retrieves a list of artists using a simple cursor
and then fetches the associated music genres for each artist using a parameterized cursor.
The parameterized cursor depends on the main cursor, processing genres based on the artist's ID.
For each artist, their details (ID and name) are displayed, followed by their associated music genres.
If an error occurs, a descriptive message is saved in the "mesaje" table.
The procedure is demonstrated using the EXEC command.
*/
CREATE OR REPLACE PROCEDURE DISPLAY_ARTISTS_GENRES IS
    -- Cursor for retrieving artist details
    CURSOR c_artists IS
        SELECT id_artist, nume_artist
        FROM artist;

    -- Parameterized cursor for retrieving genres associated with a specific artist
    CURSOR c_genres_artist (p_id_artist NUMBER) IS
        SELECT g.nume_gen
        FROM canta c
             JOIN gen g ON c.id_gen = g.id_gen
        WHERE c.id_artist = p_id_artist;

    -- Variables for storing artist details
    v_id_artist  artist.id_artist%TYPE;
    v_nume_artist artist.nume_artist%TYPE;

    -- Variable for storing genre name
    v_nume_gen    gen.nume_gen%TYPE;

    -- Variable for storing messages
    v_message VARCHAR2(255);

BEGIN
    -- Open the cursor for artists
    OPEN c_artists;
    LOOP
        -- Fetch artist details
        FETCH c_artists INTO v_id_artist, v_nume_artist;
        EXIT WHEN c_artists%NOTFOUND;

        -- Construct and insert the message for the artist
        v_message := 'Artist: ' || v_nume_artist || ' (ID=' || v_id_artist || ') - Genres:';
        INSERT INTO mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'I', USER, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(v_message);

        -- Open the cursor for the genres of the current artist
        OPEN c_genres_artist(v_id_artist);
        LOOP
            -- Fetch genre data
            FETCH c_genres_artist INTO v_nume_gen;
            EXIT WHEN c_genres_artist%NOTFOUND;

            -- Construct and insert the message for each genre
            v_message := '   * ' || v_nume_gen;
            INSERT INTO mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'I', USER, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_message);
        END LOOP;

        -- Close the genre cursor
        CLOSE c_genres_artist;

        -- Separator for clear display
        v_message := '------------------------------------';
        INSERT INTO mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'I', USER, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(v_message);
    END LOOP;

    -- Close the artist cursor
    CLOSE c_artists;

EXCEPTION
    -- Error handling
    WHEN OTHERS THEN
        v_message := 'Error occurred: ' || SQLERRM;
        INSERT INTO mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'E', USER, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(v_message);
END;
/

-- Procedure execution
EXEC DISPLAY_ARTISTS_GENRES;

-- ---------------------------------------------------- --
-- 3.
/*
This stored function calculates the total price of tickets purchased by a user for a specific concert
using a single SQL command that involves three defined tables.
The function checks the existence of the user and the concert in the database,
and handles all possible exceptions, including two custom exceptions.
*/

CREATE OR REPLACE FUNCTION CALCULATE_TOTAL_TICKETS(
    p_user_id  UTILIZATOR.ID_UTILIZATOR%TYPE,
    p_concert_id  CONCERT.ID_CONCERT%TYPE
) 
RETURN VARCHAR2
IS
    -- Exception for non-existent user
    ex_user_not_found    EXCEPTION;

    -- Exception for non-existent concert
    ex_concert_not_found EXCEPTION;

    -- Error code -20001 for non-existent user
    PRAGMA EXCEPTION_INIT(ex_user_not_found, -20001);

    -- Error code -20002 for non-existent concert
    PRAGMA EXCEPTION_INIT(ex_concert_not_found, -20002);

    -- Total ticket price
    v_total         TIP_BILET.PRET_BILET%TYPE;

    -- User existence check
    v_count_user    NUMBER;

    -- Concert existence check
    v_count_concert NUMBER;

    -- User and concert names
    v_user_name     UTILIZATOR.PRENUME%TYPE;
    v_concert_name  CONCERT.NUME_CONCERT%TYPE;

    -- Final formatted result
    v_result        VARCHAR2(4000);

    -- Message variable
    v_message VARCHAR2(255);

BEGIN
    -- Verify user existence
    SELECT COUNT(*) 
      INTO v_count_user
      FROM UTILIZATOR
     WHERE ID_UTILIZATOR = p_user_id;

    IF v_count_user = 0 THEN
        RAISE ex_user_not_found;
    END IF;

    -- Verify concert existence
    SELECT COUNT(*) 
      INTO v_count_concert
      FROM CONCERT
     WHERE ID_CONCERT = p_concert_id;

    IF v_count_concert = 0 THEN
        RAISE ex_concert_not_found;
    END IF;

    -- Retrieve user name
    SELECT PRENUME || ' ' || NUME_FAMILIE
      INTO v_user_name
      FROM UTILIZATOR
     WHERE ID_UTILIZATOR = p_user_id;

    -- Retrieve concert name
    SELECT NUME_CONCERT
      INTO v_concert_name
      FROM CONCERT
     WHERE ID_CONCERT = p_concert_id;

    -- Calculate total ticket price
    SELECT SUM(t.PRET_BILET)
      INTO v_total
      FROM BILET b
      JOIN TIP_BILET t ON b.ID_TIP_BILET = t.ID_TIP_BILET
      JOIN CONCERT c   ON b.ID_CONCERT = c.ID_CONCERT
     WHERE b.ID_UTILIZATOR = p_user_id
       AND b.ID_CONCERT    = p_concert_id;

    IF v_total IS NULL THEN
        v_total := 0;
    END IF;

    -- Format final result
    v_result := 'User ID: ' || p_user_id || CHR(10) || 
                'User Name: ' || v_user_name || CHR(10) || 
                'Concert ID: ' || p_concert_id || CHR(10) || 
                'Concert Name: ' || v_concert_name || CHR(10) || 
                'Total Ticket Price: ' || v_total;

    -- Insert message into "Mesaje" table
    v_message := 'Total ticket price for user ID ' || p_user_id ||
                 ' and concert ID ' || p_concert_id || ': ' || v_total;
    INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
    VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'I', USER, SYSDATE);

    RETURN v_result;

EXCEPTION
    -- Handle exception: user not found
    WHEN ex_user_not_found THEN
        v_message := 'User with ID ' || p_user_id || ' does not exist.';
        INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'E', USER, SYSDATE);
        RETURN v_message;

    -- Handle exception: concert not found
    WHEN ex_concert_not_found THEN
        v_message := 'Concert with ID ' || p_concert_id || ' does not exist.';
        INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'E', USER, SYSDATE);
        RETURN v_message;

    -- Handle other errors
    WHEN OTHERS THEN
        v_message := 'An error occurred: ' || SQLERRM;
        INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_message, 'E', USER, SYSDATE);
        RETURN v_message;
END;
/

-- Function execution
DECLARE
    v_result VARCHAR2(4000);
BEGIN
    -- Case 1 => valid result
    DBMS_OUTPUT.PUT_LINE('CASE 1 => VALID RESULT');
    DBMS_OUTPUT.PUT_LINE(CALCULATE_TOTAL_TICKETS(1, 2));
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
 
    -- Case 2 => non-existent user
    DBMS_OUTPUT.PUT_LINE('CASE 2 => USER NOT FOUND');
    DBMS_OUTPUT.PUT_LINE(CALCULATE_TOTAL_TICKETS(999, 2));
    DBMS_OUTPUT.PUT_LINE('----------------------------------');

    -- Case 3 => non-existent concert
    DBMS_OUTPUT.PUT_LINE('CASE 3 => CONCERT NOT FOUND');
    DBMS_OUTPUT.PUT_LINE(CALCULATE_TOTAL_TICKETS(2, 999));
    DBMS_OUTPUT.PUT_LINE('----------------------------------');

    -- Case 4 => user has no tickets for concert
    DBMS_OUTPUT.PUT_LINE('CASE 4 => USER HAS NO TICKETS');
    DBMS_OUTPUT.PUT_LINE(CALCULATE_TOTAL_TICKETS(3, 1));
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
END;

-- -------------------------------------------- --
-- 3.
