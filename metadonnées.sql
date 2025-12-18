-- Script : liste_ora_triggers.sql
SELECT 
    TABLE_NAME AS "TABLES"
    TRIGGER_NAME AS "TRIGGERS"
    TRIGGER_TYPE AS "TYPE DU TIGGER"
    TRIGGERING_EVENT AS "DECLENCHEMENT" 
FROM USER_TRIGGERS;

-- Script : liste_ora_constraints.sql

SELECT 
    TABLE_NAME AS "TABLES"
    CONSTRAINT_NAME AS "NOM"
    CONSTRAINT_TYPE AS "TYPE DE LA CONTRAINTE"
    SEARCH_CONDITION AS "CORPS" 
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('MEDICAMENT', 'MEDECIN', 'FOURNISSEUR', 'COUVERTURE', 'CLIENT', 'ORDONNANCE', 'VENTE', 'LOT', 'LIGNEVENTE');

-- On fait un where pour constraint car oracle affichera autrement toutes les contraintes du système 
-- genre on avoir jsp combien de lignes et colonnes, 
-- genre des table interne qui ne sont pas propres au projet


-- on ne fait where pas pour trigger car oracle n'a pas de trigger "système" caché 'im cached".

-- Script : d’interrogation pertinents 1 (évaluer le nombre de lignes pour chacune des tables)

SELECT 
    TABLE_NAME AS "TABLE"
    NUM_ROWS AS "LIGNES"
FROM USER_TABLES;

-- Script : d’interrogation pertinents 2 (évaluer la validité de nos jointures ?? occupation disque??, date_creation_tables...;)
