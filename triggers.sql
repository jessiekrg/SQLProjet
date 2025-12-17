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

    SELECT id_Client INTO nssi
    FROM VENTE
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
        RAISE_APPLICATION_ERROR(-20005, 
            'ERREUR FEFO : Le lot ' || lot || 
            ' périme plus tôt (' || TO_CHAR(date, 'DD/MM/YYYY') || 
            '). Veuillez prélever celui-ci.');
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





