-- ============================================================
--  TP SQL LSIN513 -- CORRIGE COMPLET
--  Base de données : Commandes
--  Auteur          : Corrigé automatique
-- ============================================================


-- ============================================================
--  PARTIE 1 : CREATION DES TABLES (DDL)
-- ============================================================

-- Supprimer les tables si elles existent déjà (ordre inverse des FK)
DROP TABLE LIGNECOMMANDE;
DROP TABLE COMMANDE;
DROP TABLE PRODUIT;
DROP TABLE FABRICANT;
DROP TABLE CLIENT;


-- -------------------------------------------------------
-- 1. CLIENT  (aucune FK)
-- -------------------------------------------------------
CREATE TABLE CLIENT (
    ClientId    NUMBER(5)    CONSTRAINT PK_CLIENT     PRIMARY KEY,
    Nom         VARCHAR(30)  CONSTRAINT NN_CLI_NOM    NOT NULL,
    Adresse     VARCHAR(60),
    Ville       VARCHAR(30),
    Departement VARCHAR(20),
    Telephone   VARCHAR(15),
    Nationalite VARCHAR(20)   -- ajouté (partie 2b)
);

-- -------------------------------------------------------
-- 2. FABRICANT  (aucune FK)
-- -------------------------------------------------------
CREATE TABLE FABRICANT (
    FabricantId NUMBER(5)    CONSTRAINT PK_FABRICANT  PRIMARY KEY,
    Nom         VARCHAR(30)  CONSTRAINT NN_FAB_NOM    NOT NULL
);

-- -------------------------------------------------------
-- 3. PRODUIT  (FK → FABRICANT)
-- -------------------------------------------------------
CREATE TABLE PRODUIT (
    ProduitId   NUMBER(5)    CONSTRAINT PK_PRODUIT    PRIMARY KEY,
    Description VARCHAR(60)  CONSTRAINT NN_PROD_DESC  NOT NULL,
    FabricantId NUMBER(5)    CONSTRAINT FK_PROD_FAB
                             REFERENCES FABRICANT(FabricantId),
    Prix        NUMBER(10,2)  -- ajouté (partie 2b)
);

-- -------------------------------------------------------
-- 4. COMMANDE  (FK → CLIENT)
-- -------------------------------------------------------
CREATE TABLE COMMANDE (
    CommandeId  NUMBER(5)    CONSTRAINT PK_COMMANDE   PRIMARY KEY,
    Date_com    DATE,
    ClientId    NUMBER(5)    CONSTRAINT FK_CMD_CLI
                             REFERENCES CLIENT(ClientId),
    PrixTotal   NUMBER(10,2)
);

-- -------------------------------------------------------
-- 5. LIGNECOMMANDE  (FK → COMMANDE + PRODUIT)
--    Clé primaire composite : (ItemId, CommandeId)
-- -------------------------------------------------------
CREATE TABLE LIGNECOMMANDE (
    ItemId      NUMBER(5),
    CommandeId  NUMBER(5),
    ProduitId   NUMBER(5),
    Prix        NUMBER(10,2),
    Quantite    NUMBER(5),
    ItemTotal   NUMBER(10,2),
    CONSTRAINT PK_LC      PRIMARY KEY (ItemId, CommandeId),
    CONSTRAINT FK_LC_CMD  FOREIGN KEY (CommandeId) REFERENCES COMMANDE(CommandeId),
    CONSTRAINT FK_LC_PROD FOREIGN KEY (ProduitId)  REFERENCES PRODUIT(ProduitId)
);


-- ============================================================
--  PARTIE 2 : MODIFICATIONS DU SCHEMA (ALTER TABLE)
-- ============================================================

-- 2a. Modifier les types
ALTER TABLE CLIENT MODIFY (ClientId NUMBER(4));
ALTER TABLE CLIENT MODIFY (Nom VARCHAR(15));

-- 2c. Contraintes NOT NULL sur les colonnes critiques
ALTER TABLE COMMANDE MODIFY (ClientId NUMBER(5) NOT NULL);


-- ============================================================
--  PARTIE 3 : INSERTION DE DONNEES (DML)
-- ============================================================

-- -------------------------------------------------------
-- FABRICANTS
-- -------------------------------------------------------
INSERT INTO FABRICANT VALUES (1, 'Bosch');
INSERT INTO FABRICANT VALUES (2, 'Sony');
INSERT INTO FABRICANT VALUES (3, 'Moulinex');
INSERT INTO FABRICANT VALUES (4, 'Philips');

-- -------------------------------------------------------
-- CLIENTS
-- -------------------------------------------------------
INSERT INTO CLIENT VALUES (1, 'Dupont',  '12 rue de Rivoli', 'Paris',    '75', '0145000001', 'Française');
INSERT INTO CLIENT VALUES (2, 'Martin',  '5 avenue Foch',    'Lyon',     '69', '0472000002', 'Française');
INSERT INTO CLIENT VALUES (3, 'Smith',   '10 Baker Street',  'Londres',  NULL, '004420700',  'Anglaise');
INSERT INTO CLIENT VALUES (4, 'Jones',   '5 Main Street',    'Paris',    NULL, '0145000003', 'Américaine');
INSERT INTO CLIENT VALUES (5, 'Müller',  '3 Hauptstrasse',   'Berlin',   NULL, '004930400',  'Allemande');
INSERT INTO CLIENT VALUES (6, 'Bernard', NULL,               'Marseille','13', '0491000004', 'Française');

-- -------------------------------------------------------
-- PRODUITS
-- -------------------------------------------------------
INSERT INTO PRODUIT VALUES (10, 'Perceuse',      1, 79.99);
INSERT INTO PRODUIT VALUES (11, 'Perceuse',      3, 65.00);   -- même produit, autre fabricant
INSERT INTO PRODUIT VALUES (12, 'Casque audio',  2, 129.00);
INSERT INTO PRODUIT VALUES (13, 'Casque audio',  4, 89.99);   -- même produit, autre fabricant
INSERT INTO PRODUIT VALUES (14, 'Cafetière',     3, 49.90);
INSERT INTO PRODUIT VALUES (15, 'Aspirateur',    4, 199.00);
INSERT INTO PRODUIT VALUES (16, 'Fer à repasser',4, 39.99);

-- -------------------------------------------------------
-- COMMANDES
-- -------------------------------------------------------
INSERT INTO COMMANDE VALUES (1001, TO_DATE('12-NOV-1999','DD-MON-YYYY'), 1, 1000.00);
INSERT INTO COMMANDE VALUES (1002, NULL,                                  2, 1500.00);
INSERT INTO COMMANDE VALUES (1003, TO_DATE('15-MAR-1993','DD-MON-YYYY'), 3,  500.00);
INSERT INTO COMMANDE VALUES (1004, TO_DATE('01-JAN-1991','DD-MON-YYYY'), 4,  250.00);
INSERT INTO COMMANDE VALUES (1005, TO_DATE('20-JUN-2001','DD-MON-YYYY'), 1,  300.00);
INSERT INTO COMMANDE VALUES (1006, TO_DATE('10-DEC-1992','DD-MON-YYYY'), 5,  800.00);

-- -------------------------------------------------------
-- LIGNES DE COMMANDE
-- -------------------------------------------------------
INSERT INTO LIGNECOMMANDE VALUES (1, 1001, 10,  79.99, 2,  159.98);
INSERT INTO LIGNECOMMANDE VALUES (2, 1001, 12, 129.00, 1,  129.00);
INSERT INTO LIGNECOMMANDE VALUES (1, 1002, 13,  89.99, 3,  269.97);
INSERT INTO LIGNECOMMANDE VALUES (2, 1002, 15, 199.00, 2,  398.00);
INSERT INTO LIGNECOMMANDE VALUES (1, 1003, 11,  65.00, 5,  325.00);
INSERT INTO LIGNECOMMANDE VALUES (1, 1004, 14,  49.90, 2,   99.80);
INSERT INTO LIGNECOMMANDE VALUES (1, 1005, 16,  39.99, 1,   39.99);
INSERT INTO LIGNECOMMANDE VALUES (2, 1005, 10,  79.99, 2,  159.98);
INSERT INTO LIGNECOMMANDE VALUES (1, 1006, 12, 129.00, 4,  516.00);

-- Valider toutes les insertions
COMMIT;
-- 1°) Liste des clients ?
SELECT *
FROM CLIENT;

-- 2°) Liste des clients français ?

SELECT *
FROM CLIENT
WHERE Nationalite = 'Française';

-- 3°) Liste des clients français triés par ordre alphabétique ?

SELECT *
FROM CLIENT
WHERE Nationalite = 'Française'
ORDER BY Nom;

-- 4°) Numéro des clients américains situés à Paris ?

SELECT *
FROM CLIENT 
WHERE VILLE = 'Paris';

-- 5°) Noms des clients français ou anglais ?

SELECT c.Nom
FROM CLIENT c
WHERE Nationalite = 'Française' OR Nationalite = 'Anglaise';

-- 6°) Numéros des commandes passées entre le 31/12/92 et le 31/12/93 ?
SELECT i
FROM COMMANDE c
WHERE Date_com BETWEEN TO_DATE('31-DEC-1992','DD-MON-YYYY') AND TO_DATE('31-DEC-1993','DD-MON-YYYY');

-- 7°) Noms des clients et numéros des commandes qu'ils passent ?
SELECT co.CommandeId
FROM CLIENT c
JOIN COMMANDE co on c.ClientId = co.ClientId;

-- 8°) Codes des fabricants qui fabriquent le produit 'x' le moins cher ?
SELECT fab.FabricantId
FROM FABRICANT fab
JOIN PRODUIT pr on fab.FabricantId = pr.FabricantId
WHERE prix = (
    SELECT MIN(PRIX) 
    FROM PRODUIT
    );

-- 9°) Noms des fabricants qui fabriquent le produit 'x' le moins cher ?
SELECT fab.Nom
FROM FABRICANT fab
JOIN PRODUIT pr on fab.FabricantId = pr.FabricantId
WHERE prix = (
    SELECT MIN(PRIX) 
    FROM PRODUIT
    );


-- 10°) Pour chaque type de produit (description), donner le prix moyen et le prix max ?
SELECT PR.DESCRIPTION, AVG(Prix), MAX(Prix)
FROM PRODUIT PR
GROUP BY DESCRIPTION;

-- 11°) Même question que 10) mais le produit a au moins deux fabricants ?
SELECT PR.DESCRIPTION, count( DISTINCT FabricantId) 
FROM PRODUIT PR
GROUP BY DESCRIPTION
HAVING count(DISTINCT FabricantId) >= 2;

-- 12°) Pour chaque type de produit, donner le fabricant qui fabrique au plus bas prix ainsi que ce prix ?
SELECT PR.DESCRIPTION, PR.PRIX
FROM PRODUIT PR 
JOIN FABRIQUANT FA ON FA.FabricantId = PR.FabricantId
WHERE Prix = (SELECT MIN(P2.PRIX) FROM PRODUIT P2 WHERE P2.DESCRIPTION = PR.DESCRIPTION)

-- 13°) Noms des clients qui n'ont pas passé de commandes ?
-- 13. Clients sans commande (LEFT JOIN anti-jointure)
SELECT c.Nom FROM CLIENT c
LEFT JOIN COMMANDE cmd ON c.ClientId = cmd.ClientId
WHERE cmd.ClientId IS NULL;

-- 14°) Couples des numéros de clients différents ?


-- 15°) Rechercher tous les clients qui n'ont pas d'adresse ?
SELECT *
FROM CLIENT 
WHERE ADRESSE IS NULL;

-- 16°) Remplacer toutes ces valeurs nulles par une valeur par défaut ?
UPDATE CLIENT SET Adresse = 'Adresse inconnue' WHERE Adresse IS NULL;
COMMIT;

-- 17°) Donner pour chaque client la liste des produits commandés et leur nombre pour l'ensemble des commandes qu'il a passées ?
SELECT c.Nom, p.Description, SUM(lc.Quantite) AS Qte_Totale
FROM CLIENT c
JOIN COMMANDE      cmd ON c.ClientId    = cmd.ClientId
JOIN LIGNECOMMANDE lc  ON cmd.CommandeId = lc.CommandeId
JOIN PRODUIT       p   ON lc.ProduitId   = p.ProduitId
GROUP BY c.Nom, p.Description;

-- 18°) Rechercher les clients qui ont commandé tous les produits du fournisseur ‘y’, donner le nom des clients par ordre croissant ?
SELECT c.Nom
FROM CLIENT c
JOIN COMMANDE cmd ON c.ClientId = cmd.ClientId
JOIN LIGNECOMMANDE lc ON cmd.CommandeId = lc.CommandeId
JOIN PRODUIT p ON lc.ProduitId = p.ProduitId
JOIN FABRICANT f ON p.FabricantId = f.FabricantId
WHERE f.Nom = 'Bosch'
GROUP BY c.Nom
HAVING COUNT(DISTINCT lc.ProduitId) = (
    SELECT COUNT(DISTINCT p2.ProduitId)
    FROM PRODUIT p2
    JOIN FABRICANT f2 ON p2.FabricantId = f2.FabricantId
    WHERE f2.Nom = 'Bosch'
)
ORDER BY c.Nom;

-- 19°) Rechercher le nombre de produits vendus par fournisseur ainsi que la moyenne des prix des produits vendus ?
SELECT PR.FabricantId, COUNT( PR.ProduitId), AVG(PR.PRIX) AS MOY
FROM PRODUIT PR
GROUP BY PR.FabricantId;

-- ============================================================
--  PARTIE 5 : VUES (CREATE VIEW)
-- ============================================================

-- Vue a : produits au-dessus du prix moyen
CREATE VIEW PL_MOY AS
    SELECT *
    FROM PRODUIT 
    WHERE PRIX > (SELECT AVG(PRIX) FROM PRODUIT);


-- Vue b : catalogue par fabricant
CREATE VIEW C AS

-- Requêtes de test sur les vues



-- ============================================================
--  PARTIE 6 : MISES A JOUR ET SUPPRESSIONS
-- ============================================================

-- Mettre les noms en majuscule

-- Mettre les clients français en minuscule

-- Doubler le prix des commandes après le 01/01/1992


-- Supprimer les clients français
-- (supprimer d'abord les lignes dépendantes si nécessaire)

-- Supprimer les clients ayant commandé avant le 01/01/1990


