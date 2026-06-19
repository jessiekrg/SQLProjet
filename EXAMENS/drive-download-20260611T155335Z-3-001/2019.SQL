--------------------------------------------------------------------------------
-- IN507 - BASES DE DONNÉES (EXAMEN 2019-2020)
-- SCHÉMA RELATIONNEL
--------------------------------------------------------------------------------

-- UTILISATEUR (NumUt, Mail, Ville, Reputation)
-- PRODUIT (NumProd, Nom, Type, Marque, Description, Prix, Couleur)
-- POSSEDE_PRODUIT (NumUt, NumProd, DateAchat)
-- OFFRE_ECHANGE (NumOff, NumUtInit, NumProdOff, NumProdDes, DateCreation, DateLimite)
-- ECHANGE_REALISE (NumOff, NumUtAcc, DateAcc)

--------------------------------------------------------------------------------
-- REQUÊTES EXAMEN - PARTIE II
--------------------------------------------------------------------------------

-- Question 2.1 (1pt) :
-- Trouver les utilisateurs ayant une réputation supérieure à 3, habitant à 
-- Versailles et qui proposent des échanges de 'téléphone portable' de marque 'Alcatel'.

SELECT U.NumUt
FROM UTILISATEUR U
JOIN OFFRE_ECHANGE O ON U.NumUt = O.NumUtInit
JOIN PRODUIT P ON O.NumProdOff = P.NumProd
WHERE U.Reputation > 3 AND U.Ville = 'Versailles' AND P.Type = 'téléphone portable' AND P.marque = 'Alcatel';

-- Question 2.2a (1pt) :
-- Trouver les offres encore valides pour des meubles de type 'buffet' proposées par 
-- des utilisateurs situés à Palaiseau.
-- Note : Une offre est valide si DateLimite >= COURANTE et non présente dans ECHANGE_REALISE.

SELECT O.NumOff
FROM OFFRE_ECHANGE O 
JOIN PRODUIT P ON O.NumProdOff = P.NumProd
WHERE P.Type = 'buffet' AND O.DateLimite >= SYSDATE AND O.NumUtInit IN (
    SELECT NumUt
    FROM UTILISATEUR
    WHERE Ville = 'Palaiseau' 
    )
AND 
NOT EXISTS (
    SELECT NumOff
    FROM ECHANGE_REALISE
    WHERE O.NumOff = NumOff
);

-- Question 2.2b (1pt) :
-- Donner le nom des produits qui sont proposés à l'échange mais dont personne ne veut.

SELECT DISTINCT P.NumProd, P.Nom
FROM PRODUIT P 
JOIN OFFRE_ECHANGE O ON P.NumProd = O.NumProdOff -- Le produit est proposé à l'échange
WHERE NOT EXISTS (
    SELECT *
    FROM OFFRE_ECHANGE O2
    WHERE O2.NumProdDes = P.NumProd -- Sémantique : Personne ne le désire dans AUCUNE offre
);

-- Question 2.3 (2pts) :
-- Écrire la requête qui positionne à zéro la réputation des clients qui ne proposent 
-- à l'échange que des produits qui valent moins cher que ceux avec lesquels ils sont prêts à échanger.

UPDATE UTILISATEUR U
SET Reputation = 0
WHERE NOT EXISTS (
    SELECT *
    FROM OFFRE_ECHANGE O 
    JOIN PRODUIT P_OFF ON P_OFF.NumProd = O.NumProdOff
    JOIN PRODUIT P_DESI ON  P_DESI.NumProd = O.NumProdDes
    WHERE P_OFF.Prix >= P_DESI.Prix
    AND O.NumUtInit = U.NumUt
) AND EXISTS (
    SELECT *
    FROM OFFRE_ECHANGE
    WHERE NumUtInit = U.NumUt
); -- perfect 

-- Question 2.4 (2pts) :
-- Trouver les produits les plus recherchés, à savoir, ceux qui ont généré le 
-- nombre maximum d'échanges acceptés en moins de trois jours.

SELECT OE.NumProdOff, COUNT(ER.NumOff) AS NB_MAXECHANGE
FROM OFFRE_ECHANGE OE 
JOIN ECHANGE_REALISE ER ON ER.NumOff = OE.NumOff
WHERE ER.DateAcc - OE.DateCreation < 3
GROUP BY OE.NumProdOff
HAVING COUNT(ER.NumOff) = (
    SELECT MAX(COUNT(ER1.NumOff))
    FROM OFFRE_ECHANGE OE1 
    JOIN ECHANGE_REALISE ER1 ON ER1.NumOff = OE1.NumOff
    WHERE ER1.DateAcc - OE1.DateCreation < 3
    GROUP BY OE1.NumProdOff
);

-- Question 2.5 (2pts) :
-- Définir la vue qui donne le nombre d'échanges pour chaque couple de produits échangés.

CREATE VIEW S AS
    SELECT P1.NumProd AS NumProdOff , P2.NumProd AS NumProdDes, COUNT(ER.NumOff) AS nombre
    FROM ECHANGE_REALISE ER
    JOIN OFFRE_ECHANGE OE ON ER.NumOff = OE.NumOff
    JOIN PRODUIT P1 ON OE.NumProdOff = P1.NumProd
    JOIN PRODUIT P2 ON OE.NumProdDes = P2.NumProd
    GROUP BY P1.NumProd, P2.NumProd;