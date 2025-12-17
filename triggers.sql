--  les scripts PL/SQL de création des triggers, ainsi que leur formulation en langage naturel.

-- 2. Si le client possède une ordonnance, le prix de chaque médicament qu’elle contient doit être calculé en fonction du taux de remboursement auquel le client a droit. 
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

-- 4. Un médicament doit toujours être prélevé du lot dont la date de péremption est la plus proche.
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