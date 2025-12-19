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

create or replace trigger verif_lot_avant_vente
before update on lot
for each row
declare 
    v_quantite_commande number;
begin
    select Quantite
    into v_quantite_commande
    from COMMANDE
    where id_Commande = :NEW.Id_Commande

    if v_quantite_commande != :NEW.Quantite then
        DBMS_OUTPUT.PUT_LINE('Attention : la quantité du lot ne correspond pas à la commande.');
    end if;
end;
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


-- Il faut faire une contrainte d'integrité en mode quand quantité lot = 0 il est supprimé
-- On peut prendre d'un lot en cours de livraison


----------------------------------------------------------------------------------------------------------------------------------------

--- les trigger corrigé du copain

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_1_SECURITE_LOT
BEFORE INSERT ON LIGNEVENTE
FOR EACH ROW
DECLARE
    v_lot_fefo NUMBER;
BEGIN
    -- On cherche le numéro du lot qui périme le plus tôt pour ce même médicament
    SELECT num_lot INTO v_lot_fefo
    FROM (
        SELECT num_lot
        FROM LOT
        WHERE code_cip = (SELECT code_cip FROM LOT WHERE num_lot = :NEW.numero_de_lot)
        ORDER BY Date_Peremption ASC
    ) WHERE ROWNUM = 1;

    -- Si le lot choisi n'est pas le plus ancien, on bloque
    IF :NEW.numero_de_lot != v_lot_fefo THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERREUR SECURITE : Le lot ' || v_lot_fefo || ' périme plus tôt. Veuillez utiliser celui-ci.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_LIGNEVENTE_2_CALCUL_PRIX
BEFORE INSERT ON LIGNEVENTE
FOR EACH ROW
FOLLOWS TRG_LIGNEVENTE_1_SECURITE_LOT
DECLARE
    v_prix_pub NUMBER;
    v_taux     NUMBER := 0;
BEGIN
    -- 1. Récupération du prix public du médicament via le lot
    SELECT prix_public INTO v_prix_pub 
    FROM MEDICAMENT M 
    JOIN LOT L ON L.code_cip = M.code_cip 
    WHERE L.num_lot = :NEW.numero_de_lot;

    -- 2. Récupération du taux de remboursement du client
    BEGIN
        SELECT COUV.taux_de_remboursement INTO v_taux
        FROM COUVERTURE COUV
        JOIN CLIENT C ON C.Nom_mutuelle = COUV.Nom_mutuelle
        JOIN VENTE V ON V.id_Client = C.NSSI -- Ajuste ici si ta colonne s'appelle NSSI ou id_Client
        WHERE V.id_Vente = :NEW.id_Vente;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_taux := 0;
    END;

    -- 3. Injection du prix calcul
    :NEW.prix_après_remboursement := (v_prix_pub * :NEW.quantité_vendu) * (1 - (v_taux / 100));
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

CREATE OR REPLACE TRIGGER Calcule_Prix_Vente
AFTER INSERT OR UPDATE ON LIGNEVENTE
FOR EACH ROW
BEGIN
    UPDATE VENTE
    SET prixfinal = (
        SELECT SUM(lv.prix_après_remboursement)
        FROM LIGNEVENTE lv
        WHERE lv.id_vente = :NEW.id_vente
    )
    WHERE id_vente = :NEW.id_vente;
END;
/
