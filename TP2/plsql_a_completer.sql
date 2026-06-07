-- ============================================================
--  TP PL/SQL + CONTROLE D'INTEGRITE -- VERSION A COMPLETER
--  LSIN513 - Base de Données
--  Remplace les ___ par le bon code PL/SQL
-- ============================================================

-- Structure d'un bloc PL/SQL à retenir :
-- DECLARE   → déclaration des variables
-- BEGIN     → corps du programme
-- EXCEPTION → gestion des erreurs
-- END;      /


-- ============================================================
--  EXERCICE PRELIMINAIRE : Créer la table RESULTAT
-- ============================================================

CREATE TABLE ___ (
    ___  NUMBER,
    ___  VARCHAR(___)
);


-- ============================================================
--  EXERCICE 1
-- ============================================================
-- Objectif : demander un ClientId, compter ses commandes,
-- insérer 'pas de commandes' ou 'il y a n commande pour le client X'

DECLARE
    v_clientId  NUMBER          := ___; -- saisie utilisateur avec &
    v_nbCmd     NUMBER;
    v_nom       CLIENT.___%;TYPE;       -- type calqué sur la colonne
    v_message   VARCHAR(40);
BEGIN
    -- Récupérer le nom du client
    SELECT ___ INTO v_nom
    FROM ___
    WHERE ___ = v_clientId;

    -- Compter les commandes
    SELECT ___ INTO v_nbCmd
    FROM ___
    WHERE ___ = v_clientId;

    -- Construire le message avec IF/ELSE
    IF ___ THEN
        v_message := '___';
    ELSE
        v_message := 'il y a ' || ___ || ' commande pour le client ' || ___;
    END IF;

    -- Insérer dans RESULTAT
    INSERT INTO RESULTAT VALUES (___, ___);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE(___);

EXCEPTION
    WHEN ___ THEN
        DBMS_OUTPUT.PUT_LINE('Client introuvable.');
END;
/


-- ============================================================
--  EXERCICE 2
-- ============================================================
-- Objectif :
-- 1) Demander un ClientId
-- 2) Calculer total commandes client + moyenne ville
-- 3) Réduction 10% si total > moyenne, sinon 5%

DECLARE
    v_clientId  NUMBER        := ___;
    v_ville     CLIENT.Ville%TYPE;
    v_total     NUMBER(10,2);
    v_moyenne   NUMBER(10,2);
BEGIN
    -- Récupérer la ville
    SELECT ___ INTO v_ville
    FROM ___
    WHERE ___ = v_clientId;

    -- Total des commandes du client (NVL pour éviter NULL)
    SELECT NVL(___, 0) INTO v_total
    FROM ___
    WHERE ___ = v_clientId;

    -- Moyenne des commandes de la même ville
    SELECT NVL(___, 0) INTO v_moyenne
    FROM COMMANDE cmd
    JOIN CLIENT c ON ___
    WHERE c.Ville = ___;

    -- Affichage
    DBMS_OUTPUT.PUT_LINE('Total : ' || ___);
    DBMS_OUTPUT.PUT_LINE('Moyenne ville : ' || ___);

    -- Appliquer la réduction
    IF ___ THEN
        UPDATE COMMANDE SET PrixTotal = PrixTotal * ___
        WHERE ClientId = v_clientId;
    ELSE
        UPDATE COMMANDE SET PrixTotal = PrixTotal * ___
        WHERE ClientId = v_clientId;
    END IF;

    COMMIT;
END;
/


-- ============================================================
--  EXERCICE 3
-- ============================================================
-- Objectif : afficher la nième et nième+1 commandes les plus récentes
-- n saisi par l'utilisateur

DECLARE
    v_n     NUMBER := ___;

    CURSOR c_cmds IS
        SELECT CommandeId, Date_com, PrixTotal,
               ___ OVER (ORDER BY Date_com DESC) AS rang  -- fonction de rang
        FROM COMMANDE;
BEGIN
    DELETE FROM RESULTAT;

    FOR v_row IN ___ LOOP
        IF v_row.rang = ___ OR v_row.rang = ___ THEN
            INSERT INTO RESULTAT VALUES (
                ___,
                'Cde ' || ___ || ' ' ||
                TO_CHAR(v_row.Date_com,'DD/MM/YYYY') || ' ' || ___
            );
            DBMS_OUTPUT.PUT_LINE('Rang ' || v_row.rang || ' : Cde ' || ___);
        END IF;
    END LOOP;

    COMMIT;
END;
/


-- ============================================================
--  EXERCICE 4
-- ============================================================
-- Objectif : curseur paramétré, vérifier PrixTotal = SUM(ItemTotal)
-- Format ligne : 'Cde:X PT:Y Calc:Z'

DECLARE
    -- Déclarer un curseur paramétré
    CURSOR ___ (___ NUMBER) IS
        SELECT SUM(___) AS total_calc
        FROM ___
        WHERE CommandeId = ___;

    v_total_calc  NUMBER(10,2);
    v_msg         VARCHAR(40);
BEGIN
    DELETE FROM RESULTAT;

    FOR cmd IN (SELECT CommandeId, PrixTotal FROM COMMANDE) LOOP

        OPEN ___(cmd.CommandeId);
        FETCH ___ INTO v_total_calc;
        CLOSE ___;

        v_total_calc := NVL(v_total_calc, 0);

        v_msg := 'Cde:' || ___ || ' PT:' || ___ || ' Calc:' || ___;

        INSERT INTO RESULTAT VALUES (___, ___);
    END LOOP;

    COMMIT;
END;
/


-- ============================================================
--  EXERCICE 5
-- ============================================================
-- Objectif : corriger PrixTotal quand ≠ SUM(ItemTotal)

DECLARE
    v_total_calc NUMBER(10,2);
BEGIN
    FOR cmd IN (SELECT CommandeId, PrixTotal FROM COMMANDE) LOOP

        SELECT NVL(___, 0) INTO v_total_calc
        FROM ___
        WHERE ___ = cmd.CommandeId;

        IF ___ THEN   -- si différent
            UPDATE ___
            SET PrixTotal = ___
            WHERE ___ = cmd.CommandeId;
        END IF;

    END LOOP;
    COMMIT;
END;
/


-- ============================================================
--  EXERCICE 6
-- ============================================================
-- Objectif : Exercice 3 + gestion erreur si N > nb commandes
-- Créer une exception personnalisée avec EXCEPTION + RAISE

DECLARE
    v_n            NUMBER := ___;
    v_nb_total     NUMBER;
    ___            EXCEPTION;   -- nom de l'exception personnalisée

    CURSOR c_cmds IS
        SELECT CommandeId, Date_com, PrixTotal,
               ROW_NUMBER() OVER (ORDER BY Date_com DESC) AS rang
        FROM COMMANDE;
BEGIN
    SELECT COUNT(*) INTO ___ FROM COMMANDE;

    IF ___ THEN          -- condition : N+1 > nb total
        RAISE ___;       -- déclencher l'exception
    END IF;

    DELETE FROM RESULTAT;

    FOR v_row IN c_cmds LOOP
        IF v_row.rang IN (___, ___) THEN
            INSERT INTO RESULTAT VALUES (
                ___,
                'Cde ' || ___ || ' ' ||
                TO_CHAR(v_row.Date_com,'DD/MM/YYYY') || ' ' || ___
            );
        END IF;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN ___ THEN          -- attraper l'exception
        INSERT INTO RESULTAT VALUES (
            -1,
            'ERREUR : N=' || ___ || ' > max=' || ___
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('ERREUR : N trop grand.');
END;
/


-- ============================================================
--  EXERCICE 7 : PACKAGE
-- ============================================================
-- Un package = spécification (interface) + corps (implémentation)

-- ---- Spécification ----
CREATE OR REPLACE PACKAGE ___ AS
    PROCEDURE ___;           -- trier clients par total décroissant
    FUNCTION  ___ RETURN ___; -- retourner ID du meilleur client
END ___;
/

-- ---- Corps ----
CREATE OR REPLACE PACKAGE BODY ___ AS

    PROCEDURE ___ IS
    BEGIN
        DELETE FROM RESULTAT;

        FOR rec IN (
            SELECT c.ClientId,
                   NVL(SUM(cmd.PrixTotal), 0) AS Total
            FROM CLIENT c
            LEFT JOIN COMMANDE cmd ON ___
            GROUP BY ___
            ORDER BY ___ DESC   -- ordre décroissant
        ) LOOP
            INSERT INTO RESULTAT VALUES (
                ___,
                'Client ' || ___ || ' Total:' || ___
            );
        END LOOP;

        COMMIT;
    END ___;

    FUNCTION ___ RETURN ___ IS
        v_clientId NUMBER;
    BEGIN
        SELECT ClientId INTO v_clientId
        FROM (
            SELECT ClientId, SUM(PrixTotal) AS Total
            FROM COMMANDE
            GROUP BY ___
            ORDER BY ___ DESC
        )
        WHERE ROWNUM = 1;   -- premier = meilleur

        RETURN ___;
    END ___;

END ___;
/

-- Appels
BEGIN
    ___.tri_clients;
    DBMS_OUTPUT.PUT_LINE('Meilleur client : ' || ___.meilleur_client);
END;
/


-- ============================================================
--  CONTROLE D'INTEGRITE (TRIGGERS)
-- ============================================================
-- Syntaxe d'un trigger :
-- CREATE OR REPLACE TRIGGER nom
-- BEFORE/AFTER INSERT OR UPDATE OR DELETE ON table
-- FOR EACH ROW   ← ligne par ligne (optionnel)
-- BEGIN ... END;


-- -------------------------------------------------------
-- Contrainte 1 : CommandeId et ItemId entre 1 et 999
-- -------------------------------------------------------
ALTER TABLE COMMANDE ADD CONSTRAINT ___
    CHECK (___ BETWEEN ___ AND ___);

ALTER TABLE LIGNECOMMANDE ADD CONSTRAINT ___
    CHECK (___ BETWEEN ___ AND ___);


-- -------------------------------------------------------
-- Contrainte 2 : Nationalité ∈ {FR,GB,D,E,B}
--               + client FR doit avoir une adresse
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
BEFORE INSERT OR UPDATE ON CLIENT
FOR EACH ROW
BEGIN
    IF :NEW.Nationalite NOT IN (___) THEN
        RAISE_APPLICATION_ERROR(___, '___');
    END IF;

    IF ___ AND ___ IS NULL THEN
        RAISE_APPLICATION_ERROR(___, '___');
    END IF;
END;
/


-- -------------------------------------------------------
-- Contrainte 3 : CommandeId = max + 1
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
BEFORE INSERT ON COMMANDE
FOR EACH ROW
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(___), 0) INTO v_max FROM COMMANDE;

    IF :NEW.CommandeId <> ___ THEN
        RAISE_APPLICATION_ERROR(___, '___');
    END IF;
END;
/


-- -------------------------------------------------------
-- Contrainte 4 : ville → un seul département
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
BEFORE INSERT OR UPDATE ON CLIENT
FOR EACH ROW
DECLARE
    v_dept CLIENT.Departement%TYPE;
BEGIN
    BEGIN
        SELECT DISTINCT ___ INTO v_dept
        FROM CLIENT
        WHERE Ville = :NEW.Ville AND ROWNUM = 1;

        IF v_dept <> :NEW.Departement THEN
            RAISE_APPLICATION_ERROR(___, '___');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;
END;
/


-- -------------------------------------------------------
-- Contrainte 5 : dates croissantes
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
BEFORE INSERT ON COMMANDE
FOR EACH ROW
DECLARE
    v_max_date DATE;
BEGIN
    SELECT ___ INTO v_max_date FROM COMMANDE;

    IF v_max_date IS NOT NULL AND :NEW.Date_com < ___ THEN
        RAISE_APPLICATION_ERROR(___, '___');
    END IF;
END;
/


-- -------------------------------------------------------
-- Contrainte 6 : PrixTotal auto-calculé depuis LigneCommande
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
AFTER INSERT OR UPDATE OR DELETE ON LIGNECOMMANDE
FOR EACH ROW
DECLARE
    v_cmdId NUMBER;
BEGIN
    IF DELETING THEN
        v_cmdId := :OLD.CommandeId;
    ELSE
        v_cmdId := :NEW.CommandeId;
    END IF;

    UPDATE COMMANDE
    SET PrixTotal = (
        SELECT NVL(SUM(___), 0)
        FROM LIGNECOMMANDE
        WHERE CommandeId = ___
    )
    WHERE CommandeId = ___;
END;
/


-- -------------------------------------------------------
-- Contrainte 7 : remise 10% si PrixTotal >= seuil
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
BEFORE INSERT ON COMMANDE
FOR EACH ROW
DECLARE
    v_seuil NUMBER := ___;   -- seuil à définir
BEGIN
    IF :NEW.PrixTotal >= ___ THEN
        :NEW.PrixTotal := :NEW.PrixTotal * ___;
    END IF;
END;
/


-- -------------------------------------------------------
-- Contrainte 8 : bloquer suppression client avec commandes
--               + cascade update ClientId
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER ___
BEFORE DELETE ON CLIENT
FOR EACH ROW
DECLARE
    v_nb NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_nb
    FROM COMMANDE WHERE ClientId = :OLD.ClientId;

    IF v_nb > 0 THEN
        RAISE_APPLICATION_ERROR(___, '___');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER ___
AFTER UPDATE OF ClientId ON CLIENT
FOR EACH ROW
BEGIN
    UPDATE COMMANDE
    SET ClientId = ___
    WHERE ClientId = ___;
END;
/


-- -------------------------------------------------------
-- Contrainte 9 : journal d'activité INSERT/UPDATE/DELETE
-- -------------------------------------------------------
CREATE TABLE JOURNAL_ACTIVITE (
    Table_name  VARCHAR(20),
    Nb_Insert   NUMBER DEFAULT 0,
    Nb_Update   NUMBER DEFAULT 0,
    Nb_Delete   NUMBER DEFAULT 0
);
INSERT INTO JOURNAL_ACTIVITE VALUES ('COMMANDE', 0, 0, 0);
INSERT INTO JOURNAL_ACTIVITE VALUES ('PRODUIT',  0, 0, 0);
COMMIT;

CREATE OR REPLACE TRIGGER ___
AFTER INSERT OR UPDATE OR DELETE ON COMMANDE
BEGIN
    IF ___ THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Insert = Nb_Insert + 1
        WHERE Table_name = 'COMMANDE';
    ELSIF ___ THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Update = Nb_Update + 1
        WHERE Table_name = 'COMMANDE';
    ELSIF ___ THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Delete = Nb_Delete + 1
        WHERE Table_name = 'COMMANDE';
    END IF;
END;
/

-- Faire de même pour PRODUIT...
CREATE OR REPLACE TRIGGER ___
AFTER INSERT OR UPDATE OR DELETE ON PRODUIT
BEGIN
    IF ___ THEN
        UPDATE JOURNAL_ACTIVITE SET ___ WHERE Table_name = 'PRODUIT';
    ELSIF ___ THEN
        UPDATE JOURNAL_ACTIVITE SET ___ WHERE Table_name = 'PRODUIT';
    ELSIF ___ THEN
        UPDATE JOURNAL_ACTIVITE SET ___ WHERE Table_name = 'PRODUIT';
    END IF;
END;
/

SELECT * FROM JOURNAL_ACTIVITE;

-- ============================================================
--  FIN DU FICHIER A COMPLETER
-- ============================================================
