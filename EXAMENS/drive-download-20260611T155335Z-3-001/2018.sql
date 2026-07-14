/*
=========================================================================================
                          UNIVERSITÉ DE VERSAILLES ST-QUENTIN
                           IN507 - BASES DE DONNÉES (2018-2019)
                                     SUJET D'EXAMEN
=========================================================================================

DESCRIPTION DU SCHÉMA RELATIONNEL :
- LIEUX (IDlieu, NomL, Description, Altitude)
- SERVICE (IDservice, Type, Description, Telephone, SiteWeb)
- PROPOSE_SERVICE (IDlieu, IDservice)
- SENTIER (IDsentier, NomS, Description, Difficulte, Longueur, IDlieu1, IDlieu2)
- RANDONNEUR (Email, Age, Sexe, Niveau)
- TRAJET (Email, IDsentier, DateDepart, IDlieuDepart, DateArrivee)

Notes importantes :
- Les clés primaires sont le premier attribut de chaque table (ex: IDlieu, IDservice...).
- Pour PROPOSE_SERVICE, la clé primaire est le couple (IDlieu, IDservice).
- Pour TRAJET, la clé primaire est le triplet (Email, IDsentier, DateDepart).
- Tous les attributs préfixés par "ID" sont de type ENTIER.
- Les attributs DateDepart et DateArrivee incluent l'heure.
=========================================================================================
*/

-----------------------------------------------------------------------------------------
-- PARTIE I : MODÈLE RELATIONNEL ET SQL (14 PTS)
-----------------------------------------------------------------------------------------

-- Question 1.1 (1 pt) :
-- Indiquez les clés étrangères dans ces relations, pour que le modèle soit cohérent.
-- Utilisez la notation : TableA.CléEtrangère -> TableB.AttributRéférencé




-- Question 1.2 (2 pts) :
-- Donnez le schéma dans le format entité-association de cette base de telle sorte que 
-- le schéma relationnel qui se déduit par la méthode vue en cours de votre schéma E/A 
-- est bien celui donné plus haut. Indiquez les clés primaires et les cardinalités.



-- Question 1.3 (1 pt) :
-- Donnez la requête SQL permettant de créer la table SENTIER et ses contraintes 
-- d'intégrités (c.à.d., clés primaire et étrangères).
CREATE TABLE SENTIER (
    IDsentier NUMBER CONSTRAINT IDS PRIMARY KEY, 
    NomS VARCHAR(50), 
    Description VARCHAR(50), 
    Difficulte VARCHAR(50), 
    Longueur NUMBER,  
    IDlieu1 NUMBER CONSTRAINT FK_L1 REFERENCES LIEUX(IDlieu), 
    IDlieu2 NUMBER CONSTRAINT FK_L2 REFERENCES LIEUX(IDlieu)
);

-- Question 2.1 (1 pt) :
-- Afficher les sentiers qui partent de "Lac des cygnes" et arrivent à "Grotte de l'ours".

SELECT IDsentier
FROM SENTIER
WHERE IDlieu1 IN (
    SELECT IDlieu
    FROM LIEUX
    WHERE NomL = 'Lac des cygnes'
)
AND IDlieu2 IN (
    SELECT IDlieu
    FROM LIEUX
    WHERE NomL = 'Grotte de l''ours'
);

-- Question 2.2 (1 pt) :
-- Trouver les lieux situés à plus de 1500 mètres d'altitude qui proposent des 
-- services de type restauration et couchage.

SELECT L.IDlieu
FROM LIEUX L
JOIN PROPOSE_SERVICE J ON J.IDlieu = L.IDlieu
JOIN SERVICE S ON S.IDservice = J.IDservice
WHERE L.Altitude > 1500 AND S.Type IN ('restauration','couchage')
GROUP BY L.IDlieu
HAVING COUNT(DISTINCT S.Type) = 2;

-- Question 2.3 (1 pt) :
-- Quels sont les lieux que personne n'a visités (si l'on considère les trajets) 
-- pendant la journée du 1er janvier 2019.

SELECT L.IDlieu
FROM LIEUX L 
WHERE NOT EXISTS (
    SELECT *
    FROM TRAJET T
    JOIN SENTIER S ON S.IDsentier = T.IDsentier
    WHERE T.DateDepart BETWEEN TO_DATE('2019-01-01 0:0:00', 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE('2019-01-01 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
    AND (L.IDlieu = S.IDlieu1 OR L.IDlieu = S.IDlieu2)
);



-- Question 2.4 (1 pt) :
-- Créer la vue Randonneurs_actifs qui donne les randonneurs les plus mobiles 
-- (ayant fait le maximum de trajets) par jour.
-- Afficher l'email du randonneur, le nombre de trajet et la date.

CREATE VIEW Randonneurs_actifs AS 
SELECT T.Email, COUNT(T.IDsentier) as nb , TO_CHAR(T.DateDepart, 'YYYY-MM-DD') AS JOUR
FROM TRAJET T
GROUP BY T.Email,TO_CHAR(T.DateDepart, 'YYYY-MM-DD') 
HAVING COUNT(T.IDsentier) = (
    SELECT  MAX(COUNT (T2.IDsentier))
    FROM TRAJET T2
    WHERE TO_CHAR(T2.DateDepart, 'YYYY-MM-DD') = TO_CHAR(T.DateDepart, 'YYYY-MM-DD') 
    GROUP BY  T2.Email
);



-- Question 2.5 (1.5 pts) :
-- Trouver les sentiers qui partent du lieu nommé la « Motte aux marmottes » et 
-- arrivent à la « Prairie des cerfs » soit directs soit passant par un seul lieu intermédiaire.
-- Afficher le nom des sentiers directs ou le couple de noms pour les trajets composés 
-- triés sur la difficulté des sentiers.

-- PARTIE 1 : Sentiers directs
SELECT S1.NomS AS Sentier1, NULL AS Sentier2, S1.Difficulte
FROM SENTIER S1
JOIN LIEUX L_Deb ON S1.IDlieu1 = L_Deb.IDlieu
JOIN LIEUX L_Fin ON S1.IDlieu2 = L_Fin.IDlieu
WHERE L_Deb.NomL = 'Motte aux marmottes' 
  AND L_Fin.NomL = 'Prairie des cerfs'

UNION -- Fusionne les deux résultats

-- PARTIE 2 : Trajets avec un lieu intermédiaire (2 sentiers mis bout à bout)
SELECT S1.NomS AS Sentier1, S2.NomS AS Sentier2, S1.Difficulte
FROM SENTIER S1
JOIN SENTIER S2 ON S1.IDlieu2 = S2.IDlieu1 -- La fin du premier est le début du second !
JOIN LIEUX L_Deb ON S1.IDlieu1 = L_Deb.IDlieu
JOIN LIEUX L_Fin ON S2.IDlieu2 = L_Fin.IDlieu
WHERE L_Deb.NomL = 'Motte aux marmottes' 
  AND L_Fin.NomL = 'Prairie des cerfs'

ORDER BY Difficulte DESC; -- Le tri global demandé à la fin

-- Question 2.6 (1.5 pts) :
-- Trouver les randonneurs qui ont visité tous les lieux (par rapport aux trajets 
-- effectués) dans la période du 24 au 31 décembre 2018.

SELECT R.Email
FROM RANDONNEUR R
WHERE NOT EXISTS (
    SELECT L.IDlieu
    FROM LIEUX L 
    WHERE NOT EXISTS (
        SELECT *
        FROM TRAJET T 
        JOIN SENTIER S ON T.IDsentier = S.IDsentier
        WHERE T.Email = R.Email AND T.DateDepart BETWEEN TO_DATE('2018-12-24 0:0:00', 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE('2018-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') 
        AND (L.IDlieu = S.IDlieu1 OR L.IDlieu = S.IDlieu2)
    )
);

-- Question 2.7 (1.5 pts) :
-- Afficher les couples de randonneurs qui se sont croisés sur les sentiers (en les 
-- parcourant dans des directions opposées) dans la journée du 10 janvier 2019. 
-- Pour extraire l'heure à partir d'un attribut de type date, utiliser la fonction Time(attribut_date).

SELECT R1.Email, R2.Email
FROM TRAJET T1
JOIN TRAJET T2 ON T1.IDsentier = T2.IDsentier AND T1.Email < T2.Email
WHERE T1.DateDepart BETWEEN TO_DATE('2018-12-24 0:0:00', 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE('2018-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') 
AND T1.IDlieuDepart <> T2.IDlieuDepart
AND Time(T1.DateDepart) <= Time(T2.DateArrivee)
    AND Time(T2.DateDepart) <= Time(T1.DateArrivee);

-- Question 2.8 (1.5 pts) :
-- Créer la vue Stats_randonneurs qui calcule pour chaque randonneur le nombre total 
-- de sentiers parcourus, la distance totale et le dénivelé total. 
-- Le dénivelé d'un sentier est obtenu en faisant la différence entre l'altitude des 
-- points de départ et d'arrivée.

CREATE VIEW Stats_randonneurs AS 
    SELECT 
        T.Email, COUNT(T.IDsentier) AS NB , 
        SUM(S.Longueur) AS distance_totale, 
        SUM(ABS(L1.Altitude - L2.Altitude)) AS dénivelé_total
    FROM TRAJET T 
    JOIN SENTIER S ON S.IDsentier = T.IDsentier 
    JOIN LIEUX L1 ON L1.IDlieu = S.IDlieu1
    JOIN LIEUX L2 ON L2.IDlieu = S.IDlieu2
    GROUP BY T.Email;


-----------------------------------------------------------------------------------------
-- PARTIE II : HTML/PHP ET DROITS D'ACCÈS (6 PTS)
-----------------------------------------------------------------------------------------

/*
Contexte :
On souhaite construire un site web permettant de visualiser et administrer en ligne 
les informations stockées dans la base de données. 
- Nom de la base : "parc_vert"
- Login de la base : "user"
- Mot de passe : "toto"
*/

-- a) (1 pt) :
-- Donner les requêtes SQL permettant de créer l'utilisateur "user" et de lui donner 
-- l'accès en lecture seule sur les tables LIEUX et SERVICE.



/*
-- b) (1 pt) :
-- Donner le code d'une page de recherche HTML contenant un titre "Recherche parcours" 
-- et un formulaire de recherche contenant :
--   - Les champs de type texte 'Lieu départ' et 'Lieu arrivée'
--   - Une liste déroulante permettant d'indiquer le type de parcours désiré :
--     facile, rapide, lent, loisir...
-- Le formulaire sera situé dans un tableau (table) ayant deux colonnes.
-- Méthode de transmission : POST à la page 'affiche_parcours.php'.
*/



/*
-- c) (4 pts) :
-- Donner le code PHP de la page 'affiche_parcours.php' pour afficher les résultats 
-- de la recherche d'un parcours triés sur le type de parcours choisi.
-- Deux lieux sont connectés si le chemin couvre au maximum 5 sentiers.
-- Afficher les informations globales (longueur totale, nombre de sentiers) puis le détail.
-- Calculer le parcours pour un seul type au choix entre : facile/lent/rapide/loisir.
*/