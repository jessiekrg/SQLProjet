CREATE OR REPLACE TRIGGER VérificationDisque
BEFORE INSERT ON PARTITION 
FOR EACH ROW 
DECLARE 
    V_tailletotaleP NUMBER;
    V_CAPACAITÉ NUMBER;
BEGIN 
    SELECT CAPACITÉ INTO V_CAPACAITÉ
    FROM DISQUE
    WHERE :NEW.nomDisque = nom;

    SELECT SUM(NVL(TAILLE)) INTO V_tailletotaleP
    FROM PARTITION
    WHERE nomDisque = :NEW.nomDisque;

    IF V_tailletotaleP > V_CAPACAITÉ THEN 
        RAISE_APPLICATION_ERROR(-20001, 'La capacité du disque est dépassée');
    END IF;


