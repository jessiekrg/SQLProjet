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
ALTER TABLE CLIENT MODIFY (Nom      VARCHAR(15));

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


-- ============================================================
--  PARTIE 4 : REQUETES SELECT (exemples corrigés)
-- ============================================================

-- 1. Liste de tous les clients
SELECT * FROM CLIENT;

-- 2. Clients français
SELECT * FROM CLIENT WHERE Nationalite = 'Française';

-- 3. Clients français triés alphabétiquement
SELECT * FROM CLIENT
WHERE Nationalite = 'Française'
ORDER BY Nom ASC;

-- 4. Numéros des clients américains à Paris
SELECT ClientId FROM CLIENT
WHERE Nationalite = 'Américaine' AND Ville = 'Paris';

-- 5. Clients français ou anglais
SELECT Nom FROM CLIENT
WHERE Nationalite IN ('Française', 'Anglaise');

-- 6. Commandes entre 31/12/1992 et 31/12/1993
SELECT CommandeId FROM COMMANDE
WHERE Date_com BETWEEN TO_DATE('31-DEC-1992','DD-MON-YYYY')
                   AND TO_DATE('31-DEC-1993','DD-MON-YYYY');

-- 7. Noms des clients et numéros de leurs commandes
SELECT c.Nom, cmd.CommandeId
FROM CLIENT c
JOIN COMMANDE cmd ON c.ClientId = cmd.ClientId;

-- 8. Codes fabricants du produit 'Perceuse' le moins cher
SELECT FabricantId FROM PRODUIT
WHERE Description = 'Perceuse'
  AND Prix = (SELECT MIN(Prix) FROM PRODUIT WHERE Description = 'Perceuse');

-- 9. Noms des fabricants du produit 'Perceuse' le moins cher
SELECT f.Nom FROM FABRICANT f
JOIN PRODUIT p ON f.FabricantId = p.FabricantId
WHERE p.Description = 'Perceuse'
  AND p.Prix = (SELECT MIN(Prix) FROM PRODUIT WHERE Description = 'Perceuse');

-- 10. Prix moyen et max par type de produit
SELECT Description,
       AVG(Prix) AS Prix_Moyen,
       MAX(Prix) AS Prix_Max
FROM PRODUIT
GROUP BY Description;

-- 11. Idem, mais uniquement les produits avec au moins 2 fabricants
SELECT Description,
       AVG(Prix) AS Prix_Moyen,
       MAX(Prix) AS Prix_Max
FROM PRODUIT
GROUP BY Description
HAVING COUNT(DISTINCT FabricantId) >= 2;

-- 12. Fabricant au prix le plus bas, par type de produit
SELECT p.Description, f.Nom AS Fabricant, p.Prix
FROM PRODUIT p
JOIN FABRICANT f ON p.FabricantId = f.FabricantId
WHERE p.Prix = (
    SELECT MIN(p2.Prix) FROM PRODUIT p2
    WHERE p2.Description = p.Description
);

-- 13. Clients sans commande (LEFT JOIN anti-jointure)
SELECT c.Nom FROM CLIENT c
LEFT JOIN COMMANDE cmd ON c.ClientId = cmd.ClientId
WHERE cmd.ClientId IS NULL;

-- 14. Couples de clients différents (auto-jointure)
SELECT c1.ClientId, c2.ClientId
FROM CLIENT c1, CLIENT c2
WHERE c1.ClientId < c2.ClientId;

-- 15. Clients sans adresse
SELECT * FROM CLIENT WHERE Adresse IS NULL;

-- 16. Remplacer les adresses nulles
UPDATE CLIENT SET Adresse = 'Adresse inconnue' WHERE Adresse IS NULL;
COMMIT;

-- 17. Produits commandés par chaque client + quantité totale
SELECT c.Nom, p.Description, SUM(lc.Quantite) AS Qte_Totale
FROM CLIENT c
JOIN COMMANDE      cmd ON c.ClientId    = cmd.ClientId
JOIN LIGNECOMMANDE lc  ON cmd.CommandeId = lc.CommandeId
JOIN PRODUIT       p   ON lc.ProduitId   = p.ProduitId
GROUP BY c.Nom, p.Description;

-- 18. Clients ayant commandé TOUS les produits de Bosch
SELECT c.Nom FROM CLIENT c
WHERE NOT EXISTS (
    SELECT p.ProduitId FROM PRODUIT p
    JOIN FABRICANT f ON p.FabricantId = f.FabricantId
    WHERE f.Nom = 'Bosch'
    AND NOT EXISTS (
        SELECT 1 FROM COMMANDE cmd
        JOIN LIGNECOMMANDE lc ON cmd.CommandeId = lc.CommandeId
        WHERE cmd.ClientId = c.ClientId
          AND lc.ProduitId = p.ProduitId
    )
)
ORDER BY c.Nom;

-- 19. Nombre de produits et prix moyen par fournisseur
SELECT f.Nom,
       COUNT(DISTINCT p.ProduitId) AS Nb_Produits,
       AVG(p.Prix)                 AS Prix_Moyen
FROM FABRICANT f
JOIN PRODUIT p ON f.FabricantId = p.FabricantId
GROUP BY f.Nom;


-- ============================================================
--  PARTIE 5 : VUES (CREATE VIEW)
-- ============================================================

-- Vue a : produits au-dessus du prix moyen
CREATE VIEW Produits_Premium AS
    SELECT * 
    FROM PRODUIT
    WHERE Prix > (SELECT AVG(Prix) FROM PRODUIT);

-- Vue b : catalogue par fabricant
CREATE VIEW Catalogue AS
    SELECT f.Nom AS Fabricant, p.Description, p.Prix
    FROM FABRICANT f
    JOIN PRODUIT p ON f.FabricantId = p.FabricantId;

-- Requêtes de test sur les vues
SELECT * FROM Produits_Premium;
SELECT * FROM Catalogue WHERE Fabricant = 'Bosch';
SELECT Fabricant, COUNT(*) AS Nb FROM Catalogue GROUP BY Fabricant;


-- ============================================================
--  PARTIE 6 : MISES A JOUR ET SUPPRESSIONS
-- ============================================================

-- Mettre les noms en majuscule
UPDATE CLIENT SET Nom = UPPER(Nom);

-- Mettre les clients français en minuscule
UPDATE CLIENT SET Nom = LOWER(Nom) WHERE Nationalite = 'Française';

-- Doubler le prix des commandes après le 01/01/1992
UPDATE COMMANDE SET PrixTotal = PrixTotal * 2
WHERE Date_com > TO_DATE('01-JAN-1992', 'DD-MON-YYYY');

COMMIT;

-- Supprimer les clients français
-- (supprimer d'abord les lignes dépendantes si nécessaire)
DELETE FROM LIGNECOMMANDE
WHERE CommandeId IN (
    SELECT CommandeId FROM COMMANDE
    WHERE ClientId IN (SELECT ClientId FROM CLIENT WHERE Nationalite = 'Française')
);
DELETE FROM COMMANDE
WHERE ClientId IN (SELECT ClientId FROM CLIENT WHERE Nationalite = 'Française');
DELETE FROM CLIENT WHERE Nationalite = 'Française';

-- Supprimer les clients ayant commandé avant le 01/01/1990
DELETE FROM CLIENT
WHERE ClientId IN (
    SELECT ClientId FROM COMMANDE
    WHERE Date_com < TO_DATE('01-JAN-1990', 'DD-MON-YYYY')
);

COMMIT;

-- ============================================================
--  FIN DU SCRIPT
-- ============================================================
