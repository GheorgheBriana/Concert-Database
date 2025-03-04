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
