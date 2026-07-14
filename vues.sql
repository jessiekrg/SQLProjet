-- Les scripts de création des vues, ainsi qu’une description en langage naturel de chacune, ainsi que la définition des droits d’accès : groupes utilisateurs, droits…


-- Vue 1. : Vue des médicaments dont le stock est faible et présente un risque de rupture
create view Stock_risque as    
select m.nom
from medicament m
join lot l on l.CODE_CIP = m.code_cip
group by m.nom
having sum(l.Quantite) <= 500;


-- Vue 2. : Vue affichant les informations détaillées des ordonnances actuellement en cours de traitement, incluant les patients, les médicaments prescrits et les quantités à délivrer

create or replace view infos_ordonnance as      
select o.id_ordonnance,
       o.date_prescription as date_ordonnance,
       o.date_de_peremption,
       c.nssi,
       c.nom,
       c.prenom,
       c.nom_mutuelle,
       lo.id_medicament,
       lo.qt_delivre,
       lo.duree_trait,
       lo.date_traitement,
       lo.id_rpps
from ordonnance o
join client c on c.nssi = o.nssi
join ligneordonnance lo on o.id_ordonnance = lo.id_ordonnance
where lo.date_traitement >= sysdate - 2;


-- Vue 3. : Vue centralisée du catalogue des médicaments, incluant caractéristiques et disponibilité en stock

create view Catalogue_Stock_medicament as
SELECT m.code_cip,              
       m.nom,
       m.prix_public,
       m.Categorie,
       m.Statue_Vente,
       m.Laboratoire,
       sum(l.Quantite) as quantite_totale,
       min(l.date_peremption) as date_peremption_proche,
       count(l.num_lot) as nombre_lots
from medicament m
join lot l on l.CODE_CIP = m.code_cip
group by m.code_cip, m.nom, m.prix_public, m.Categorie, m.Statue_Vente, m.Laboratoire;


-- Vue 4. : Vue des ventes et du chiffre d’affaires mensuel
CREATE OR REPLACE VIEW VUE_CA_MENSUEL AS      
SELECT 
    TO_CHAR(datevente, 'MM-YYYY') AS MOIS,   
    COUNT(id_Vente) AS NB_VENTES,          
    SUM(PrixFinal) AS TOTAL_REVENUS        
FROM VENTE
GROUP BY TO_CHAR(datevente, 'MM-YYYY')   
ORDER BY MIN(datevente);  

GRANT SELECT ON VUE_CA_MENSUEL TO COMPTABLE;


-- Vue 5. : Vue des dépenses mensuelles des commandes de la pharmacie
CREATE OR REPLACE VIEW DEPENSE AS 
SELECT TO_CHAR(C.Date_Commande, 'MM-YYYY') AS MOIS, SUM(C.Prix_Commande) AS DEPENSE    
FROM COMMANDE C
GROUP BY TO_CHAR(C.Date_Commande, 'MM-YYYY')
ORDER BY MIN(C.Date_Commande);


-- Vue 6 : Vue qui permet à un client de consulter son historique personnel de ventes
CREATE OR REPLACE VIEW HISTORIQUE AS
SELECT M.NOM, M.Categorie, LV.quantité_vendu, LV.PRIX_APRÈS_REMBOURSEMENT, V.dateVente 
FROM MEDICAMENT M 
JOIN LOT L on l.code_cip = m.code_cip
JOIN LIGNEVENTE LV on lv.numero_de_lot =  l.num_lot
JOIN VENTE V ON V.id_Vente = LV.id_Vente
JOIN CLIENT CL on cl.NSSI = v.id_Client
WHERE CL.NSSI = USER;


--> Nous sommes sur oracle live, on ne peut pas créer de ROLE. Voici une alternative

CREATE OR REPLACE VIEW historique AS
SELECT m.nom,
       m.categorie,
       lv.quantité_vendu,
       lv.prix_après_remboursement,
       v.datevente,
       cl.nssi
FROM medicament m
JOIN lot l ON l.code_cip = m.code_cip
JOIN lignevente lv ON lv.numero_de_lot = l.numero_de_lot
JOIN vente v ON v.id_vente = lv.id_vente
JOIN client cl ON cl.nssi = v.id_client;

SELECT *
FROM historique
WHERE nssi = &nssi;

-- Vue 7 : Montant total des remboursements dus par chaque mutuelle à la pharmacie

CREATE OR REPLACE VIEW Remboursement_Mutuelles AS
SELECT C.Nom_mutuelle , SUM( (M.prix_public * Lv.quantité_vendu) - LV.PRIX_APRÈS_REMBOURSEMENT) as Total_Recouvrer
FROM MEDICAMENT M 
JOIN LOT L ON L.CODE_CIP = M.CODE_CIP
JOIN LIGNEVENTE LV ON LV.numero_de_lot = L.num_lot 
JOIN VENTE V ON V.id_Vente = LV.id_Vente
JOIN CLIENT CL ON CL.NSSI = V.id_Client
JOIN COUVERTURE C ON C.Nom_mutuelle = CL.Nom_mutuelle
GROUP BY C.Nom_mutuelle; 



-- COMPTABLE 
CREATE ROLE COMPTABLE;
GRANT SELECT ON VUE_CA_MENSUEL, Remboursement_Mutuelles, DEPENSE TO COMPTABLE;

--- CLIENT -- INCERTAIN
CREATE ROLE CLIENT;
GRANT SELECT ON HISTORIQUE TO CLIENT;


-- ADMIN
CREATE ROLE ADMINISTRATEUR
GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO ADMINISTRATEUR;
GRANT CREATE USER, DROP USER, CREATE ROLE TO ADMINISTRATEUR;

-- Gestionnaire des Commandes

create role Gestionnaire_Commandes
grant select on Stock_risque,Catalogue_Stock_medicament to Gestionnaire_Commandes;
grant select,insert on LIGNEORDONNANCE,LIGNEVENTE to Gestionnaire_Commandes;
grant select on on medicament,lot,fournisseur to Gestionnaire_Commandes;


create role Pharmacien
grant select on Stock_risque,Catalogue_Stock_medicament,Infos_ordonnance to Gestionnaire_Commandes;
grant select,insert on LIGNEORDONNANCE,LIGNEVENTE to Gestionnaire_Commandes;
grant select on on medicament,lot,fournisseur to Gestionnaire_Commandes;