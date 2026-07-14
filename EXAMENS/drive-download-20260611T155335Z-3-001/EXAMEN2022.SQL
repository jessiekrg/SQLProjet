/*
DESCRIPTION DU SCHEMA RELATIONNEL :
- PERSONNE (Npers, NomPers, Ville, dept, email) : Chercheurs d'emplois
- RECHERCHE (Npers, Ntyp, DateRech) : Qui recherche quoi ?
- T_EMPLOI (Ntyp, NomType, DescTyp, Sal_Moy) : Type d'emplois
- OFFRE (Nemploi, Nsiret, NTyp, DateDeb, DateFin, SalOffre) : Qui offre quoi ?
- SOCIETE (Nsiret, NomSoc, ville, dept) : Sociétés qui embauchent
- EMBAUCHE (Nemploi, Npers, NTyp, NSiret, DateEmb, SalEmb) : Qui embauche Qui ?
*/


-----------------------------------------------------------------------------------------
-- ENONCÉ DES QUESTIONS DE RECHERCHE & TRIGGERS
-----------------------------------------------------------------------------------------

-- Question 2 (2pts) : 
-- Rechercher le nom des sociétés qui ont embauché plus de 100 employés en 2021.
SELECT S.Nsiret, S.NomSoc
FROM SOCIETE S
JOIN EMBAUCHE E ON E.NSiret = S.NSiret
WHERE DateEmb IS BETWEEN TO_DATE('01-JAN-2021','DD-MON-YYYY') AND TO_DATE('31-DEC-2021','DD-MON-YYYT')
GROUP BY S.Nsiret, S.NomSoc -- c'est mieux 
HAVING COUNT(E.Npers) > 100;

-- Question 3 (2pts) : 
-- Calculer le nombre moyen d'offre par département. (genre 25)
SELECT COUNT(O.Nemploi) / COUNT(DISTINCT S.dept) -- Compte combien il y a de départements UNIQUES au total dans la table des sociétés (ex: 4 départements).
FROM SOCIETE S
LEFT JOIN OFFRE O ON O.Nsiret = S.Nsiret;

-- Question 4 (2 pts) : 
-- Rechercher pour chaque type d'emploi les offres disponibles.
-- Si il n'existe pas d'offre pour un type d'emploi, on doit voir apparaître que l'offre est nulle.
-- Aucun type d'emploi ne doit disparaître.
SELECT T.Ntyp, O.Nemploi
FROM T_EMPLOI T
LEFT JOIN OFFRE O ON O.NTyp = T.Ntyp;

SELECT T.Ntyp, O.Nemploi
FROM OFFRE O
LEFT JOIN T_EMPLOI T ON O.NTyp = T.Ntyp;

-- Question 5 (3 pts) : Quelles sont les sociétés qui ont offert tous les types d'emploi ?
-- a/ répondre par la logique
-- b/ répondre avec fonction agrégat

SELECT S.Nsiret, S.NomSoc
FROM SOCIETE S
WHERE NOT EXISTS (
    SELECT T.Ntyp
    FROM T_EMPLOI T
    WHERE NOT EXISTS (
        SELECT *
        FROM OFFRE O
        WHERE O.NTyp = T.Ntyp AND O.NSiret = S.Nsiret
    )
);

SELECT S.Nsiret, S.NomSoc
FROM SOCIETE S
JOIN OFFRE O ON O.NSiret = S.Nsiret
JOIN T_EMPLOI T ON O.Ntyp = T.Ntyp
GROUP BY S.Nsiret, S.NomSoc
HAVING COUNT(DISTINCT O.Ntyp) = (
    SELECT COUNT(Ntyp)
    FROM T_EMPLOI
);



-- Question 6 (4 pts) : 
-- Ecrire le/les triggers qui permettent de mettre à jour automatiquement la base de l'ANPE.
-- 1) On doit vérifier qu'une embauche correspond bien à une offre d'emploi existante 
--    et que le salaire d'embauche n'est pas inférieur à celui de l'offre, sinon on ne peut l'insérer.
-- 2) Ensuite, si une personne est embauchée, elle n'est plus à la recherche d'un emploi 
--    et donc certaines informations doivent disparaître de la base.
-- 3) De même une fois l'offre pourvue, elle doit disparaître de la base.

CREATE OR REPLACE TRIGGER MAJ_BASE_ANPE
BEFORE INSERT ON EMBAUCHE 
FOR EACH ROW 
DECLARE 
    v_CountOffre NUMBER;
    v_SalOffre   OFFRE.SalOffre%TYPE; -- Récupère dynamiquement le type de la colonne
BEGIN 
    -- 1. On vérifie si l'offre existe ET on récupère son salaire en même temps
    SELECT COUNT(*), MAX(SalOffre) INTO v_CountOffre, v_SalOffre
    FROM OFFRE
    WHERE Nemploi = :NEW.Nemploi;

    -- 2. Vérifications de conformité
    IF v_CountOffre = 0 THEN
        -- Si l'offre n'existe pas, on bloque l'insertion
        RAISE_APPLICATION_ERROR(-20001, 'L''embauche ne correspond à aucune offre existante.');
    ELSIF :NEW.SalEmb < v_SalOffre THEN 
        -- Si le salaire est insuffisant, on bloque l'insertion
        RAISE_APPLICATION_ERROR(-20002, 'Le salaire d''embauche est inférieur à celui de l''offre.');
    END IF;

    -- 3. Si tout est OK, on nettoie la base (Disparition des données)
    
    -- La personne n'est plus à la recherche d'un emploi pour ce type
    DELETE FROM RECHERCHE 
    WHERE Npers = :NEW.Npers AND Ntyp = :NEW.NTyp;

    -- L'offre est pourvue, elle disparaît
    DELETE FROM OFFRE 
    WHERE Nemploi = :NEW.Nemploi;
    
END;
/



-- OFFRE (Nemploi, Nsiret, NTyp, DateDeb, DateFin, SalOffre) : Qui offre quoi ?
-- SUPPRIMER LIGNE 

-- RECHERCHE (Npers, Ntyp, DateRech) : Qui recherche quoi ?

-- Question 7 (3 pts) :
-- Ecrire un trigger Mailing, qui permet aux agences de l'ANPE d'envoyer automatiquement des mails
-- pour informer les demandeurs d'emploi (càd ceux en recherche) d'une nouvelle offre qui peut les intéresser.
-- Un tuple sera inséré pour chaque envoi de mail à faire dans la table Mailing (Nom, email, message).
-- Les mails doivent être bien ciblés, seules les personnes concernées doivent en recevoir.

CREATE OR REPLACE TRIGGER TRG_MAILING
AFTER INSERT ON OFFRE
FOR EACH ROW
BEGIN
    INSERT INTO Mailing (Nom, email, message)
    SELECT P.NomPers, P.email, 
           'Bonjour ' || P.NomPers || ', une offre de type ' || :NEW.NTyp || ' est disponible au salaire de ' || :NEW.SalOffre
    FROM PERSONNE P
    JOIN RECHERCHE R ON P.Npers = R.Npers
    WHERE R.Ntyp = :NEW.NTyp;
END;
/