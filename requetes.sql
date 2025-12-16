--  la question en langage naturel, suivi du script SQL.
--  la question en langage naturel, suivi du script SQL.


-- 1. Accéder aux infos des médicaments qui sont fournis à la fois par Fournisseurs 1 et par Fournisseur 2.

SELECT m.Nom, m.Prix_Public
FROM MEDICAMENT m
JOIN LOT l ON l.Code_CIP = m.Code_CIP
WHERE l.Nom = 'PharmaDis'

INTERSECT

SELECT m.Nom, m.Prix_Public
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