--  la question en langage naturel, suivi du script SQL.
--  la question en langage naturel, suivi du script SQL.


-- 1. Accéder aux infos des médicaments qui sont fournis à la fois par Fournisseurs 1 et par Fournisseur 2.

SELECT m.Nom, m.Prix_Public
FROM MEDICAMENT m
JOIN LOT l ON l.Code_CIP = m.Code_CIP
WHERE l.Nom = 'PharmaDis'

INTERSECT

SELECT m.Nom, m.Prix_Publicx
FROM MEDICAMENT m
JOIN LOT l ON l.Code_CIP = m.Code_CIP
WHERE l.Nom = ' HealthNord';


-- 2. Afficher le nom des fournisseurs qui fournissent l’ensemble de tous les médicaments.

select f.Nom
from fournisseur f
join lot l  on l.Nom = f.Nom
group by f.Nom
having count(distinct l.CODE_CIP) = (select count(*)
                                    from medicament);

-- 3. Afficher le nom et prénom des pharmaciens qui n’ont traité  aucune ordonnance  pendant le mois d'août.

select p.nom, p.prenom
from pharmacien p
where not exists (
    select 1
    from ligneordonnance lo
    where lo.id_RPPS = p.id_RPPS and extract(month from date_traitement) = 8
);

-- 4. Médicaments qui ne sont prescrit par aucun médecin

select m.nom
from medicament m
where not exists (
    select *
    from ligneordonnance l 
    where m.code_cip = l.code_cip
);

-- 5. Afficher le nom et la quantité des médicaments qui sont encore disponible en stock 


select m.nom,sum(l.Quantite) as quantite__med_dispo
from medicament m
join lot l on l.CODE_CIP = m.code_cip
group by m.nom
having sum(l.Quantite) > 0;

-- 6. Afficher le taux de remboursement du client saisie par l’utilisateur

select c.Nom,c.Prenom,co.taux_de_remboursement
from client c
join couverture co on c.Nom_mutuelle = co.Nom_mutuelle
where c.nom = '&nomclient' and c.prenom = '&prenomclient';


-- 7. Afficher la somme moyenne dépensée pour chaque commande ( rapport entre la somme de toutes les commandes et le nombre de commandes) 

select sum(Quantite)/count(id_Commande)
from commande;

-- 8.Afficher le nom des médicaments qui ne sont pas en stock ( Aucun lot ne contient ce médicament ou quantité dans lot =0) i (dans un intérêt de gestion des approvisionnement

SELECT M.nom
FROM MEDICAMENT M
WHERE NOT EXISTS (
    SELECT *
    FROM LOT L
    WHERE L.code_cip = M.code_cip
      AND L.quantite > 0
);

-- 9. Afficher les 5 médicaments les plus (ou moins) vendus  (dans un intérêt d'économie et statistiques)


-- MA METHODE 

SELECT M.nom
FROM MEDICAMENT M
JOIN LOT L ON L.code_cip = M.code_cip
JOIN LIGNEVENTE LV ON LV.numero_de_lot = L.numero_de_lot
GROUP BY M.nom
HAVING SUM(LV.quantite_vendu) >= ALL (
    SELECT SUM(LV2.quantite_vendu)
    FROM MEDICAMENT M2
    JOIN LOT L2 ON L2.code_cip = M2.code_cip
    JOIN LIGNEVENTE LV2 ON LV2.numero_de_lot = L2.numero_de_lot
    GROUP BY M2.nom
);

-- OU SOUS REQUETE 

SELECT nom
FROM (
    SELECT M.nom, SUM(LV.quantite_vendu) AS total_vendu
    FROM MEDICAMENT M
    JOIN LOT L ON L.code_cip = M.code_cip
    JOIN LIGNEVENTE LV ON LV.numero_de_lot = L.numero_de_lot
    GROUP BY M.nom
) 
WHERE total_vendu = (
    SELECT MAX(total_vendu)
    FROM (
        SELECT SUM(LV2.quantite_vendu) AS total_vendu
        FROM MEDICAMENT M2
        JOIN LOT L2 ON L2.code_cip = M2.code_cip
        JOIN LIGNEVENTE LV2 ON LV2.numero_de_lot = L2.numero_de_lot
        GROUP BY M2.nom
    )
);


-- 10. Sélectionner les lots de médicaments dont la quantité est supérieure à 0 ET la date de péremption supérieure à celle d’aujourd’hui (dans un intérêt de gestion de la sécurité et usage des produit délivré) 
-- a verifier 

SELECT L.numero_de_lot, L.quantité
FROM LOT L
WHERE L.Quantite > 0 AND L.date_De_Peremption > SYSDATE;



-- 11. Afficher les ventes de tous  les pharmaciens ( avec tous les pharmaciens, même ceux qui n’ont effectué aucune vente) (dans un intérêt de constat des performance)

SELECT V.id_Vente, P.id_RPPS
FROM VENTE V
LEFT JOIN PHARMACIEN P ON (P.ID_RPPS = V.ID_RPPS);


-- 12.Afficher les fournisseurs qui fournissent des médicaments d’une même description trié selon un ordre spécifié comme le prix (dans un intérêt d'économie)

SELECT DISTINCT 
    F.Nom
FROM FOURNISSEUR F
JOIN LOT L ON L.NOM = F.NOM
WHERE 

-- 13. Afficher, pour une ordonnance donnée, le pharmacien qui l’a traitée, dans un objectif de traçabilité.

SELECT P.Id_RPPS, P.Nom, P.Prenom
FROM PHARMACIEN P
JOIN ORDONNANCE O ON O.Id_RPPS = P.Id_RPPS
WHERE O.id_Ordonnance = &id_ordonnance; -- on saisit l'ordonnance en question


-- 14.Calculer la quantité totale de médicament vendu pendant le mois de Septembre

SELECT M.CODE_CIP, SUM(LV.quantite_vendu) quantité_totale
FROM MEDICAMENT M
JOIN LOT L ON L.CODE_CIP = M.CODE_CIP
JOIN LIGNEVENTE LV ON LV.numero_de_lot = L.numero_de_lot ---
JOIN VENTE V ON V.id_Vente = LV.id_Vente
WHERE EXTRACT(MONTH FROM V.datevente) = 9
GROUP BY M.CODE_CIP;

-- 15.Trouver les clients dont le taux de remboursement est supérieur à la moyenne de tous les clients

SELECT CL.NSSI
FROM CLIENT CL
JOIN COUVERTURE C ON C.Nom_mutuelle = CL.Nom_mutuelle
WHERE C.taux_de_remboursement > (
    SELECT AVG(C1.taux_de_remboursement) AS moyenne
    FROM COUVERTURE C1
    JOIN CLIENT CL1 ON C1.Nom_mutuelle = CL1.Nom_mutuelle
);


--  16. Lister les clients qui sont couvert par la mutuelle “Malakoff Humanis”

SELECT DISTINCT 
    C.NSSI 
FROM CLIENT CL
JOIN COUVERTURE CO ON CO.NSSI = CL.NSSI
WHERE CO.Nom_mutuelle = 'Malakoff Humanis';

--17. Afficher les pharmaciens qui ont fait le plus de ventes le mois actuel.

SELECT p.Nom, p.Prenom, COUNT(v.id_Vente) AS nb_ventes
FROM PHARMACIEN p
JOIN VENTE v ON p.id_RPPS = v.id_Pharmacien
WHERE EXTRACT(MONTH FROM v.DateVente) = EXTRACT(MONTH FROM SYSDATE)
  AND EXTRACT(YEAR FROM v.DateVente) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY p.id_RPPS, p.Nom, p.Prenom
HAVING COUNT(v.id_Vente) = (
    SELECT MAX(nb)
    FROM (
        SELECT COUNT(*) AS nb
        FROM VENTE v2
        JOIN PHARMACIEN p2 ON v2.id_Pharmacien = p2.id_RPPS
        WHERE EXTRACT(MONTH FROM v2.DateVente) = EXTRACT(MONTH FROM SYSDATE)
          AND EXTRACT(YEAR FROM v2.DateVente) = EXTRACT(YEAR FROM SYSDATE)
        GROUP BY p2.id_RPPS
    )
);


-- 18. Liste des médicaments qui n’ont jamais été vendus 

select m.nom
from medicament m
where not exists(
    select *
    from lignevente lv
    join lot l  on l.num_lot = lv.numero_de_lot
    where l.CODE_CIP = m.code_cip
);

-- 19. Lister les pharmaciens qui ont vendus tous les médicaments 

select p.id_RPPS
from pharmacien p, vente v, lignevente lv,lot l
where v.id_Pharmacien = p.id_RPPS
and lv.id_Vente = v.id_Vente
and l.num_lot = lv.numero_de_lot
group by p.id_RPPS
having count(distinct l.CODE_CIP) = (select count(*)
                                    from medicament);

-- 20. Liste Médicaments mal remboursés (=taux de remboursement moyen des clients qui achètent ce médicament est < 50% ) 
-- mais très vendus (= top x des médicaments vendus)  triés dans un ordre sp


SELECT DISTINCT M.CODE_CIP, M.NOM
FROM (
    SELECT CL.NSSI
    FROM COUVERTURE C 
    JOIN CLIENT CL ON  CL.Nom_mutuelle = C.Nom_mutuelle
    WHERE C.taux_de_remboursement < 0.5)
    T -- client_avec_taux_de_remboursement_moyen_nul
JOIN VENTE V ON T.NSSI = V.NSSI
JOIN LIGNEVENTE LV ON LV.id_Vente = V.id_Vente
JOIN LOT L ON L.CODE_CIP = LV.CODE_CIP
JOIN MEDICAMENT M ON M.CODE_CIP = L.CODE_CIP;



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