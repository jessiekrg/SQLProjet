-----------------------------------------------------------------------------------------
-- Examen de Base de données LSIN513
-- 10 janvier 2025
-- Tous documents autorisés – 2h
-- – Session 1 –
-----------------------------------------------------------------------------------------

-- ======================================================================================
-- DESCRIPTION DE LA BASE DE DONNÉES
-- ======================================================================================
-- La base de données ci-dessous décrit un système de gestion de projets informatiques. 
-- La table PROJET décrit les projets avec leur durée et le budget prévisionnel affecté. 
-- Le statut indique si un projet est terminé ou pas. Si non terminé sa valeur reste à NULL. 
-- Un projet est constitué d'un ensemble de tâches à réaliser. A chaque tâche correspond un 
-- nombre total d'heures à effectuer. 
-- La table EMPLOYE recense tous les employés de la boîte avec leur taux horaire. 
-- La table AFFECTATION recense toutes les affectations d'un employé sur une tâche donnée. 
-- Un employé remplit chaque semaine sa feuille de service et indique combien d'heures 
-- il a réalisé sur cette tâche.
-- Les tables ont été réduites à leur strict minimum. Les clés sont indiquées en gras.

-- ======================================================================================
-- SCHÉMA RELATIONNEL
-- ======================================================================================
-- PROJET (numproj, descriptif, date_deb, date_fin, budget, statut)
-- TACHE (idtach, numproj, nbr_heures_tot)
-- EMPLOYE (numempl, nom, prénom, age, taux_horaire)
-- AFFECTATION (jobid, numempl, idtach, numproj, datej, nb_heures)


-- ======================================================================================
-- PARTIE 1. (9p) Requêtes SQL
-- ======================================================================================

-- Q1 (2p): La table AFFECTATION a été créée mais aucune contrainte n'a été définie. 
-- Veuillez donner les commandes SQL qui permettent de rajouter toutes les contraintes 
-- clé primaire et clés étrangères.
--
ALTER TABLE AFFECTATION ADD CONSTRAINT PK1 PRIMARY KEY (jobid);
ALTER TABLE AFFECTATION ADD CONSTRAINT K1 FOREIGN KEY (numproj) REFERENCES PROJET(numproj) ON DELETE CASCADE;
ALTER TABLE AFFECTATION ADD CONSTRAINT K2 FOREIGN KEY (numempl) REFERENCES EMPLOYE(numempl) ON DELETE CASCADE;
ALTER TABLE AFFECTATION ADD CONSTRAINT K3 FOREIGN KEY (idtach,numproj) REFERENCES TACHE(idtach,numproj) ON DELETE CASCADE;


-- Q2 (2p): Donner pour chaque projet en cours (c.-à-d. ceux non terminés), le nombre de 
-- tâches et le nombre d'employés affectés au projet.

SELECT P.numproj, COUNT(DISTINCT T.idtach) AS NB_TACHE, COUNT(DISTINCT E.numempl) AS NB_E
FROM PROJET P
LEFT JOIN TACHE T ON T.numproj = P.numproj
LEFT JOIN AFFECTATION A ON A.idtach = T.idtach AND A.numproj = T.numproj -- Jointure complète !
LEFT JOIN EMPLOYE E ON E.numempl = A.numempl
WHERE P.date_fin IS NULL
GROUP BY P.numproj;

-- Q3 (3p): Trouver les employés qui ont participé à tous les projets.
--
SELECT E.numempl, E.nom
FROM EMPLOYE E
WHERE NOT EXISTS (
    SELECT P.numproj
    FROM PROJET P
    WHERE NOT EXISTS (
        SELECT *
        FROM AFFECTATION A
        WHERE A.numempl = E.numempl AND A.numproj = P.numproj
    )
);

-- Q4 (2p): Définir la vue personne_anonyme qui pour chaque employé ne retourne que la tranche 
-- d'âge à laquelle appartient l'employé. On définit uniquement 3 tranches d'âge : 20-35, 36-50, 51-65.
--

CREATE OR REPLACE VIEW personne_anonyme AS
    SELECT 
        numempl,
        CASE 
            WHEN age BETWEEN 20 AND 35 THEN '20-35'
            WHEN age BETWEEN 36 AND 50 THEN '36-50'
            WHEN age BETWEEN 51 AND 65 THEN '51-65'
            ELSE 'Hors tranche'
        END AS TrancheAge -- <-- Création de la colonne "TrancheAge"
    FROM EMPLOYE;

-- ======================================================================================
-- PARTIE 2. (6p) Définir les contraintes d'intégrité suivantes soit en SQL, soit en PL/SQL :
-- ======================================================================================

-- Q5 (2p): La date de début de projet doit toujours être inférieure à la date de fin de projet, 
-- et un projet ne peut pas excéder une durée de un an.
--
CREATE OR REPLACE TRIGGER date
BEFORE INSERT OR UPDATE ON PROJET
FOR EACH ROW 
BEGIN 
    IF :NEW.date_deb > :NEW.date_fin THEN 
        RAISE_APPLICATION_ERROR(-20031, 'DATE doit toujours être inférieure à la date de fin de projet ');
    END IF;

    IF (:NEW.date_fin - :NEW.date_deb) > 365 THEN
        RAISE_APPLICATION_ERROR(-20032, 'Projet ne peut pas excéder une durée de un an');
    END IF;
END; 

-- Q6 (2p): Un projet ne peut pas comporter plus de 10 tâches.
-
CREATE OR REPLACE TRIGGER TA
BEFORE INSERT ON TACHE
FOR EACH ROW 
DECLARE
    V_NBTACHE NUMBER;
BEGIN 
    SELECT COUNT(T.idtach) INTO V_NBTACHE
    FROM PROJET P
    JOIN TACHE T ON T.numproj = P.numproj --NOOOOO TABLE MUTANTES
    WHERE P.numproj = :NEW.numproj;

    IF V_NBTACHE >= 10 THEN 
        RAISE_APPLICATION_ERROR(-20033, 'NB PROJET DOIT ETRE INFEREIEUR À 10 ');
    END IF;
END; 

-- Q7 (2p): On ne peut pas créer une affectation si le nombre d'heures déjà affectées dépasse 
-- le nombre d'heures initialement défini pour cette tâche (nb_heures_tot).

CREATE OR REPLACE TRIGGER TA
BEFORE INSERT ON AFFECTATION 
FOR EACH ROW 
DECLARE
    V_nombre_dheures NUMBER;
BEGIN 
    SELECT SUM(nbr_heures_tot) INTO V_nombre_dheures
    FROM TACHE
    WHERE :NEW.idtach = idtach;

    IF V_nombre_dheures > :NEW.nb_heures THEN
        RAISE_APPLICATION_ERROR(-20034, 'le nombre dheures déjà affectées dépasse le nombre dheures initialement défini pour cette tâche');
    END IF;
END; 


-- ======================================================================================
-- PARTIE 3. (3p) Procédure PL/SQL
-- ======================================================================================
-- Ecrire la procédure PL/SQL qui permet de changer le statut d'un projet qui se termine. 
-- Dès qu'un projet est terminé, on regarde si le budget a été dépassé ou pas. On peut le 
-- savoir car chaque employé possède un taux horaire et a réalisé un certain nombre d'heures 
-- sur l'ensemble des tâches du projet. Si le budget est dépassé on insère un message dans 
-- une table MESSSAGE (comme vu en TP), afin que plus tard des analystes puissent en analyser 
-- les causes, sinon on change simplement le statut du projet.
--
-- Votre réponse ici...

CREATE OR REPLACE PROCEDURE STATUT IS 
 -- Y PAS DE DECLARE
    V_COUT NUMBER;
BEGIN
    FOR PRO IN (
        SELECT numproj, budget
        FROM PROJET
        WHERE TRUNC(SYSDATE) = TRUNC(date_fin)
    ) LOOP 

    SELECT NVL(SUM(E.taux_horaire * A.nb_heures)) INTO V_COUT 
    FROM EMPLOYE E
    JOIN AFFECTATION A ON A.numempl = E.numempl 
    WHERE A.numproj = PRO.numproj;

    UPDATE PROJET
    SET statut = 'termine'
    WHERE numproj = PRO.numproj ;


    IF V_COUT > PRO.budget THEN 
        INSERT INTO MESSSAGE (descriptif_erreur)
        VALUES ('Dépassement budget pour le projet ' || PRO.numproj);
    END IF;

        
    END LOOP;

    COMMIT;
END; 





-- ======================================================================================
-- PARTIE 4. (2p) Transactions
-- ======================================================================================
-- On vous demande de représenter le graphe de précédence correspondant à l'exécution de 6 
-- transactions sur les granules A, B, C et D, effectuée de la façon suivante. Que pouvez-vous en 
-- conclure ? (Ei écriture de la transaction i, Li lecture de la transaction i).
-- 
-- A : E1, L5, E2, L3
-- B : L3, L4, E1, E3
-- C : E5, L2, L6, E4
-- D : L1, L3, L4, E6
--
-- Votre réponse ici...