/*
The package PKG_GESTIUNE_CONCERTE contains three independent stored subprograms and three triggers.
The GESTIONARE_BILETE procedure manipulates data from tables related to tickets and logs messages in the MESAJE table.
The AFISARE_ARTISTI_GENURI procedure uses two cursors (one simple and one parameterized) to display artists and their associated genres.
The CALCUL_TOTAL_BILETE function calculates the total ticket prices for a user for a concert, handling custom exceptions.
Additionally, the package defines three triggers through dynamic execution:
  - A statement-level trigger (logs inserts into the BILET table)
  - A row-level trigger (updates available seats in the CONCERT table before inserting into BILET)
  - A DDL trigger (monitors DROP and ALTER operations on the LOCATIE table).
*/

-- Package Definition
CREATE OR REPLACE PACKAGE PKG_GESTIUNE_CONCERTE AS

    -- 1. Procedure using collections
    PROCEDURE GESTIONARE_BILETE;

    -- 2. Procedure using two types of cursors
    PROCEDURE AFISARE_ARTISTI_GENURI;

    -- 3. Function for calculating total ticket prices
    FUNCTION CALCUL_TOTAL_BILETE(
        p_id_utilizator UTILIZATOR.ID_UTILIZATOR%TYPE,
        p_id_concert    CONCERT.ID_CONCERT%TYPE
    ) RETURN VARCHAR2;

    -- 4. Procedure for dynamically creating triggers
    PROCEDURE CREARE_TRIGGERE;

    -- 5. Procedure for testing triggers on the BILET table
    PROCEDURE TESTARE_TRIGGER_BILET;

END PKG_GESTIUNE_CONCERTE;
/ 

-- Package Body
CREATE OR REPLACE PACKAGE BODY PKG_GESTIUNE_CONCERTE AS

    ------------------------------------------------------------------------------
    -- 1. GESTIONARE_BILETE Procedure
    ------------------------------------------------------------------------------
    PROCEDURE GESTIONARE_BILETE IS
        -- Define collection types
        TYPE t_bilet_denumire_varray IS VARRAY(10) OF VARCHAR2(50);
        TYPE t_bilet_pret_nested     IS TABLE OF NUMBER;
        TYPE t_bilet_index_by        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

        -- Variables based on defined types
        v_bilet_id      t_bilet_index_by;          -- Index-by table
        v_bilet_denum   t_bilet_denumire_varray;   -- VARRAY
        v_bilet_pret    t_bilet_pret_nested;       -- Nested table

        -- Cursor to iterate through data from TIP_BILET
        CURSOR c_tip_bilet IS
           SELECT ID_TIP_BILET, TIP_BILET, PRET_BILET
             FROM TIP_BILET
         ORDER BY ID_TIP_BILET;

        -- Working variables
        i          BINARY_INTEGER := 0;  -- Counter for collection elements
        pret_total NUMBER := 0;          -- Sum of prices

        -- Variables for logging messages
        v_mesaj VARCHAR2(255);
        v_user  VARCHAR2(40);
        
    BEGIN
        -- Get the current user
        v_user := USER;

        -- Initialize collections
        v_bilet_denum := t_bilet_denumire_varray();
        v_bilet_pret  := t_bilet_pret_nested();

        -- Iterate through the cursor to load data from TIP_BILET
        FOR j IN c_tip_bilet LOOP
            i := i + 1;

            -- Add ticket ID to index-by table
            v_bilet_id(i) := j.ID_TIP_BILET;

            -- Add ticket name to VARRAY (if the limit is not reached)
            IF v_bilet_denum.COUNT < v_bilet_denum.LIMIT THEN
                v_bilet_denum.EXTEND;
                v_bilet_denum(v_bilet_denum.COUNT) := j.TIP_BILET;
            END IF;

            -- Add ticket price to nested table
            v_bilet_pret.EXTEND;
            v_bilet_pret(v_bilet_pret.COUNT) := j.PRET_BILET;

            -- Calculate total price
            pret_total := pret_total + j.PRET_BILET;
        END LOOP;

        -- Log an informational message: loaded i ticket types
        v_mesaj := 'Loaded ' || i || ' ticket types into collections.';
        INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
        VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'I', v_user, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(v_mesaj);

        -- Display and log the average ticket price
        IF i > 0 THEN
            v_mesaj := 'Calculated average price: ' || (pret_total / i);
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'I', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
        ELSE
            -- No tickets found
            v_mesaj := 'No tickets found for average price calculation.';
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'W', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
        END IF;

        -- Display and log tickets with a price above 50
        FOR k IN 1..v_bilet_pret.COUNT LOOP
            IF v_bilet_pret(k) > 50 THEN
                v_mesaj := 'ID: ' || v_bilet_id(k) 
                           || ', Name: ' || v_bilet_denum(k) 
                           || ', Price: ' || v_bilet_pret(k);

                INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
                VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'I', v_user, SYSDATE);
                DBMS_OUTPUT.PUT_LINE(v_mesaj);
            END IF;
        END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_mesaj := 'No data found in TIP_BILET table.';
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'E', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
        WHEN OTHERS THEN
            v_mesaj := 'An error occurred: ' || SQLERRM;
            INSERT INTO Mesaje (cod_mesaj, mesaj, tip_mesaj, creat_de, creat_la)
            VALUES (seq_cod_mesaj.NEXTVAL, v_mesaj, 'E', v_user, SYSDATE);
            DBMS_OUTPUT.PUT_LINE(v_mesaj);
    END GESTIONARE_BILETE;

END PKG_GESTIUNE_CONCERTE;
/

-- Call PKG_GESTIUNE_CONCERTE.AFISARE_ARTISTI_GENURI
BEGIN
    PKG_GESTIUNE_CONCERTE.AFISARE_ARTISTI_GENURI;
END;

-- Call PKG_GESTIUNE_CONCERTE.CALCUL_TOTAL_BILETE
-- Valid case
SELECT PKG_GESTIUNE_CONCERTE.CALCUL_TOTAL_BILETE(1, 2)
FROM DUAL;

-- Invalid case, non-existent user
SELECT PKG_GESTIUNE_CONCERTE.CALCUL_TOTAL_BILETE(9999, 1)
FROM DUAL;

-- Invalid case, non-existent concert
SELECT PKG_GESTIUNE_CONCERTE.CALCUL_TOTAL_BILETE(1, 9999)
FROM DUAL;

-- Call PKG_GESTIUNE_CONCERTE.CREARE_TRIGGERE 
BEGIN
    PKG_GESTIUNE_CONCERTE.CREARE_TRIGGERE;
END;

-- Call PKG_GESTIUNE_CONCERTE.TESTARE_TRIGGER_BILET
BEGIN
     PKG_GESTIUNE_CONCERTE.TESTARE_TRIGGER_BILET;
END;

-- Call PKG_GESTIUNE_CONCERTE.GESTIONARE_BILETE
BEGIN
    PKG_GESTIUNE_CONCERTE.GESTIONARE_BILETE;
END;
/
