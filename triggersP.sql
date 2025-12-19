
--- Trigger qui determine le lot optimal (date de péremption la plus récente) à extraire lorsque le pharmacien créer une nouvelle ligne de vente pour un médicament)

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_1_AUTO_LOT
BEFORE INSERT OR UPDATE ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_cip          NUMBER;
    v_lot_fefo     NUMBER;
    v_date_fefo    DATE;
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
        -- Si ni lot ni ordonnance, on ne peut rien faire
        RAISE_APPLICATION_ERROR(-20010, 'saisir soit un lot ou une ordonnance.');
    END IF;
    -- RECHERCHE DU LOT OPTIMAL (Le plus proche de la péremption avec du stock)
    SELECT num_lot, Date_Peremption INTO v_lot_fefo, v_date_fefo
    FROM (
        SELECT num_lot, Date_Peremption
        FROM LOT
        WHERE code_cip = v_cip 
          AND Quantite >= :NEW.quantité_vendu
        ORDER BY Date_Peremption ASC
    ) WHERE ROWNUM = 1;
    --CORRECTION
    --  Si c'était saisi mais qu'il y a plus récent, on remplace.
    IF v_date_saisie > v_date_fefo THEN
        :NEW.numero_de_lot := v_lot_fefo;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Erreur : Aucun stock disponible pour ce médicament ou ordonnance invalide.');
END;
/


-- Calcule le prix d'une ligne de vente 

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_2_CALCUL_PRIX
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
        -- Note : J'utilise V.id_Client ici. Si ton champ s'appelle autrement, remplace-le.
        BEGIN
            SELECT COUV.taux_de_remboursement INTO v_taux
            FROM VENTE V
            JOIN CLIENT C ON V.id_Client = C.NSSI  -- <--- CORRECTION ICI
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
--- Met à jour le stock lors d'une nouvelle vente de médicament 

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


CREATE OR REPLACE TRIGGER verif_lot_avant_vente
BEFORE INSERT ON LOT
FOR EACH ROW
DECLARE 
    v_quantite_attendue NUMBER;
BEGIN
    SELECT Quantite
    INTO v_quantite_attendue
    FROM COMMANDE
    WHERE id_Commande = :NEW.id_Commande;
    IF :NEW.Quantite != v_quantite_attendue THEN
        RAISE_APPLICATION_ERROR(-20008,'Quantité livrée (' || :NEW.Quantite || ') différente de la quantité commandée (' || v_quantite_attendue || ')');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009, 'Le numéro de commande ' || :NEW.id_Commande || ' n''existe pas.');
END;
/