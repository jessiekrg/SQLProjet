-- ============================================================
--  TP PL/SQL + CONTROLE D'INTEGRITE -- CORRIGE COMPLET
--  LSIN513 - Base de Données
-- ============================================================


-- ============================================================
--  EXERCICE PRELIMINAIRE : Créer la table RESULTAT
-- ============================================================

DROP TABLE RESULTAT;

CREATE TABLE RESULTAT (
    Code    NUMBER,
    Message VARCHAR(40)
);


-- ============================================================
--  EXERCICE 1
--  a) Demande l'identifiant d'un client
--  b) Insère un tuple dans RESULTAT :
--     - 'pas de commandes' si aucune commande
--     - 'il y a n commande pour le client X' sinon
-- ============================================================

-- Structure PL/SQL de base à connaître :
-- DECLARE  → variables
-- BEGIN    → corps du programme
-- EXCEPTION → gestion des erreurs
-- END;

DECLARE
    v_clientId  NUMBER          := &clientId;   -- saisie utilisateur
    v_nbCmd     NUMBER;
    v_nom       CLIENT.Nom%TYPE;
    v_message   VARCHAR(40);
BEGIN
    -- Récupérer le nom du client
    SELECT Nom INTO v_nom
    FROM CLIENT
    WHERE ClientId = v_clientId;

    -- Compter ses commandes
    SELECT COUNT(*) INTO v_nbCmd
    FROM COMMANDE
    WHERE ClientId = v_clientId;

    -- Construire le message
    IF v_nbCmd = 0 THEN
        v_message := 'pas de commandes';
    ELSE
        v_message := 'il y a ' || v_nbCmd || ' commande pour le client ' || v_nom;
    END IF;

    -- Insérer dans RESULTAT
    INSERT INTO RESULTAT VALUES (v_clientId, v_message);
    COMMIT;

    -- Afficher
    DBMS_OUTPUT.PUT_LINE(v_message);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Client introuvable.');
END;
/


-- ============================================================
--  EXERCICE 2
--  1) Demande l'identifiant d'un client
--  2) Affiche total commandes client + moyenne ville
--  3) Applique réduction 10% si total > moyenne ville, sinon 5%
-- ============================================================

DECLARE
    v_clientId  NUMBER        := &clientId;
    v_ville     CLIENT.Ville%TYPE;
    v_total     NUMBER(10,2);
    v_moyenne   NUMBER(10,2);
BEGIN
    -- Récupérer la ville du client
    SELECT Ville INTO v_ville
    FROM CLIENT
    WHERE ClientId = v_clientId;

    -- Total des commandes du client
    SELECT NVL(SUM(PrixTotal), 0) INTO v_total
    FROM COMMANDE
    WHERE ClientId = v_clientId;

    -- Moyenne des commandes des clients de la même ville
    SELECT NVL(AVG(cmd.PrixTotal), 0) INTO v_moyenne
    FROM COMMANDE cmd
    JOIN CLIENT c ON cmd.ClientId = c.ClientId
    WHERE c.Ville = v_ville;

    -- Affichage
    DBMS_OUTPUT.PUT_LINE('Total commandes client  : ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Moyenne ville (' || v_ville || ') : ' || v_moyenne);

    -- Mise à jour avec réduction
    IF v_total > v_moyenne THEN
        DBMS_OUTPUT.PUT_LINE('Réduction appliquée : 10%');
        UPDATE COMMANDE
        SET PrixTotal = PrixTotal * 0.90
        WHERE ClientId = v_clientId;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Réduction appliquée : 5%');
        UPDATE COMMANDE
        SET PrixTotal = PrixTotal * 0.95
        WHERE ClientId = v_clientId;
    END IF;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Client introuvable.');
END;
/


-- ============================================================
--  EXERCICE 3
--  Afficher la nième et nième+1 commandes les plus récentes
--  Insérer dans RESULTAT
--  n saisi par l'utilisateur
-- ============================================================

DECLARE
    v_n         NUMBER := &n;
    v_cmdId1    COMMANDE.CommandeId%TYPE;
    v_date1     COMMANDE.Date_com%TYPE;
    v_prix1     COMMANDE.PrixTotal%TYPE;
    v_cmdId2    COMMANDE.CommandeId%TYPE;
    v_date2     COMMANDE.Date_com%TYPE;
    v_prix2     COMMANDE.PrixTotal%TYPE;

    -- Curseur trié par date décroissante avec numéro de rang
    CURSOR c_cmds IS
        SELECT CommandeId, Date_com, PrixTotal,
               ROW_NUMBER() OVER (ORDER BY Date_com DESC) AS rang
        FROM COMMANDE;

    v_row c_cmds%ROWTYPE;
BEGIN
    DELETE FROM RESULTAT;

    FOR v_row IN c_cmds LOOP
        IF v_row.rang = v_n THEN
            v_cmdId1 := v_row.CommandeId;
            v_date1  := v_row.Date_com;
            v_prix1  := v_row.PrixTotal;

            INSERT INTO RESULTAT VALUES (
                v_row.CommandeId,
                'Cde ' || v_row.CommandeId || ' ' ||
                TO_CHAR(v_row.Date_com,'DD/MM/YYYY') || ' ' ||
                v_row.PrixTotal
            );

        ELSIF v_row.rang = v_n + 1 THEN
            v_cmdId2 := v_row.CommandeId;
            v_date2  := v_row.Date_com;
            v_prix2  := v_row.PrixTotal;

            INSERT INTO RESULTAT VALUES (
                v_row.CommandeId,
                'Cde ' || v_row.CommandeId || ' ' ||
                TO_CHAR(v_row.Date_com,'DD/MM/YYYY') || ' ' ||
                v_row.PrixTotal
            );
        END IF;
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Commande ' || v_n   || ' : ' || v_cmdId1 || ' ' || v_date1 || ' ' || v_prix1);
    DBMS_OUTPUT.PUT_LINE('Commande ' || (v_n+1) || ' : ' || v_cmdId2 || ' ' || v_date2 || ' ' || v_prix2);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Pas assez de commandes.');
END;
/


-- ============================================================
--  EXERCICE 4
--  Curseur paramétré : vérifier que PrixTotal = SUM(ItemTotal)
--  Insérer dans RESULTAT une ligne par commande
-- ============================================================

DECLARE
    -- Curseur paramétré sur une commande donnée
    CURSOR c_lignes (p_cmdId NUMBER) IS
        SELECT SUM(ItemTotal) AS total_calc
        FROM LIGNECOMMANDE
        WHERE CommandeId = p_cmdId;

    v_total_calc    NUMBER(10,2);
    v_msg           VARCHAR(40);

BEGIN
    DELETE FROM RESULTAT;

    -- Boucle sur toutes les commandes
    FOR cmd IN (SELECT CommandeId, PrixTotal FROM COMMANDE) LOOP

        -- Ouvrir curseur paramétré pour cette commande
        OPEN c_lignes(cmd.CommandeId);
        FETCH c_lignes INTO v_total_calc;
        CLOSE c_lignes;

        v_total_calc := NVL(v_total_calc, 0);

        v_msg := 'Cde:' || cmd.CommandeId ||
                 ' PT:' || cmd.PrixTotal   ||
                 ' Calc:' || v_total_calc;

        INSERT INTO RESULTAT VALUES (cmd.CommandeId, v_msg);

    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Vérification terminée. Voir table RESULTAT.');
END;
/


-- ============================================================
--  EXERCICE 5
--  Corriger PrixTotal quand il diffère de SUM(ItemTotal)
-- ============================================================

DECLARE
    v_total_calc NUMBER(10,2);
BEGIN
    FOR cmd IN (SELECT CommandeId, PrixTotal FROM COMMANDE) LOOP

        SELECT NVL(SUM(ItemTotal), 0) INTO v_total_calc
        FROM LIGNECOMMANDE
        WHERE CommandeId = cmd.CommandeId;

        -- Mettre à jour seulement si différent
        IF cmd.PrixTotal <> v_total_calc THEN
            UPDATE COMMANDE
            SET PrixTotal = v_total_calc
            WHERE CommandeId = cmd.CommandeId;

            DBMS_OUTPUT.PUT_LINE(
                'Commande ' || cmd.CommandeId ||
                ' corrigée : ' || cmd.PrixTotal || ' → ' || v_total_calc
            );
        END IF;

    END LOOP;

    COMMIT;
END;
/


-- ============================================================
--  EXERCICE 6
--  Exercice 3 + gestion d'erreur si N > nb de commandes
-- ============================================================

DECLARE
    v_n         NUMBER := &n;
    v_nb_total  NUMBER;
    e_n_trop_grand EXCEPTION;   -- exception personnalisée

    CURSOR c_cmds IS
        SELECT CommandeId, Date_com, PrixTotal,
               ROW_NUMBER() OVER (ORDER BY Date_com DESC) AS rang
        FROM COMMANDE;
BEGIN
    -- Vérifier que N+1 <= nombre total de commandes
    SELECT COUNT(*) INTO v_nb_total FROM COMMANDE;

    IF v_n + 1 > v_nb_total THEN
        RAISE e_n_trop_grand;   -- déclencher l'exception
    END IF;

    DELETE FROM RESULTAT;

    FOR v_row IN c_cmds LOOP
        IF v_row.rang IN (v_n, v_n + 1) THEN
            INSERT INTO RESULTAT VALUES (
                v_row.CommandeId,
                'Cde ' || v_row.CommandeId || ' ' ||
                TO_CHAR(v_row.Date_com,'DD/MM/YYYY') || ' ' ||
                v_row.PrixTotal
            );
            DBMS_OUTPUT.PUT_LINE(
                'Rang ' || v_row.rang || ' : Cde ' || v_row.CommandeId
            );
        END IF;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN e_n_trop_grand THEN
        INSERT INTO RESULTAT VALUES (
            -1,
            'ERREUR : N=' || v_n || ' > nb commandes=' || v_nb_total
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('ERREUR : N trop grand (' || v_n || '). Max = ' || v_nb_total);
END;
/


-- ============================================================
--  EXERCICE 7
--  PACKAGE : procédure tri clients + fonction meilleur client
-- ============================================================

-- ---- Spécification du package ----
CREATE OR REPLACE PACKAGE pkg_clients AS

    -- Procédure : trier les clients par montant décroissant → RESULTAT
    PROCEDURE tri_clients;

    -- Fonction : retourner l'ID du client avec le plus grand total
    FUNCTION meilleur_client RETURN NUMBER;

END pkg_clients;
/

-- ---- Corps du package ----
CREATE OR REPLACE PACKAGE BODY pkg_clients AS

    PROCEDURE tri_clients IS
    BEGIN
        DELETE FROM RESULTAT;

        -- Curseur trié par montant total décroissant
        FOR rec IN (
            SELECT c.ClientId,
                   NVL(SUM(cmd.PrixTotal), 0) AS Total
            FROM CLIENT c
            LEFT JOIN COMMANDE cmd ON c.ClientId = cmd.ClientId
            GROUP BY c.ClientId
            ORDER BY Total DESC
        ) LOOP
            INSERT INTO RESULTAT VALUES (
                rec.ClientId,
                'Client ' || rec.ClientId || ' Total:' || rec.Total
            );
        END LOOP;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Tri terminé. Voir table RESULTAT.');
    END tri_clients;

    FUNCTION meilleur_client RETURN NUMBER IS
        v_clientId NUMBER;
    BEGIN
        SELECT ClientId INTO v_clientId
        FROM (
            SELECT ClientId, SUM(PrixTotal) AS Total
            FROM COMMANDE
            GROUP BY ClientId
            ORDER BY Total DESC
        )
        WHERE ROWNUM = 1;

        RETURN v_clientId;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END meilleur_client;

END pkg_clients;
/

-- Appels du package
BEGIN
    pkg_clients.tri_clients;
    DBMS_OUTPUT.PUT_LINE('Meilleur client ID : ' || pkg_clients.meilleur_client);
END;
/


-- ============================================================
--  CONTROLE D'INTEGRITE (TRIGGERS)
-- ============================================================

-- -------------------------------------------------------
-- Contrainte 1 : CommandeId et ItemId entre 1 et 999, NOT NULL
-- -------------------------------------------------------
-- Déjà gérable via CHECK + NOT NULL à la création :
ALTER TABLE COMMANDE ADD CONSTRAINT chk_cmdId
    CHECK (CommandeId BETWEEN 1 AND 999);

ALTER TABLE LIGNECOMMANDE ADD CONSTRAINT chk_itemId
    CHECK (ItemId BETWEEN 1 AND 999);

-- -------------------------------------------------------
-- Contrainte 2 : Nationalité ∈ {FR,GB,D,E,B}
--               + si FR → Adresse NOT NULL
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_client_nationalite
BEFORE INSERT OR UPDATE ON CLIENT
FOR EACH ROW
BEGIN
    -- Vérifier les valeurs autorisées
    IF :NEW.Nationalite NOT IN ('FR','GB','D','E','B') THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Nationalité invalide. Valeurs : FR, GB, D, E, B');
    END IF;

    -- Si français → adresse obligatoire
    IF :NEW.Nationalite = 'FR' AND :NEW.Adresse IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Un client français doit avoir une adresse.');
    END IF;
END;
/

-- -------------------------------------------------------
-- Contrainte 3 : CommandeId = max(CommandeId) + 1
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_commande_autoincrement
BEFORE INSERT ON COMMANDE
FOR EACH ROW
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(CommandeId), 0) INTO v_max FROM COMMANDE;

    IF :NEW.CommandeId <> v_max + 1 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'CommandeId doit être ' || (v_max + 1) ||
            ', pas ' || :NEW.CommandeId);
    END IF;
END;
/

-- -------------------------------------------------------
-- Contrainte 4 : une ville → un seul département
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_ville_departement
BEFORE INSERT OR UPDATE ON CLIENT
FOR EACH ROW
DECLARE
    v_dept CLIENT.Departement%TYPE;
BEGIN
    BEGIN
        SELECT DISTINCT Departement INTO v_dept
        FROM CLIENT
        WHERE Ville = :NEW.Ville
          AND Departement IS NOT NULL
          AND ROWNUM = 1;

        IF v_dept <> :NEW.Departement THEN
            RAISE_APPLICATION_ERROR(-20004,
                'La ville ' || :NEW.Ville ||
                ' est déjà associée au département ' || v_dept);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;  -- ville inconnue, ok
    END;
END;
/

-- -------------------------------------------------------
-- Contrainte 5 : dates de commandes croissantes
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_date_croissante
BEFORE INSERT ON COMMANDE
FOR EACH ROW
DECLARE
    v_max_date DATE;
BEGIN
    SELECT MAX(Date_com) INTO v_max_date FROM COMMANDE;

    IF v_max_date IS NOT NULL AND :NEW.Date_com < v_max_date THEN
        RAISE_APPLICATION_ERROR(-20005,
            'La date doit être >= ' || TO_CHAR(v_max_date,'DD/MM/YYYY'));
    END IF;
END;
/

-- -------------------------------------------------------
-- Contrainte 6 : PrixTotal recalculé auto depuis LigneCommande
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_update_prixtotal
AFTER INSERT OR UPDATE OR DELETE ON LIGNECOMMANDE
FOR EACH ROW
DECLARE
    v_cmdId NUMBER;
BEGIN
    -- Récupérer l'ID de commande concerné
    IF DELETING THEN
        v_cmdId := :OLD.CommandeId;
    ELSE
        v_cmdId := :NEW.CommandeId;
    END IF;

    -- Recalculer et mettre à jour PrixTotal
    UPDATE COMMANDE
    SET PrixTotal = (
        SELECT NVL(SUM(ItemTotal), 0)
        FROM LIGNECOMMANDE
        WHERE CommandeId = v_cmdId
    )
    WHERE CommandeId = v_cmdId;
END;
/

-- -------------------------------------------------------
-- Contrainte 7 : remise 10% si PrixTotal >= seuil donné
-- -------------------------------------------------------
-- (seuil = 500 dans cet exemple, à adapter)
CREATE OR REPLACE TRIGGER trg_remise
BEFORE INSERT ON COMMANDE
FOR EACH ROW
DECLARE
    v_seuil NUMBER := 500;
BEGIN
    IF :NEW.PrixTotal >= v_seuil THEN
        :NEW.PrixTotal := :NEW.PrixTotal * 0.90;
        DBMS_OUTPUT.PUT_LINE('Remise 10% appliquée.');
    END IF;
END;
/

-- -------------------------------------------------------
-- Contrainte 8 : empêcher suppression client avec commandes
--               + CASCADE UPDATE sur ClientId
-- -------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_no_delete_client
BEFORE DELETE ON CLIENT
FOR EACH ROW
DECLARE
    v_nb NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_nb
    FROM COMMANDE
    WHERE ClientId = :OLD.ClientId;

    IF v_nb > 0 THEN
        RAISE_APPLICATION_ERROR(-20008,
            'Impossible de supprimer le client ' ||
            :OLD.ClientId || ' : il a ' || v_nb || ' commande(s).');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_cascade_update_client
AFTER UPDATE OF ClientId ON CLIENT
FOR EACH ROW
BEGIN
    UPDATE COMMANDE
    SET ClientId = :NEW.ClientId
    WHERE ClientId = :OLD.ClientId;
END;
/

-- -------------------------------------------------------
-- Contrainte 9 : journal d'activité (INSERT/UPDATE/DELETE)
--               sur COMMANDE et PRODUIT
-- -------------------------------------------------------

-- Table de log
CREATE TABLE JOURNAL_ACTIVITE (
    Table_name  VARCHAR(20),
    Nb_Insert   NUMBER DEFAULT 0,
    Nb_Update   NUMBER DEFAULT 0,
    Nb_Delete   NUMBER DEFAULT 0
);
INSERT INTO JOURNAL_ACTIVITE VALUES ('COMMANDE', 0, 0, 0);
INSERT INTO JOURNAL_ACTIVITE VALUES ('PRODUIT',  0, 0, 0);
COMMIT;

-- Trigger sur COMMANDE
CREATE OR REPLACE TRIGGER trg_journal_commande
AFTER INSERT OR UPDATE OR DELETE ON COMMANDE
BEGIN
    IF INSERTING THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Insert = Nb_Insert + 1
        WHERE Table_name = 'COMMANDE';
    ELSIF UPDATING THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Update = Nb_Update + 1
        WHERE Table_name = 'COMMANDE';
    ELSIF DELETING THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Delete = Nb_Delete + 1
        WHERE Table_name = 'COMMANDE';
    END IF;
END;
/

-- Trigger sur PRODUIT
CREATE OR REPLACE TRIGGER trg_journal_produit
AFTER INSERT OR UPDATE OR DELETE ON PRODUIT
BEGIN
    IF INSERTING THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Insert = Nb_Insert + 1
        WHERE Table_name = 'PRODUIT';
    ELSIF UPDATING THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Update = Nb_Update + 1
        WHERE Table_name = 'PRODUIT';
    ELSIF DELETING THEN
        UPDATE JOURNAL_ACTIVITE SET Nb_Delete = Nb_Delete + 1
        WHERE Table_name = 'PRODUIT';
    END IF;
END;
/

-- Vérifier le journal
SELECT * FROM JOURNAL_ACTIVITE;

-- ============================================================
--  FIN DU SCRIPT
-- ============================================================
