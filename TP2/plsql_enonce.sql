-- ============================================================
--  TP PL/SQL + CONTROLE D'INTEGRITE -- ENONCE
--  LSIN513 - Base de Données
-- ============================================================


-- ============================================================
--  EXERCICE PRELIMINAIRE
-- ============================================================
-- Créer une table RESULTAT ayant la structure suivante :
-- Resultat (Code Number, Message varchar(40))



-- ============================================================
--  EXERCICE 1
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- a) demande l'identifiant d'un client
-- b) insère un tuple dans RESULTAT et l'affiche :
--    - 'pas de commandes'              si aucune commande pour ce client
--    - 'il y a n commande pour le client X'  sinon (n = nb commandes, X = nom)



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



-- ============================================================
--  EXERCICE 3
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- - demande un entier n à l'utilisateur
-- - insère dans RESULTAT la nième et la (n+1)ième commandes
--   les plus récentes (CommandeId, Date, PrixTotal)
-- - affiche ces deux commandes



-- ============================================================
--  EXERCICE 4
-- ============================================================
-- Ecrire un bloc PL/SQL utilisant un curseur paramétré qui :
-- - pour chaque commande, vérifie que PrixTotal = SUM(ItemTotal)
-- - insère dans RESULTAT une ligne de la forme :
--   'Cde : 100 Prix Total : 5000 Prix Total Calculé : 5000'



-- ============================================================
--  EXERCICE 5
-- ============================================================
-- Ecrire un bloc PL/SQL qui :
-- - parcourt toutes les commandes
-- - corrige PrixTotal quand il est différent de SUM(ItemTotal)



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
