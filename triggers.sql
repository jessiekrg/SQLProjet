--  les scripts PL/SQL de création des triggers, ainsi que leur formulation en langage naturel.

--Trigger 1 : Un médicament doit toujours être prélevé du lot dont la date de péremption est la plus proche.

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_1_AUTO_LOT
BEFORE INSERT OR UPDATE ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_cip NUMBER;
    v_lot_p NUMBER;
    v_date_p DATE;
    v_date_saisie DATE;
BEGIN
    IF :NEW.numero_de_lot IS NULL AND :NEW.id_ordonnance IS NOT NULL THEN
        SELECT id_medicament INTO v_cip
        FROM LIGNEORDONNANCE
        WHERE id_ordonnance = :NEW.id_ordonnance
        AND ROWNUM = 1;

    ELSIF :NEW.numero_de_lot IS NOT NULL THEN
        SELECT code_cip, Date_Peremption INTO v_cip, v_date_saisie
        FROM LOT 
        WHERE num_lot = :NEW.numero_de_lot;

    ELSE
    RAISE_APPLICATION_ERROR(-20010, 'saisir soit un lot ou une ordonnance');
    END IF;

    SELECT num_lot, Date_Peremption INTO v_lot_p, v_date_p
    FROM (
        SELECT num_lot, Date_Peremption
        FROM LOT
        WHERE code_cip = v_cip 
          AND Quantite >= :NEW.quantité_vendu
        ORDER BY Date_Peremption ASC
    ) WHERE ROWNUM = 1;

    IF v_date_saisie > v_date_p THEN
        :NEW.numero_de_lot := v_lot_p;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, '0 stock disponible pour ce médicament ou ordonnance invalide');
END;
/

-- Trigger 2 : Trigger qui ajuste le prix de chaque médicament d’une ordonnance selon le taux de remboursement du client.

CREATE OR REPLACE TRIGGER LIGNEVENTE_CALCUL_PRIX
BEFORE INSERT OR UPDATE ON LIGNEVENTE
FOR EACH ROW
FOLLOWS TRG_LIGNEVENTE_1_AUTO_LOT
DECLARE
    v_prix_pub NUMBER(8,2);
    v_taux     NUMBER(5,2) := 0;
BEGIN
    IF :NEW.numero_de_lot IS NOT NULL THEN
        
        -- 1. Récupération du prix public
        BEGIN
            SELECT M.prix_public INTO v_prix_pub 
            FROM MEDICAMENT M 
            JOIN LOT L ON L.code_cip = M.code_cip 
            WHERE L.num_lot = :NEW.numero_de_lot;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN v_prix_pub := 0;
        END;

        -- 2. Récupération du taux de remboursement
        BEGIN
            SELECT COUV.taux_de_remboursement INTO v_taux
            FROM VENTE V
            JOIN CLIENT C ON V.id_Client = C.NSSI
            JOIN COUVERTURE COUV ON C.Nom_mutuelle = COUV.Nom_mutuelle
            WHERE V.id_Vente = :NEW.id_Vente;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN v_taux := 0;
        END;

        -- 3. Calcul du prix final
        :NEW.prix_après_remboursement := (:NEW.quantité_vendu * v_prix_pub) * (1 - (v_taux / 100));
        
    END IF;
END;
/

-- Trigger 3 : Trigger de mise à jour automatique du stock après vente.

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_3_MAJ_STOCK
AFTER INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_stock_actuel NUMBER;
BEGIN
    -- 1. Vérification du stock restant
    SELECT Quantite INTO v_stock_actuel FROM LOT WHERE num_lot = :NEW.numero_de_lot;

    IF v_stock_actuel < :NEW.quantité_vendu THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERREUR STOCK : Quantité insuffisante (Dispo: ' || v_stock_actuel || ').');
    ELSE
        -- 2. Mise à jour
        UPDATE LOT
        SET Quantite = Quantite - :NEW.quantité_vendu
        WHERE num_lot = :NEW.numero_de_lot;
    END IF;
END;
/

-- Trigger 4 : Trigger de recalcul automatique du total de la vente après modification des lignes.

CREATE OR REPLACE TRIGGER Calcule_Prix_Vente
AFTER INSERT OR UPDATE OR DELETE ON LIGNEVENTE
BEGIN
    UPDATE VENTE
    SET prixfinal = (
        SELECT NVL(SUM(prix_après_remboursement),0)
        FROM LIGNEVENTE
        WHERE LIGNEVENTE.id_vente = VENTE.id_vente
    )
    WHERE id_vente IN (SELECT DISTINCT id_vente FROM LIGNEVENTE);
    END;
/



-- Trigger 5 :  Ce trigger vérifie, avant toute modification d’un lot, que la quantité et le médicament correspondent à ceux spécifiés dans la commande associée

CREATE OR REPLACE TRIGGER verif_livraison_conforme
BEFORE INSERT ON LOT
FOR EACH ROW                            -- FONCTIONNE
DECLARE 
    v_quantite_attendue NUMBER;
BEGIN
    SELECT Quantite
    INTO v_quantite_attendue
    FROM COMMANDE
    WHERE id_Commande = :NEW.id_Commande;

    IF :NEW.Quantite != v_quantite_attendue THEN
        DBMS_OUTPUT.PUT_LINE('Attention : la quantité du lot ne correspond pas à la commande.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009, 'ERREUR : Le numéro de commande ' || :NEW.id_Commande || ' n''existe pas.');
END;
/

    

-- Trigger 6 :  Contrôle des sur-délivrance (= la quantité vendus doit correspondre à la quantité prescrite mentionnées sur une ligne d’ordonnance)


CREATE OR REPLACE TRIGGER verif_surdelivrance
BEFORE INSERT ON lignevente         -- FONCTIONNE
FOR EACH ROW
DECLARE
    v_qt_prescrite NUMBER;
BEGIN
    -- On récupère la quantité prescrite pour **la première ligne** de l'ordonnance
    SELECT qt_delivre
    INTO v_qt_prescrite
    FROM ligneordonnance
    WHERE id_ordonnance = :NEW.id_ordonnance
    AND ROWNUM = 1;

    IF :NEW.quantité_vendu > v_qt_prescrite THEN 
        RAISE_APPLICATION_ERROR(-20002,'Erreur : la quantité vendue dépasse la quantité prescrite pour ce médicament.');
    END IF;
END;
/


-- Trigger 7 : Un pharmacien ne peut pas traiter une ordonnance dont la date de péremption est passée. 
CREATE OR REPLACE TRIGGER VALIDITE_ORDONNANCE?
BEFORE INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE
    DP DATE;

BEGIN
    SELECT date_peremption INTO DP
    FROM ORDONNANCE
    WHERE id_ordonnance = :NEW.id_ordonnance;

    IF DP < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'ordonnance a expiré ');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
END;
/

-- Trigger 8 : Chaque vente et ligne de vente antérieure à la date actuelle ne peuvent être modifiée, elles sont dès lors verrouillées
CREATE OR REPLACE TRIGGER VERROUILLAGE_LIGNE
BEFORE UPDATE OR DELETE ON LIGNEVENTE
FOR EACH ROW
DECLARE
    D DATE;
BEGIN
    SELECT date_vente INTO D
    FROM VENTE
    WHERE id_Vente = :OLD.id_Vente;

    IF D < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Modification interdite.');
    END IF;
END;
/
