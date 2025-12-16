--  la question en langage naturel, suivi du script SQL.
--  la question en langage naturel, suivi du script SQL.

-- 21. Lister le fournisseur auprès duquel la pharmacie s’est procurés le plus de médicament 

SELECT F.NOM, COUNT(M.CODE_CIP) AS NOMBRE_MEDICAMENT_FOURNI
FROM FOURNISSEUR F
JOIN LOT L ON (F.NOM = L.NOM) -- INCERTAINE 
JOIN MEDICAMENT M ON (L.CODE_CIP = M.CODE_CIP)
GROUP BY F.NOM
HAVING COUNT(M.CODE_CIP)  > ALL (
    SELECT COUNT(M2.CODE_CIP)
    FROM FOURNISSEUR F2
    JOIN LOT L2 ON (F2.NOM = L2.NOM) -- INCERTAINE 
    JOIN MEDICAMENT M2 ON (L2.CODE_CIP = M2.CODE_CIP)
);

-- 11. Afficher les ventes de tous  les pharmaciens ( avec tous les pharmaciens, même ceux qui n’ont effectué aucune vente) (dans un intérêt de constat des performance)

SELECT V.id_Vente, P.id_RPPS
FROM VENTE V
LEFT JOIN PHARMACIEN P ON (P.ID_RPPS = V.ID_RPPS);

-- 1. Accéder aux infos des lots de médicaments qui sont fournis à la fois par Fournisseurs 1 et par Fournisseur 2.

SELECT DISTINCT
       M.code_cip,
       M.nom_medicament
FROM LOT L
JOIN MEDICAMENT M ON M.id_medicament = L.id_medicament
WHERE L.id_fournisseur = 1
   OR L.id_fournisseur = 2;


--  16. Lister les clients qui sont couvert par la mutuelle “Malakoff Humanis”

SELECT DISTINCT 
    C.NSSI 
FROM CLIENT CL
JOIN COUVERTURE CO ON CO.NSSI = CL.NSSI
WHERE CO.Nom_mutuelle = 'Malakoff Humanis';


-- 12.Afficher les fournisseurs qui fournissent des médicaments d’une même description trié selon un ordre spécifié comme le prix (dans un intérêt d'économie)

SELECT DISTINCT 
    F.Nom
FROM FOURNISSEUR F
JOIN LOT L ON L.NOM = F.NOM
WHERE 