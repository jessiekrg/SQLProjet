-- ======================================================================================
-- EXAMEN DE BASE DE DONNÉES - 9 JANVIER 2026
-- TOUS DOCUMENTS AUTORISÉS - 2H
-- ======================================================================================

-- PERSONNE    (N°PERS, NOM, PRENOM)
-- PERMIS      (N°PERS, DATE_PERMIS, CATEGORIE)
-- VEHICULE    (N°VEH, NOM, MARQUE, CATEGORIE, COULEUR)
-- CARTEGRISE  (N°VEH, N°PERS, DATE_IMMA)
-- ACCIDENT    (N°ACC, A_DATE, CODE_POSTAL, ADRESSE, N°VEH)
-- BLESSÉ      (N°ACC, N°PERS, GRAVITE)

-- Notes de l'énoncé :
-- * CATEGORIE de permis : 'A' = moto, 'B' = voiture, 'C' = véhicule de transport.
-- * Une personne peut avoir plusieurs permis de conduire.
-- * L'attribut N°VEH dans ACCIDENT peut être null (accident sans véhicule impliqué).
-- * GRAVITE prend ses valeurs dans : {'indemne', 'léger', 'sérieux', 'grave', 'mortel'}.

-- ======================================================================================
-- PARTIE 1 : Requêtes et Vues SQL
-- ======================================================================================

-- Question 1 : (3 points)
-- On suppose que le schéma de la base de données de la sécurité routière a déjà été créé,
-- toutes les clés primaires et les clés étrangères ont été exprimées. Maintenant on souhaite
-- rajouter les contraintes d'intégrité simples de l'énoncé ci-dessus, c'est-à-dire celles
-- que l'on peut exprimer avec un CHECK.
-- Veuillez écrire en SQL, la séquence de contraintes simples à ajouter sur le schéma existant.
-- Votre réponse ici :

ALTER TABLE PERMIS
ADD CONSTRAINT CK
CHECK (CATEGORIE IN ('A', 'B', 'C'));

ALTER TABLE ACCIDENT 
MODIFY ( N°VEH NULL );

ALTER TABLE BLESSÉ
ADD CONSTRAINT CK3
CHECK (GRAVITE IN ('indemne', 'léger', 'sérieux', 'grave', 'mortel'));


-- Question 2 : (2 points)
-- Définir en SQL, la vue bons_conducteurs, c'est-à-dire retrouver le nom et le prénom des
-- personnes n'ayant jamais eu d'accidents.
-- Votre réponse ici :

CREATE VIEW bons_conducteurs AS
    SELECT P.NOM, P.PRENOM
    FROM PERSONNE P
    WHERE NOT EXISTS (
        SELECT *
        FROM BLESSÉ B
        WHERE B.N°PERS = P.N°PERS
    );

OU 

CREATE VIEW bons_conducteurs AS
    SELECT P.NOM, P.PRENOM
    FROM PERSONNE P
    WHERE P.N°PERS NOT IN (
        SELECT B.N°PERS -- DOIT RENVOYER UNE SEULE COLONNE 
        FROM BLESSÉ B
    );

-- Question 3 : (2 points)
-- Ecrire la requête SQL qui indique pour chaque département le nombre total d'accidents et le
-- nombre de morts pour l'année 2018.
-- (Aide : Le département correspond généralement aux 2 premiers chiffres du CODE_POSTAL).
-- Votre réponse ici :

SELECT SUBSTR(A.CODE_POSTAL, 1, 2) AS DEPT, 
    COUNT(DISTINCT A.N°ACC) AS NB_A, 
    COUNT(CASE WHEN B.GRAVITE = 'mortel' THEN 1 END) AS NB_MORT
FROM ACCIDENT A
LEFT JOIN BLESSÉ B ON A.N°ACC = B.N°ACC
WHERE A.A_DATE BETWEEN TO_DATE('01-JAN-2018','DD-MON-YYYY') AND TO_DATE('31-DEC-2018','DD-MON-YYYY')
GROUP BY SUBSTR(A.CODE_POSTAL, 1, 2);

-- Question 4 : (2 points)
-- Ecrire la requête SQL, qui indique pour chaque personne le nombre d'accidents qu'ils ont eu au
-- cours de leur vie. Fort heureusement certaines personnes n'ont jamais eu d'accidents.
-- Votre réponse ici : goood

SELECT P.N°PERS, COUNT(DISTINCT B.N°ACC) AS NB_ACC
FROM PERSONNE P
LEFT JOIN BLESSÉ B ON B.N°PERS = P.N°PERS
GROUP BY P.N°PERS;


-- Question 5 : (2 points)
-- Ecrire la requête SQL, qui retrouve les personnes qui ont eu plus de 3 accidents au cours de leur
-- vie, trier par numéro de personne croissant.
-- Votre réponse ici :

SELECT P.N°PERS, COUNT(DISTINCT B.N°ACC) AS NB_ACC
FROM PERSONNE P
JOIN BLESSÉ B ON B.N°PERS = P.N°PERS 
GROUP BY P.N°PERS 
HAVING COUNT(DISTINCT B.N°ACC) > 3
ORDER BY P.N°PERS ASC ;


-- ======================================================================================
-- PARTIE 2 : Triggers PL/SQL
-- ======================================================================================

-- Question 6 : (3 points)
-- Écrire le trigger qui permet de vérifier que seules les personnes possédant un permis de
-- conduire approprié pour le bon type de véhicule peuvent posséder une carte grise sur ce
-- véhicule.
-- Votre réponse ici :

CREATE OR REPLACE TRIGGER tg_verif_permis_direct
BEFORE INSERT OR UPDATE ON CARTEGRISE
FOR EACH ROW 
DECLARE 
    v_cat_vehicule VEHICULE.CATEGORIE%TYPE;
BEGIN 
    -- 1. On récupère d'abord la catégorie du véhicule
    SELECT CATEGORIE INTO v_cat_vehicule
    FROM VEHICULE
    WHERE N°VEH = :NEW.N°VEH;

    -- 2. On vérifie directement si cette catégorie n'est PAS dans les permis de la personne
    IF v_cat_vehicule NOT IN (
        SELECT P.CATEGORIE 
        FROM PERMIS P
        WHERE P.N°PERS = :NEW.N°PERS
    ) THEN 
        RAISE_APPLICATION_ERROR(-20080, 'Interdit : La personne ne possède pas le permis adapté.');
    END IF;
END;
/

-- PERSONNE    (N°PERS, NOM, PRENOM)
-- PERMIS      (N°PERS, DATE_PERMIS, CATEGORIE)
-- VEHICULE    (N°VEH, NOM, MARQUE, CATEGORIE, COULEUR)
-- CARTEGRISE  (N°VEH, N°PERS, DATE_IMMA)
-- ACCIDENT    (N°ACC, A_DATE, CODE_POSTAL, ADRESSE, N°VEH)
-- BLESSÉ      (N°ACC, N°PERS, GRAVITE)

-- Question 7 : (3 points)
-- Écrire le trigger qui permet de vérifier qu'une personne qui est morte dans un accident ne peut
-- plus être blessée à nouveau.
-- Votre réponse ici :

CREATE OR REPLACE TRIGGER V
AFTER INSERT OR UPDATE ON BLESSÉ -- 1. Correction de UPDTAE
DECLARE                         -- <-- Attention, ne pas oublier le mot-clé DECLARE
    V_NB_ACC NUMBER;
BEGIN 
    SELECT COUNT(*) INTO V_NB_ACC
    FROM BLESSÉ B1
    JOIN ACCIDENT A1 ON B1.N°ACC = A1.N°ACC
    WHERE B1.GRAVITE = 'mortel' 
      AND EXISTS (
        SELECT 1 -- Un simple "1" ou "*" suffit ici
        FROM BLESSÉ B2
        JOIN ACCIDENT A2 ON B2.N°ACC = A2.N°ACC
        WHERE B1.N°PERS = B2.N°PERS     -- 2. On vérifie que c'est la MÊME personne
          AND A2.A_DATE > A1.A_DATE     -- 3. Qui a un autre accident APRÈS la date du décès
    );

    IF V_NB_ACC > 0 THEN
        RAISE_APPLICATION_ERROR(-20078, 'Erreur : Une personne ne peut pas être blessée dans un accident postérieur à son décès.');
    END IF;
END;
/



-- ======================================================================================
-- PARTIE 3 : TRANSACTIONS (3 p)
-- ======================================================================================

-- Q1 (2p). On vous demande de représenter le graphe de précédence correspondant à l'exécution
-- de 6 transactions sur les granules A, B, C et D, effectuée de la façon suivante. Que pouvez-vous
-- en conclure ? (Ei écriture de la transaction i, Li lecture de la transaction i).
--
-- A : E1, L5, E2, L3
-- B : L3, L4, E1, E3
-- C : E5, L2, L6, E4
-- D : L1, E3, L4, E6
--
-- Votre réponse ici :



-- Q2 (1p). Dans le protocole de concurrence par verrouillage, à quoi correspond le 2PL (2 phase
-- locking) ?
-- Votre réponse ici :