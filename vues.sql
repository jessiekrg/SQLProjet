-- Les scripts de création des vues, ainsi qu’une description en langage naturel de chacune, ainsi que la définition des droits d’accès : groupes utilisateurs, droits…


-- Vue stock des médicaments à risque
create view Stock_risque as
select m.nom
from medicament m
join lot l on l.CODE_CIP = m.code_cip
group by m.nom
where sum(l.Quantite) <= 40

-- Vue d’accès aux informations de l’ordonnance en cours de traitement

create view Infos_ordonnance as
select o.id_Ordonnance,
       o.date_Ordonnance,
       o.date_De_Peremption,
       c.NSSI,
       c.nom 
       c.prenom 
       c.nom_mutuelle,
       lo.id_medicament,
       lo.qt_delivre,
       lo.duree_trait,
       lo.date_traitement
from ordonnance o
join client c c.NSSI = o.NSSI
join ligneordonnance lo on o.id_ordonnance = lo.id_ordonnance
where lo.id_RPPS = :id_RPPS and o.date_traitement >= SYSDATE - 2; 

-- Vue catalogue des médicaments

create view Catalogue_Stock_medicament as
SELECT m.code_cip,
       m.nom,
       m.prix_public,
       m.Categorie,
       m.Statue_Vente,
       m.Laboratoire,
       sum(l.Quantite) as quantite_totale
from medicament m
join lot l on l.CODE_CIP = m.code_cip
group by m.code_cip, m.nom, m.prix_public, m.Categorie, m.Statue_Vente, m.Laboratoire;

-- COMPTABLE 
CREATE ROLE COMPTABLE;
GRANT SELECT ON VUE_CA_MENSUEL, Remboursement_Mutuelles, DEPENSE TO COMPTABLE;

-- VUE CA
CREATE OR REPLACE VIEW VUE_CA_MENSUEL AS
SELECT 
    TO_CHAR(datevente, 'MM-YYYY') AS MOIS, 
    COUNT(id_Vente) AS NB_VENTES,          
    SUM(PrixFinal) AS TOTAL_REVENUS        
FROM VENTE
GROUP BY TO_CHAR(datevente, 'MM-YYYY')   
ORDER BY MIN(datevente);  

GRANT SELECT ON VUE_CA_MENSUEL TO COMPTABLE;

-- VUE REMBOURSEMENT
CREATE OR REPLACE VIEW Remboursement_Mutuelles AS
SELECT MU.NOM , SUM( (M.prix_public * Lv.quantité_vendu) - LV.PRIX_APRÈS_REMBOURSEMENT) as Total_Recouvrer
FROM MEDICAMENT M 
JOIN LOT L ON L.CODE_CIP = M.CODE_CIP
JOIN LIGNEVENTE LV ON LV.numero_de_lot = L.numero_de_lot 
JOIN VENTE V ON V.id_Vente = LV.id_Vente
JOIN CLIENT CL ON CL.id_Client = V.id_Client
JOIN COUVERTURE MU ON MU.Nom_mutuelle = CL.Nom_mutuelle
GROUP BY MU.NOM;

-- VUE DES DES DEPENSES MENSUELLE 
CREATE OR REPLACE VIEW DEPENSE AS 
SELECT TO_CHAR(C.Date_Commande, 'MM-YYYY') AS MOIS, SUM(C.Prix_Commande) AS DEPENSE
FROM COMMANDE C
GROUP BY TO_CHAR(C.Date_Commande, 'MM-YYYY')
ORDER BY MIN(C.Date_Commande);

--- CLIENT -- INCERTAIN
CREATE ROLE CLIENT;
GRANT SELECT ON HISTORIQUE TO CLIENT;

CREATE OR REPLACE VIEW HISTORIQUE AS
SELECT M.NOM, M.Categorie, LV.quantité_vendu, LV.PRIX_APRÈS_REMBOURSEMENT, V.dateVente
FROM MEDICAMENT M 
JOIN LOT L on l.code_cip = m.code_cip
JOIN LIGNEVENTE LV on lv.num_lot =  l.numero_de_lot
JOIN VENTE V ON V.id_Vente = LV.id_Vente
JOIN CLIENT CL on cl.id_Client = v.id_Client
WHERE CL.NSSI = USER;


-- ADMIN
CREATE ROLE ADMINISTRATEUR
GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO ADMINISTRATEUR;
