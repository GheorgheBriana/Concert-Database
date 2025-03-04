-- Table: MESAJE
-- This table stores system messages related to various database operations. 
-- Messages can be of different types, such as errors, warnings, and informational messages.
-- Each message is associated with the user who triggered the operation and the timestamp of creation.

CREATE TABLE MESAJE (
    cod_mesaj  NUMBER PRIMARY KEY, -- Unique identifier for each message
    mesaj      VARCHAR2(255), -- The content of the message
    tip_mesaj  VARCHAR2(1) CHECK (tip_mesaj IN ('E','W','I')), -- Message type: 'E' (Error), 'W' (Warning), 'I' (Information)
    creat_de   VARCHAR2(40) NOT NULL, -- Username of the user who triggered the message
    creat_la   DATE NOT NULL -- Timestamp of when the message was created
);

-- Sequence for generating unique message IDs
CREATE SEQUENCE seq_cod_mesaj START WITH 1 INCREMENT BY 1;
