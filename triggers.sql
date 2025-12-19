--  les scripts PL/SQL de création des triggers, ainsi que leur formulation en langage naturel.

-- 1. Si le client possède une ordonnance, le prix de chaque médicament qu’elle contient doit être calculé en fonction du taux de remboursement auquel le client a droit. 
CREATE OR REPLACE TRIGGER MAJ_REMBOURSEMENT
BEFORE INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE 
    pp    MEDICAMENT.prix_public%TYPE;
    tr    COUVERTURE.taux_de_remboursement%TYPE;
    nssi CLIENT.NSSI%TYPE;
BEGIN 
    SELECT M.prix_public INTO pp
    FROM MEDICAMENT M
    JOIN LOT L ON L.code_cip = M.code_cip
    WHERE L.num_lot = :NEW.numero_de_lot;

    SELECT CL.id_Client INTO nssi
    FROM VENTE V
    JOIN CLIENT CL ON CL.NSSI = V.id_Client
    WHERE id_Vente = :NEW.id_Vente;

    SELECT C.taux_de_remboursement INTO tr
    FROM COUVERTURE C
    JOIN CLIENT CL ON CL.Nom_mutuelle = C.Nom_mutuelle
    WHERE CL.NSSI = nssi;

    :NEW.prix_après_remboursement := (pp * :NEW.quantité_vendu) * (1 - (NVL(tr, 0) / 100));

EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        :NEW.prix_après_remboursement := pp * :NEW.quantité_vendu;
END;
/

-- 2. Un médicament doit toujours être prélevé du lot dont la date de péremption est la plus proche.
CREATE OR REPLACE TRIGGER LOTp
BEFORE INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE
    CIP      LOT.code_cip%TYPE;
    lot     LOT.num_lot%TYPE;
    date    DATE;
BEGIN
    -- 1. Trouver le code CIP du médicament concerné par le lot scanné
    SELECT code_cip INTO CIP FROM LOT WHERE num_lot = :NEW.numero_de_lot;

    -- 2. Identifier le lot qui périme le plus tôt (FEFO) et qui possède du stock
    SELECT num_lot, date_peremption INTO lot, date
    FROM (
        SELECT num_lot, date_peremption
        FROM LOT
        WHERE code_cip = CIP AND quantite_en_stock > 0
        ORDER BY date_peremption ASC
    )
    WHERE ROWNUM = 1;

    -- 3. Comparaison et blocage si erreur de prélèvement
    IF :NEW.numero_de_lot != lot THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Le lot ' || lot || ' périme plus tôt (' || TO_CHAR(date, 'DD/MM/YYYY') || '). ');
    END IF;
END;
/

--  les scripts PL/SQL de création des triggers, ainsi que leur formulation en langage naturel.



-- 3. Déduction simple de la quantité du lot choisi (lot à péremption proche)

CREATE OR REPLACE TRIGGER Update_Quantite_Lot
AFTER INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_num_lot LOT.num_lot%TYPE;
BEGIN
    -- On récupère le lot avec le même médicament que le lot initial et la péremption la plus proche
    SELECT num_lot
    INTO v_num_lot
    FROM LOT
    WHERE CODE_CIP = (SELECT CODE_CIP FROM LOT WHERE num_lot = :NEW.numero_de_lot)
      AND Quantite >= :NEW.quantité_vendu
    ORDER BY Date_Peremption
    FETCH FIRST 1 ROWS ONLY;

    -- Mise à jour de la quantité du lot choisi
    UPDATE LOT
    SET Quantite = Quantite - :NEW.quantité_vendu
    WHERE num_lot = v_num_lot;
END;
/

-- 4. Compléter la vente si le lot initial est insuffisant

CREATE OR REPLACE TRIGGER Complete_Quantite_Lot
AFTER INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_qt_restante NUMBER;
    v_num_lot LOT.num_lot%TYPE;
    v_code_cip LOT.code_cip%TYPE;
BEGIN
    -- On récupère le code CIP du lot initial
    SELECT CODE_CIP
    INTO v_code_cip
    FROM LOT
    WHERE num_lot = :NEW.numero_de_lot;

    -- On récupère la quantité restante dans le lot initial
    SELECT Quantite
    INTO v_qt_restante
    FROM LOT
    WHERE num_lot = :NEW.numero_de_lot;

    -- Si le lot initial n'a pas assez de quantité
    IF v_qt_restante < :NEW.quantité_vendu THEN
        -- On met le lot initial à 0
        UPDATE LOT
        SET Quantite = 0
        WHERE num_lot = :NEW.numero_de_lot;

        -- Calcul de la quantité restante à délivrer
        v_qt_restante := :NEW.quantité_vendu - v_qt_restante;

        -- On récupère le lot suivant disponible (péremption la plus proche)
        SELECT num_lot
        INTO v_num_lot
        FROM LOT
        WHERE CODE_CIP = v_code_cip
          AND Quantite >= v_qt_restante
        ORDER BY Date_Peremption
        FETCH FIRST 1 ROWS ONLY;

        -- Création d'une nouvelle ligne de vente pour compléter
        INSERT INTO LIGNEVENTE (
            id_Lignevente,
            id_Vente,
            numero_de_lot,
            quantité_vendu
        )
        VALUES (
            SEQ_LIGNEVENTE.NEXTVAL,
            :NEW.id_Vente,
            v_num_lot,
            v_qt_restante
        );

        -- Mise à jour du lot complémentaire
        UPDATE LOT
        SET Quantite = Quantite - v_qt_restante
        WHERE num_lot = v_num_lot;
    END IF;
END;
/


-- 5. Ce trigger vérifie, avant toute modification d’un lot, que la quantité et le médicament correspondent à ceux spécifiés dans la commande associée

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

-- 6. Contrôle des sur-délivrance (= la quantité vendus doit correspondre à la quantité prescrite mentionnées sur une ligne d’ordonnance)

create or replace trigger verif_surdelivrance
before insert on lignevente
for each row
declare 
    v_qt_prescrite number
begin 
    select qt_délivré
    into v_qt_prescrite
    from ligneordonnance 
    where id_ligneordonnace = :NEW.id_ordonnance;

    if :NEW.quantité_vendu >  v_qt_prescrite then
        RAISE_APPLICATION_ERROR(-20002, 'Erreur : la quantité vendue dépasse la quantité prescrite sur l''ordonnance.');
    end if;
end;
/

-- Un pharmacien ne peut pas traiter une ordonnance dont la date de péremption est passée. 
CREATE OR REPLACE TRIGGER VALIDITE_ORDONNANCE
BEFORE INSERT ON VENTE 
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

-- Chaque vente et ligne de vente antérieure à la date actuelle ne peuvent être modifiée, elles sont dès lors verrouillées
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



-- Il faut faire une contrainte d'integrité en mode quand quantité lot = 0 il est supprimé
-- On peut prendre d'un lot en cours de livraison


----------------------------------------------------------------------------------------------------------------------------------------

--- les trigger corrigé du copain

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
