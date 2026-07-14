-----------------------------------------------------------------------------------------
-- UVSQ, Université Paris-Saclay
-- Année universitaire 2021-2022
-- LSIN408 - Introduction aux Bases de Données
-- Sujet d'examen - 16 mai 2022
-----------------------------------------------------------------------------------------

-- ======================================================================================
-- SCHÉMA RELATIONNEL DE LA BASE DE DONNÉES
-- ======================================================================================
-- AGENCE (N°AG, Nom, Adresse, Ville, Pays)
-- VEHICULE (N°VEH, Marque, Modele, Annee, Kilometrage, Couleur, N°AG)
-- CLIENT (N°CL, Nom, Prenom, DateNaiss, Pays)
-- LOCATION (N°LOC, N°CL, N°VEH, DateDepart, N°AG_Depart, DateRetour, N°AG_Retour)

-- ======================================================================================
-- PARTIE I : MODÈLES ENTITÉ/ASSOCIATION ET RELATIONNEL
-- ======================================================================================

-- Question 1.1 (1pt) : 
-- Indiquer les clés étrangères dans ces relations, pour que le modèle soit cohérent.
-- Notation : TableA.CléEtrangère -> TableB.AttributRéférencé
-- 
-- Votre réponse ici...


-- Question 1.3 (1pt) : 
-- Donner la requête SQL permettant de créer la table VEHICULE et ses contraintes d'intégrités 
-- (c.à.d., clés primaire et étrangères). On suppose que les tables AGENCE et CLIENT sont déjà créées.
-- 
-- Votre réponse ici...


-- Question 1.4 (1pt) : 
-- Donner la requête SQL permettant de mettre à jour le contenu de la table VEHICULE suite au retour 
-- du véhicule numéro 42 dans l'agence numéro 343 en supposant qu'elle est différente de l'agence de départ.
-- 
-- Votre réponse ici...


-- ======================================================================================
-- PARTIE II : ALGÈBRE RELATIONNELLE
-- ======================================================================================

-- Question 2.1 (1pt) : 
-- Afficher le nom et l'adresse des agences de la Adresse de Pau en France.
--
SELECT A.Nom, A.Adresse
FROM AGENCE A 
WHERE Ville = 'Pau' AND Pays = 'France';

-- Question 2.2 (1pt) : 
-- Afficher le modèle, l'année et le kilométrage des véhicules de marque Renault disponibles dans les agences à Lille.
--
SELECT V.Modele, V.Annee, V.Kilometrage
FROM VEHICULE V 
JOIN AGENCE A ON A.N°AG = V.N°AG
WHERE V.Marque = 'Renault' AND A.Ville = 'Lille';

-- Question 2.3 (2pt) : 
-- Afficher le numéro, le nom et le prénom des clients qui n'ont loué que des véhicules de la marque Citroën.
-- Question 2.3 (2pt) : 
-- Afficher le numéro, le nom et le prénom des clients qui n'ont loué que des véhicules de la marque Citroën[cite: 29].
SELECT CL.N°CL, CL.Nom, CL.Prenom [cite: 8]
FROM CLIENT CL [cite: 8]
WHERE NOT EXISTS (
    SELECT *
    FROM LOCATION L
    JOIN VEHICULE V ON L.N°VEH = V.N°VEH -- On relie la location au véhicule 
    WHERE L.N°CL = CL.N°CL               -- On cible les locations DU client actuel 
      AND V.Marque <> 'Citroën'          -- On cherche s'il a loué une AUTRE marque [cite: 8]
) 
AND EXISTS ( 
    SELECT *
    FROM LOCATION LOC
    WHERE LOC.N°CL = CL.N°CL             -- Attention à la faute de frappe (LOC et non L) 
);

-- « Affiche-moi les clients qui ont loué tous les véhicules de la marque Citroën. »
SELECT CL.N°CL, CL.Nom, CL.Prenom
FROM CLIENT CL 
WHERE NOT EXISTS (
    SELECT V.N°VEH
    FROM VEHICULE V
    WHERE V.marque = 'Citroën'
    WHERE NOT EXISTS (
        SELECT *
        FROM LOCATION L
        WHERE L.N°VEH = V.N°VEH AND L.N°CL = CL.N°CL
    )
);

-- ======================================================================================
-- PARTIE III : REQUÊTES SQL
-- ======================================================================================

-- Question 3.1 (2pts) : 
-- Afficher le nom et le prénom des clients belges qui ont fait des locations dont la date de départ 
-- est en 2021 dans des agences situées à Amsterdam de véhicules de la marque Audi.
--
SELECT CL.nom, CL.Prenom
FROM CLIENT CL
JOIN LOCATION L ON L.N°CL = CL.N°CL
JOIN AGENCE A ON A.N°AG_Depart = L.N°AG
JOIN VEHICULE V ON V.N°VEH = L.N°VEH
WHERE A.Ville = 'Amsterdam' AND V.marque = 'Audi' AND CL.Pays = 'belgIQUE';

-- Question 3.2 (2pts) : 
-- Afficher le nom et le prénom des clients qui ont loué des véhicules dans des agences à Milan et à Lisbonne.
--
SELECT CL.nom, CL.Prenom
FROM CLIENT CL
JOIN LOCATION L ON L.N°CL = CL.N°CL
JOIN AGENCE A ON A.N°AG_Depart = L.N°AG
JOIN VEHICULE V ON V.N°VEH = L.N°VEH
WHERE A.Ville IN ('Milan','Lisbonne');

-- Question 3.3 (2pts) : 
-- Afficher pour chaque véhicule son numéro, son nombre de locations ainsi que le nombre de clients 
-- différents qui l'ont loué. Afficher l'ensemble des véhicules, y compris ceux qui n'ont pas été loués.
--

SELECT
FROM VEHICULE V
JOIN LOCATION L ON 


-- Question 3.4 (2pts) : 
-- Afficher le nom et le prénom des clients qui ont fait des locations dans toutes les agences situées à Londres.
--
-- Votre réponse ici...


-- Question 3.5 (2pts) : 
-- Définir la vue Rapport_Retours qui donne le rapport entre le nombre de locations pour lesquelles 
-- le retour se fait dans l'agence de départ et le nombre de locations pour lesquelles le retour 
-- se fait dans une agence différente de l'agence de départ.
--
-- Votre réponse ici...