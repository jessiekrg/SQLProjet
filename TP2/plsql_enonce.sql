-- ============================================================
--  TP PL/SQL + CONTROLE D'INTEGRITE -- ENONCE
--  LSIN513 - Base de Données
-- ============================================================


-- ============================================================
--  EXERCICE PRELIMINAIRE
-- ============================================================
-- Créer une table RESULTAT ayant la structure suivante :
-- Resultat (Code Number, Message varchar(40))

DROP TABLE RESULTAT
CREATE TABLE RESULTAT(
    CODE NUMBER,
    MESSAGE VARCHAR(40)
);


-- ============================================================
--  EXERCICE 1
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- a) demande l'identifiant d'un client
-- b) insère un tuple dans RESULTAT et l'affiche :
--    - 'pas de commandes'              si aucune commande pour ce client
--    - 'il y a n commande pour le client X'  sinon (n = nb commandes, X = nom)

-- DECLARE  → variables
-- BEGIN    → corps du programme
-- EXCEPTION → gestion des erreurs
-- END;

DECLARE 
    N NUMBER;
    ID NUMBER := &CLIENTID;
    MESSAGE VARCHAR(40);

BEGIN 
    SELECT COUNT(CommandeId) INTO N
    FROM COMMANDE
    WHERE CLIENTID = ID;
    
    IF N = 0 THEN 
        MESSAGE := 'PAS DE COMMANDES';
    ELSE
        MESSAGE := 'IL Y A ' || N || ' COMMANDES POUR LE CLIENT' || ID ;
    END IF;

    INSERT INTO RESULTAT VALUES (N,MESSAGE);
    DBMS_OUTPUT.PUT_LINE(MESSAGE);

END;
/


-- ============================================================
--  EXERCICE 2
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- 1) demande l'identifiant d'un client
-- 2) affiche le montant total de ses commandes
--    et la moyenne des commandes des clients de la même ville
-- 3) met à jour ses commandes :
--    - réduction 10% si son total > moyenne de la ville
--    - réduction 5%  sinon

DECLARE  
    v_id NUMBER := &CLIENTID; 
    v_montant NUMBER;
    v_moy NUMBER;
    v_villenom VARCHAR2(40);
    v_total_final NUMBER; -- Déclaration de la variable pour le prix final

BEGIN
    -- 1. Montant total actuel du client
    SELECT SUM(PRIXTOTAL) INTO v_montant
    FROM COMMANDE
    WHERE CLIENTID = v_id;

    -- 2. Ville du client
    SELECT VILLE INTO v_villenom
    FROM CLIENT
    WHERE CLIENTID = v_id;

    -- 3. Moyenne de la ville
    SELECT AVG(temp.total_client) INTO v_moy
    FROM (
        SELECT C.CLIENTID, SUM(CO.PRIXTOTAL) as total_client
        FROM CLIENT C
        JOIN COMMANDE CO ON C.CLIENTID = CO.CLIENTID
        WHERE C.VILLE = v_villenom
        GROUP BY C.CLIENTID
    ) temp;

    -- 4. Affichage des infos avant réduction
    DBMS_OUTPUT.PUT_LINE('--- AVANT RÉDUCTION ---');
    DBMS_OUTPUT.PUT_LINE('Ville : ' || v_villenom);
    DBMS_OUTPUT.PUT_LINE('Montant initial : ' || v_montant);
    DBMS_OUTPUT.PUT_LINE('Moyenne Ville : ' || ROUND(v_moy, 2));

    -- 5. Application de la réduction
    IF v_montant > v_moy THEN
        DBMS_OUTPUT.PUT_LINE('Action : Réduction de 10% appliquée');
        UPDATE COMMANDE
        SET PRIXTOTAL = PRIXTOTAL * 0.90
        WHERE CLIENTID = v_id;
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Action : Réduction de 5% appliquée');
        UPDATE COMMANDE
        SET PRIXTOTAL = PRIXTOTAL * 0.95
        WHERE CLIENTID = v_id;
    END IF;

    -- 6. RÉCUPÉRATION ET AFFICHAGE DU PRIX FINAL
    SELECT SUM(PRIXTOTAL) INTO v_total_final
    FROM COMMANDE
    WHERE CLIENTID = v_id;

    DBMS_OUTPUT.PUT_LINE('--- RÉSULTAT FINAL ---');
    DBMS_OUTPUT.PUT_LINE('PRIX TOTAL FINAL : ' || ROUND(v_total_final, 2));

    COMMIT; -- Important pour enregistrer les changements dans la base

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : Aucune donnée pour ce client.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;
/

-- ============================================================
--  EXERCICE 3
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- - demande un entier n à l'utilisateur
-- - insère dans RESULTAT la nième et la (n+1)ième commandes
--   les plus récentes (CommandeId, Date, PrixTotal)
-- - affiche ces deux commandes

DECLARE
    N NUMBER := &E;
    CURSOR C IS
        SELECT COMMANDEID, DATE_COM, PRIXTOTAL
        FROM COMMANDE;

    V_COMMANDEID NUMBER;
    V_DATE_COM DATE;
    V_PRIXTOTAL NUMBER;
    V_MESSAGE VARCHAR(200);

BEGIN 
    OPEN C;
    LOOP 
        FETCH C INTO V_COMMANDEID, V_DATE_COM, V_PRIXTOTAL;
        
        EXIT WHEN (C%NOTFOUND or N = 1);
        N := N - 1;
    END LOOP;


    -- Si on est sorti parce qu'on a trouvé (n=1) et que le curseur a bien une ligne
    IF (C%FOUND) THEN
        V_MESSAGE := 'CDE ' || V_COMMANDEID || ' DATE : ' || V_DATE_COM || ' PRIX ' || V_PRIXTOTAL;
        INSERT INTO RESULTAT VALUES (0,V_MESSAGE);
        DBMS_OUTPUT.PUT_LINE(V_MESSAGE);

        -- On fait un FETCH de plus pour avoir la (n+1)-ième
        FETCH C INTO V_COMMANDEID, V_DATE_COM, V_PRIXTOTAL;
        IF (C%FOUND) THEN 
            V_MESSAGE := 'CDE ' || V_COMMANDEID || ' DATE : ' || V_DATE_COM || ' PRIX ' || V_PRIXTOTAL;
            INSERT INTO RESULTAT VALUES ( V_COMMANDEID, V_MESSAGE );
            DBMS_OUTPUT.put_line(V_MESSAGE);
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Erreur : Pas assez de commandes pour ce n.');
    CLOSE C;
    END IF;
    COMMIT; -- Pour enregistrer les INSERT
END;
/



-- ============================================================
--  EXERCICE 4
-- ============================================================
-- Ecrire un bloc PL/SQL utilisant un curseur paramétré qui :
-- - pour chaque commande, vérifie que PrixTotal = SUM(ItemTotal)
-- - insère dans RESULTAT une ligne de la forme :
--   'Cde : 100 Prix Total : 5000 Prix Total Calculé : 5000'

DECLARE 
    CURSOR C IS 
        SELECT LC.COMMANDEID, SUM(LC.ItemTotal) as SOMME, CO.PRIXTOTAL
        FROM LIGNECOMMANDE LC
        JOIN COMMANDE CO ON CO.COMMANDEID = LC.COMMANDEID
        GROUP BY LC.COMMANDEID, CO.PRIXTOTAL;

    V_COMMANDEID NUMBER;
    V_PRIXTOTAL  NUMBER;
    V_SOMME      NUMBER;
    V_MESSAGE    VARCHAR2(200);

BEGIN 
    OPEN C;

    LOOP 
        FETCH C INTO V_COMMANDEID, V_SOMME, V_PRIXTOTAL;
        EXIT WHEN C%NOTFOUND;

        V_MESSAGE := 'Cde : ' || V_COMMANDEID ||' Prix Total : ' || V_PRIXTOTAL ||' Prix Total Calculé : ' || V_SOMME;

        IF V_SOMME = V_PRIXTOTAL THEN 
            -- AJOUT DU "INTO" ICI
            INSERT INTO RESULTAT VALUES (V_COMMANDEID, V_MESSAGE);
            DBMS_OUTPUT.PUT_LINE('OK : ' || V_MESSAGE);
        ELSE 
            DBMS_OUTPUT.PUT_LINE('ERREUR : ' || V_MESSAGE);
            
            -- Correction du prix
            UPDATE COMMANDE
            SET PRIXTOTAL = V_SOMME
            WHERE COMMANDEID = V_COMMANDEID;

            -- On peut aussi insérer l'erreur dans RESULTAT si on veut
            INSERT INTO RESULTAT VALUES (V_COMMANDEID, 'CORRIGE : ' || V_MESSAGE);
        END IF;
    END LOOP;

    CLOSE C; -- NE PAS OUBLIER DE FERMER LE CURSEUR
    COMMIT;
END;
/




-- ============================================================
--  EXERCICE 5
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- - parcourt toutes les commandes
-- - corrige PrixTotal quand il est différent de SUM(ItemTotal)
DECLARE 
    CURSOR C IS 
        SELECT CO.COMMANDEID, CO.PRIXTOTAL
        FROM COMMANDE CO
        FOR UPDATE;
    
    V_COMMANDEID NUMBER;
    V_PRIXTOTAL NUMBER;

BEGIN
    OPEN C;

    FOR RECORD IN C LOOP

        
        BEGIN
            SELECT SUM(LC.ITEMTOTAL) INTO 
            FROM COMMANDE CO
            JOIN LIGNECOMMANDE LC ON LC.COMMANDEID = CO.COMMANDEID;
        END;

        BEGIN 
            SELECT 

        

        UPDATE COMMANDE
        SET 





-- ============================================================
--  EXERCICE 6
-- ============================================================
-- Reprendre l'exercice 3 et ajouter la gestion d'erreur :
-- - si N est strictement supérieur au nombre de commandes,
--   insérer un message d'erreur dans RESULTAT
-- Utiliser une exception personnalisée (EXCEPTION + RAISE)




-- ============================================================
--  EXERCICE 7
-- ============================================================
-- Ecrire un package contenant :
-- - une PROCEDURE qui trie les clients par montant total de commandes
--   décroissant et insère le résultat (ClientId, Total) dans RESULTAT
-- - une FUNCTION qui retourne le ClientId du client
--   ayant le montant total de commandes le plus élevé



-- ============================================================
--  CONTROLE D'INTEGRITE (TRIGGERS)
-- ============================================================

-- Contrainte 1
-- Les valeurs de CommandeId et ItemId doivent être comprises
-- entre 1 et 999 et ne peuvent pas être nulles.


-- Contrainte 2
-- Nationalité ne peut valoir que : FR, GB, D, E, B
-- Si le client est français (FR), son adresse est obligatoire.


-- Contrainte 3
-- Chaque CommandeId doit être égal au max existant + 1.
-- La première commande porte le numéro 1.


-- Contrainte 4
-- Dans la table Client, une ville correspond à un seul département.
-- Empêcher toute saisie qui violerait cette règle.


-- Contrainte 5
-- Les commandes doivent être saisies par date croissante.


-- Contrainte 6
-- PrixTotal dans Commande doit toujours être égal à SUM(ItemTotal)
-- de ses LignesCommande. Tout changement dans LigneCommande
-- doit être automatiquement répercuté dans Commande.


-- Contrainte 7
-- A la réception d'une commande, appliquer une remise de 10%
-- si le montant atteint un seuil donné.


-- Contrainte 8
-- Empêcher la suppression d'un client ayant au moins une commande.
-- Garantir que ClientId dans Commande est mis à jour
-- si ClientId dans Client est modifié.


-- Contrainte 9
-- Tracer l'activité sur les tables Commande et Produit :
-- compter le nombre d'INSERT, UPDATE et DELETE pour chacune.
-- Stocker ces informations dans une table de journal.

-- ============================================================
--  FIN DE L'ENONCE
-- ============================================================
