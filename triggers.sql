--  les scripts PL/SQL de création des triggers, ainsi que leur formulation en langage naturel.

--Trigger 1 : Un médicament doit toujours être prélevé du lot dont la date de péremption est la plus proche.

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_1_AUTO_LOT
BEFORE INSERT OR UPDATE ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_cip          NUMBER;
    v_lot_p     NUMBER;
    v_date_p    DATE;
    v_date_saisie  DATE;
BEGIN
    -- CAS 1 : Le pharmacien a laissé le lot vide mais il y a une ordonnance 
    IF :NEW.numero_de_lot IS NULL AND :NEW.id_ordonnance IS NOT NULL THEN
        -- On trouve le médicament via l'ordonnance
        SELECT id_medicament INTO v_cip
        FROM LIGNEORDONNANCE
        WHERE id_ordonnance = :NEW.id_ordonnance
        AND ROWNUM = 1;
    -- CAS 2 : Le pharmacien a saisi un numéro de lot 
    ELSIF :NEW.numero_de_lot IS NOT NULL THEN
        -- On identifie le médicament
        SELECT code_cip, Date_Peremption INTO v_cip, v_date_saisie
        FROM LOT 
        WHERE num_lot = :NEW.numero_de_lot;
    ELSE
        -- Si ni lot ni ordonnance on peut rien faire
        RAISE_APPLICATION_ERROR(-20010, 'saisir soit un lot ou une ordonnance');
    END IF;
    -- RECHERCHE DU LOT OPTIMAL (Le plus proche de la péremption avec du stock)
    SELECT num_lot, Date_Peremption INTO v_lot_p, v_date_p
    FROM (
        SELECT num_lot, Date_Peremption
        FROM LOT
        WHERE code_cip = v_cip 
          AND Quantite >= :NEW.quantité_vendu
        ORDER BY Date_Peremption ASC
    ) WHERE ROWNUM = 1;
    --CORRECTION
    --  Si c'était saisi mais qu'il y a plus récent, on emplace.
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


--- Insertion test trigger 

-- 1. On crée la couverture (la mutuelle)
INSERT INTO COUVERTURE (Nom_mutuelle, taux_de_remboursement) 
VALUES ('MAIF Santé', 75); -- Un remboursement de 75%

-- 2. On crée le client associé
INSERT INTO CLIENT (NSSI, Nom, Prenom, Adresse, contact, Nom_mutuelle) 
VALUES (195017512345678, 'DUPONT', 'Jean', '12 Rue de la Paix' , '0601020304','MAIF Santé');

-- 3. On crée une vente vide pour ce client (pour pouvoir y attacher des lignes de vente)
INSERT INTO VENTE (id_Vente, Date_Vente, id_Client, id_Pharmacien) 
VALUES (600, SYSDATE, 195017512345678, 1); -- On suppose que le pharmacien ID 1 existe

-- Création de l'ordonnance (id_Ordonnance doit faire 11 chiffres selon vos contraintes)
INSERT INTO ORDONNANCE (id_Ordonnance, date_Prescription, date_De_Peremption, Id_RPPS, NSSI) 
VALUES (
    20000000001, 
    TO_DATE('2024-05-20', 'YYYY-MM-DD'), 
    TO_DATE('2024-11-20', 'YYYY-MM-DD'), 
    10101234567, -- ID RPPS du Dr Alice Martin
    195017512345678 -- NSSI de Jean Dupont
);


-- Ajout de Doliprane 500mg (CIP: 340093000001) à l'ordonnance
INSERT INTO LIGNEORDONNANCE (id_ligneordonnace, qt_delivre, duree_trait, date_traitement, id_medicament, id_ordonnance, id_RPPS)
VALUES (
    1, 
    3,              -- Quantité prescrite
    5,              -- Durée du traitement 
    SYSDATE, 
    340093000001,   -- Code CIP du Doliprane
    20000000001,   -- Liaison avec l'ID Ordonnance créé ci-dessus
    10000000001    -- ID RPPS du Pharmacien Julien Lefèvre
);

INSERT INTO VENTE (id_Vente, DateVente, prixfinal, id_Pharmacien,  id_Client) 
VALUES (600, SYSDATE,NULL,10000000001, 195017512345678); -- (Julien)

-- Insertion d'une ligne de vente --(On laisse prix_après_remboursement à NULL POUR LE CALCUL)
INSERT INTO LIGNEVENTE (id_Lignevente, quantité_vendu, prix_après_remboursement, id_Vente, numero_de_lot, id_ordonnance)
VALUES (999, 2, NULL, 600, NULL, 20000000001), -- num lot null car le pharmacien a l'ordonnance 
VALUES (1000, 1, NULL, 600, 1, NULL); --- bon bah le pharmacien il n'a pas d'ordonnace mais il sait exactement quel medicamanent, on part du postulat que qu'il a une idée du lot des médicaments mais pas necessairement de la date de peremption la plus proche, le trigger s'en chargera  

INSERT INTO LIGNEVENTE (id_Lignevente, quantité_vendu, prix_après_remboursement, id_Vente, numero_de_lot, id_ordonnance)



-- ON OBTIENT NORMALEMENT UNE LIGNE DE VENTE QUI EXTRAIT LE MEDICAMENT DU LOT 6 ET UN PRIX APRES REMBOURSEMENT DE 0.98 OUIIII (l'autre et valide aussi ) et la somme est bonne.
