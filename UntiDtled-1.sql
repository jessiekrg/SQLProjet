-- ======================================================================================
-- EXAMEN DE BASE DE DONNÉES LSIN513 - 10 JANVIER 2025
-- ======================================================================================

-- PROJET (numproj, descriptif, date_deb, date_fin, budget, statut)
-- TACHE (idtach, numproj, nbr_heures_tot)
-- EMPLOYE (numempl, nom, prénom, age, taux_horaire)
-- AFFECTATION (jobid, numempl, idtach, numproj, datej, nb_heures)

-- ======================================================================================
-- PARTIE 1. (9p) Requêtes SQL
-- ======================================================================================

-- Q1 (2p) : La table AFFECTATION a été créée mais aucune contrainte n'a été définie. 
-- Veuillez donner les commandes SQL qui permettent de rajouter toutes les contraintes 
-- clé primaire et clés étrangères.
-- Votre réponse ici :

SELECT 

-- Q2 (2p) : Donner pour chaque projet en cours (c.-à-d. ceux non terminés), le nombre de 
-- tâches et le nombre d'employés affectés au projet.
-- Votre réponse ici :



-- Q3 (3p) : Trouver les employés qui ont participé à tous les projets.
-- Votre réponse ici :



-- Q4 (2p) : Définir la vue personne_anonyme qui pour chaque employé ne retourne que la 
-- tranche d'âge à laquelle appartient l'employé. On définit uniquement 3 tranches 
-- d'âge : 20-35, 36-50, 51-65.
-- Votre réponse ici :




-- ======================================================================================
-- PARTIE 2. (6p) Définir les contraintes d'intégrité (soit en SQL, soit en PL/SQL)
-- ======================================================================================

-- Q5 (2p) : La date de début de projet doit toujours être inférieure à la date de fin 
-- de projet, et un projet ne peut pas excéder une durée de un an.
-- Votre réponse ici :



-- Q6 (2p) : Un projet ne peut pas comporter plus de 10 tâches.
-- Votre réponse ici :



-- Q7 (2p) : On ne peut pas créer une affectation si le nombre d'heures déjà affectées 
-- dépasse le nombre d'heures initialement défini pour cette tâche (nbr_heures_tot).
-- Votre réponse ici :




-- ======================================================================================
-- PARTIE 3. (3p) Procédure PL/SQL
-- ======================================================================================

-- Écrire la procédure PL/SQL qui permet de changer le statut d'un projet qui se termine. 
-- Dès qu'un projet est terminé, on regarde si le budget a été dépassé ou pas. On peut le 
-- savoir car chaque employé possède un taux horaire et a réalisé un certain nombre d'heures 
-- sur l'ensemble des tâches du projet. Si le budget est dépassé on insère un message dans 
-- une table MESSSAGE (comme vu en TP), afin que plus tard des analystes puissent en analyser 
-- les causes, sinon on change simplement le statut du projet.
-- Votre réponse ici :




-- ======================================================================================
-- PARTIE 4. (2p) Transactions
-- ======================================================================================

-- On vous demande de représenter le graphe de précédence correspondant à l'exécution de 6 
-- transactions sur les granules A, B, C et D, effectuée de la façon suivante. 
-- Que pouvez-vous en conclure ? (Ei écriture de la transaction i, Li lecture de la transaction i).
--
-- A : E1, L5, E2, L3
-- B : L3, L4, E1, E3
-- C : E5, L2, L6, E4
-- D : L1, L3, L4, E6
--
-- Votre réponse ici :