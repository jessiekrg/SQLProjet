-----------------------------------------------------------------------------------------
-- M2106 - Programmation et administration des bases de données
-- ED PL/SQL (Université Paris-Saclay / UVSQ)
-- SCRIPT DE CRÉATION DES TABLES & ÉNONCÉS DES EXERCICES
-----------------------------------------------------------------------------------------

-- ======================================================================================
-- PARTIE 1 : RÉINITIALISATION & CRÉATION DES TABLES DE L'ED
-- ======================================================================================

-- Suppression propre des tables existantes (pour éviter les conflits lors des lancements)
DROP TABLE TRACK_ABONNEMENTS CASCADE CONSTRAINTS;
DROP TABLE ABONNEMENT CASCADE CONSTRAINTS;
DROP TABLE MAGAZINE CASCADE CONSTRAINTS;
DROP TABLE CLIENT CASCADE CONSTRAINTS;
DROP TABLE SCORE CASCADE CONSTRAINTS;
DROP TABLE PARTICIPANT CASCADE CONSTRAINTS;
DROP TABLE COMPETITION CASCADE CONSTRAINTS;
DROP TABLE METEO CASCADE CONSTRAINTS;
DROP TABLE EMPLOYE CASCADE CONSTRAINTS;
DROP TABLE PARTITION CASCADE CONSTRAINTS;
DROP TABLE DISQUE CASCADE CONSTRAINTS;
DROP TABLE PILOTE CASCADE CONSTRAINTS;
DROP TABLE RES CASCADE CONSTRAINTS;
DROP TABLE ESCALES CASCADE CONSTRAINTS;
DROP TABLE VOL CASCADE CONSTRAINTS;

-- 1. Table VOL (Exercices 1, 18, 19, 20)
CREATE TABLE VOL (
    Numvol         VARCHAR2(10) NOT NULL,
    Heure_départ   DATE,
    Heure_arrivée  DATE,
    Ville_départ   VARCHAR2(100),
    Ville_arrivée  VARCHAR2(100),
    CONSTRAINT PK_VOL PRIMARY KEY (Numvol)
);

-- 2. Table RES (Exercice 2)
CREATE TABLE RES (
    NO NUMBER(5) NOT NULL
);

-- 3. Table PILOTE (Exercice 7)
CREATE TABLE PILOTE (
    Matricule VARCHAR2(10) NOT NULL,
    Nom       VARCHAR2(100),
    Ville     VARCHAR2(100),
    Age       NUMBER(3),
    Salaire   NUMBER(11,2),
    CONSTRAINT PK_PILOTE PRIMARY KEY (Matricule)
);

-- 4. Tables DISQUE & PARTITION (Exercice 8)
CREATE TABLE DISQUE (
    nom       VARCHAR2(100) NOT NULL,
    capacité  NUMBER(10),
    vitesse   NUMBER(10),
    fabricant VARCHAR2(100),
    CONSTRAINT PK_DISQUE PRIMARY KEY (nom)
);

CREATE TABLE PARTITION (
    nomDisque    VARCHAR2(100) NOT NULL,
    nomPartition VARCHAR2(100) NOT NULL,
    taille       NUMBER(10),
    CONSTRAINT PK_PARTITION PRIMARY KEY (nomDisque, nomPartition),
    CONSTRAINT FK_PARTITION_DISQUE FOREIGN KEY (nomDisque) REFERENCES DISQUE(nom)
);

-- 5. Table EMPLOYE (Exercices 9, 10, 11)
CREATE TABLE EMPLOYE (
    ID          NUMBER(10) NOT NULL,
    NOM         VARCHAR2(100),
    DEPARTEMENT VARCHAR2(100),
    AGE         NUMBER(3),
    SALAIRE     NUMBER(11,2),
    CONSTRAINT PK_EMPLOYE PRIMARY KEY (ID)
);

-- 6. Table METEO (Exercices 12, 13)
CREATE TABLE METEO (
    NOM_VILLE   VARCHAR2(100) NOT NULL,
    Température NUMBER(4,1),
    Humidité    NUMBER(3),
    CONSTRAINT PK_METEO PRIMARY KEY (NOM_VILLE)
);

-- 7. Tables COMPETITION, PARTICIPANT & SCORE (Exercices 14, 15)
CREATE TABLE COMPETITION (
    CODE_COMP       VARCHAR2(10) NOT NULL,
    NOM_COMPETITION VARCHAR2(100),
    CONSTRAINT PK_COMPETITION PRIMARY KEY (CODE_COMP)
);

CREATE TABLE PARTICIPANT (
    NO_PART       NUMBER(10) NOT NULL,
    NOM_PART      VARCHAR2(100),
    DATENAISSANCE DATE,
    ADRESSE       VARCHAR2(255),
    EMAIL         VARCHAR2(100),
    CONSTRAINT PK_PARTICIPANT PRIMARY KEY (NO_PART)
);

CREATE TABLE SCORE (
    NO_PAR    NUMBER(10) NOT NULL,
    CODE_COMP VARCHAR2(10) NOT NULL,
    NO_JUGE   NUMBER(5) NOT NULL,
    NOTE      NUMBER(4,2),
    CONSTRAINT PK_SCORE PRIMARY KEY (NO_PAR, CODE_COMP, NO_JUGE),
    CONSTRAINT FK_SCORE_PART FOREIGN KEY (NO_PAR) REFERENCES PARTICIPANT(NO_PART),
    CONSTRAINT FK_SCORE_COMP FOREIGN KEY (CODE_COMP) REFERENCES COMPETITION(CODE_COMP)
);

-- 8. Tables CLIENT, MAGAZINE, ABONNEMENT & TRACK_ABONNEMENTS (Exercices 16, 17)
CREATE TABLE CLIENT (
    CL_ID      NUMBER(10) NOT NULL,
    CL_NOM     VARCHAR2(100),
    CL_ADDR    VARCHAR2(255),
    CL_VILLE   VARCHAR2(100),
    EMAILID    VARCHAR2(100),
    CONTACT_NO VARCHAR2(20),
    CONSTRAINT PK_CLIENT PRIMARY KEY (CL_ID)
);

CREATE TABLE MAGAZINE (
    MAG_ID           NUMBER(10) NOT NULL,
    MAG_NOM          VARCHAR2(100),
    PRIX_UNITE       NUMBER(11,2),
    TYPE_ABONNEMENT  VARCHAR2(50),
    CONSTRAINT PK_MAGAZINE PRIMARY KEY (MAG_ID)
);

CREATE TABLE ABONNEMENT (
    CL_ID      NUMBER(10) NOT NULL,
    MAG_ID     NUMBER(10) NOT NULL,
    START_DATE DATE NOT NULL,
    END_DATE   DATE,
    CONSTRAINT PK_ABONNEMENT PRIMARY KEY (CL_ID, MAG_ID, START_DATE),
    CONSTRAINT FK_ABONN_CL FOREIGN KEY (CL_ID) REFERENCES CLIENT(CL_ID),
    CONSTRAINT FK_ABONN_MAG FOREIGN KEY (MAG_ID) REFERENCES MAGAZINE(MAG_ID)
);

CREATE TABLE TRACK_ABONNEMENTS (
    MAG_NOM  VARCHAR2(100) NOT NULL,
    NB_ABONN INTEGER DEFAULT 0,
    CONSTRAINT PK_TRACK_ABONN PRIMARY KEY (MAG_NOM)
);

-- 9. Table ESCALES (Exercices 18, 19)
CREATE TABLE ESCALES (
    Numescale    NUMBER(5) NOT NULL,
    Ville_escale VARCHAR2(100),
    Duree_escale NUMBER(5),
    CONSTRAINT PK_ESCALES PRIMARY KEY (Numescale)
);


-- ======================================================================================
-- PARTIE 2 : ÉNONCÉS DES EXERCICES (À COMPLÉTER)
-- ======================================================================================

-- --------------------------------------------------------------------------------------
-- Exercice 1.
-- Écrivez un programme PL/SQL qui insère le vol AF110 partant de Paris à 21h40 et arrivant à 
-- Dublin à 23h10 (hypothèse : le vol n'est pas déjà présent dans la table).
-- --------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------
-- Exercice 2.
-- Soit la table RES(NO). Écrivez un bloc PL/SQL qui insère les chiffres de 1 à 100 dans cette table.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 3.
-- Écrivez un bloc PL/SQL qui affiche la somme des nombres entre 1000 et 10000.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 4.
-- Écrivez un programme PL/SQL qui affiche le reste de la division de 17664 par 171.
-- Ne pas utilisez la fonction MOD.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 5.
-- Créez une type tableau pouvant contenir jusqu'à 50 entiers.
-- 1. Créez une variable de ce type, faites une allocation dynamique et dimensionnez ce 
--    tableau à 20 emplacements.
-- 2. Placez dans ce tableau la liste des 20 premiers carrés parfaits : 1, 4, 9, 16, 25, ...
-- 3. Affichez ce tableau.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 6.
-- Écrire une fonction PL/SQL qui prend en entrée un nombre entier n et retourne le 
-- factoriel de ce nombre n!. Implémenter deux versions : itérative et récursive. 
-- La version récursive est basée sur la relation de récurrence : n! = n * (n-1)!
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 7.
-- Écrivez un programme PL/SQL qui calcule la moyenne des salaires des pilotes dont l'âge 
-- est entre 30 et 40 ans.
-- Table : PILOTE(Matricule, Nom, Ville, Age, Salaire).
-- --------------------------------------------------------------------------------------

DECLARE
    CURSOR C IS 
        SELECT 
BEGIN
END;
/


-- --------------------------------------------------------------------------------------
-- Exercice 8.
-- Écrivez en PL/SQL le déclencheur (trigger) qui lors de l'insertion d'une nouvelle ligne 
-- dans la table PARTITION vérifie que la taille totale des partitions sur le disque concerné 
-- (y compris la partition qui est en cours d'être ajoutée) ne dépasse pas la capacité du disque. 
-- Si tel n'est pas le cas, l'enregistrement de la nouvelle ligne ne doit pas être fait et 
-- un message doit être affiché pour indiquer cette anomalie.
-- Tables : DISQUE(nom, capacité, vitesse, fabricant) / PARTITION(nomDisque, nomPartition, taille)
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 9.
-- Écrivez un bloc PL/SQL qui effectue une augmentation de 200 euros du salaire des employés 
-- du département 'Commercial' et qui utilise le dernier curseur implicite pour afficher le 
-- nombre d'employés affectés par ce changement.
-- Table : EMPLOYE(ID, NOM, DEPARTEMENT, AGE, SALAIRE)
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 10.
-- Soit la relation EMPLOYE de l'exercice précédent. Écrivez un bloc PL/SQL qui affiche les 
-- noms des employés du département 'Commercial' qui sont âgés de plus de 40 ans. 
-- Utilisez un curseur implicite dans une boucle FOR.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 11.
-- Soit la relation EMPLOYE de l'exercice précédent. Écrivez une procédure PL/SQL qui prend 
-- en paramètre un NUMBER (age limite) et qui affiche pour chaque département le nombre des 
-- employés qui dépassent l'âge limite. Utilisez un curseur avec paramètre l'âge limite.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 12.
-- Écrire une fonction PL/SQL qui prend en entrée le nom d'une ville et retourne la température 
-- et l'humidité de cette ville. Gérer aussi par une exception le cas où la ville n'existe pas.
-- Table : METEO(NOM_VILLE, Température, Humidité)
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 13.
-- Soit la table METEO de l'exercice précédent. Écrire un déclencheur qui avant l'insertion 
-- d'une nouvelle ville dans la table vérifie :
-- a. Si la température est la plus grande de toutes les villes, afficher un message d'avertissement.
-- b. Si la ville existe déjà dans la table, ne pas l'insérer une nouvelle fois mais faire 
--    la mise à jour seulement.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 14.
-- Écrire un bloc PL/SQL qui lit à la console le nom d'une compétition et qui affiche les 
-- participants avec leur score total (la somme de tous les scores par tous les juges). 
-- Utilisez un curseur avec paramètre.
-- Tables : COMPETITION, PARTICIPANT, SCORE
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 15.
-- On considère la table COMPETITION donnée dans l'exercice précédent. Écrire un déclencheur 
-- qui vérifie que le code d'une compétition commence par les lettres 'CMP' avant son 
-- insertion ou mise à jour dans la table COMPETITION.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 16.
-- Écrire une fonction PL/SQL qui retourne le nombre de clients de Dijon qui se sont abonnés 
-- au magazine « Vogue » après août 2010. S'il n'y a pas de clients qui remplissent la condition, 
-- lancer une exception utilisateur avec un message d'erreur.
-- Tables : CLIENT, MAGAZINE, ABONNEMENT
-- --------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION NOMBRE_CLIENTS




-- --------------------------------------------------------------------------------------
-- Exercice 17.
-- Créer un déclencheur qui est lancé après chaque nouvelle commande INSERT dans la table 
-- ABONNEMENT de l'exercice précédent. Le déclencheur fait la mise à jour du nombre d'abonnements 
-- dans la table suivante : TRACK_ABONNEMENTS(MAG_NOM, NB_ABONN).
-- On considère que la table TRACK_ABONNEMENTS contient déjà tous les magazines.
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 18.
-- Écrivez un programme PL/SQL qui affiche les vols pour un tour du monde au départ de Paris 
-- avec des escales et des durées d'escale prédéfinies dans la table ESCALE. Le nombre d'escales 
-- à faire doit être demandé à l'utilisateur. Le numéro de chaque escale est donné par Numescale.
-- Hypothèse de travail : pour chaque escale il existe un vol et un seul satisfaisant les contraintes.
-- Exemple pour 4 escales : Paris -> Escale no 1 -> Escale no 2 -> Escale no 3 -> Escale no 4 -> Paris
-- Tables : VOL, ESCALES
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 19.
-- Modifiez le programme PL/SQL de l'exercice précédent pour qu'il fonctionne même si plusieurs 
-- vols satisfont les contraintes (retourner au maximum 10 propositions de vols par escale).
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :



-- --------------------------------------------------------------------------------------
-- Exercice 20.
-- On considère la table VOL des exercices précédents. Écrivez une procédure PL/SQL capable de 
-- faire des propositions de tours du monde, prenant en entrée la ville de départ (qui est aussi 
-- la destination finale) et deux bornes (supérieure et inférieure) pour le nombre d'escales. 
-- Dans ce cas il n'y a pas de liste prédéfinie d'escales et on ne s'intéresse pas à la durée des 
-- escales. La procédure doit afficher les vols pour chaque tour du monde proposé (méthode récursive).
-- --------------------------------------------------------------------------------------
-- ÉCRIVEZ VOTRE PL/SQL CI-DESSOUS :