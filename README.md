# Base de données Oracle : gestion d'une pharmacie

Projet de Base de Données (UE LSIN513, Université de Versailles Saint-Quentin, année).

Le but est de construire et d'exploiter une base de données sous **Oracle** pour une **pharmacie** : gestion des médicaments, du stock par lot, des commandes fournisseurs, des ordonnances, des ventes et du remboursement par les mutuelles. Le sujet complet est dans `PROJET_ORACLE.pdf`.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `PROJET_ORACLE.pdf` | Énoncé du projet (phase 1 : cahier des charges, phase 2 : implémentation) |
| `schema.sql` | Création des 11 tables (contraintes `CHECK`, clés primaires et étrangères) et jeu de données (`INSERT`) |
| `requetes.sql` | 20 requêtes d'interrogation (avec commentaire en langage naturel) |
| `vues.sql` | 7 vues, rôles et droits d'accès |
| `triggers.sql` | 8 triggers PL/SQL, avec la règle de gestion en commentaire |
| `metadonnées.sql` | Requêtes sur le dictionnaire Oracle (contraintes, triggers, nombre de lignes, relations) |
| `TennisOracle.sql` | Exercice de TD indépendant (base « tennis »), sans lien avec la pharmacie |

## Modèle de données

11 tables. Clés primaires en **gras**, clés étrangères entre parenthèses.

- **MEDICAMENT** (**code_cip**, nom, prix_public, categorie, statut_vente, laboratoire) : `statut_vente` vaut `Libre` ou `Ordonnance`.
- **MEDECIN** (**id_rpps**, prenom, nom, specialite, telephone, email)
- **PHARMACIEN** (**id_rpps**, prenom, nom, mail, adresse)
- **COUVERTURE** (**nom_mutuelle**, taux_de_remboursement) : taux entre 0 et 100.
- **CLIENT** (**nssi**, nom, prenom, adresse, contact, *nom_mutuelle*)
- **FOURNISSEUR** (**nom**, mail, numero, adresse, ville)
- **COMMANDE** (**id_commande**, date_commande, statut, prix_commande, quantite, *nom*)
- **LOT** (**num_lot**, quantite, date_peremption, date_fabrication, *nom*, *id_commande*, *code_cip*)
- **ORDONNANCE** (**id_ordonnance**, date_prescription, date_de_peremption, *id_rpps*, *nssi*)
- **LIGNEORDONNANCE** (**id_ligneordonnace**, qt_delivre, duree_trait, date_traitement, *id_medicament*, *id_ordonnance*, *id_rpps*) : `id_rpps` désigne ici le pharmacien qui a traité la ligne.
- **VENTE** (**id_vente**, datevente, prixfinal, *id_pharmacien*, *id_client*)
- **LIGNEVENTE** (**id_lignevente**, quantité_vendu, prix_après_remboursement, *id_vente*, *numero_de_lot*, *id_ordonnance*)

Les contraintes déclaratives portent notamment sur la longueur des identifiants (CIP à 12 chiffres, RPPS à 11, NSSI à 15), le format des téléphones et e-mails, les prix et quantités positifs, et la cohérence des dates d'ordonnance.

## Jeu de données

Le fichier `schema.sql` contient environ 30 n-uplets par table (clients, pharmaciens, médecins, fournisseurs, mutuelles, médicaments, commandes, lots, ordonnances, ventes). Il est conçu pour que les requêtes complexes donnent des résultats, par exemple :

- des commandes et lots de `MediNord` couvrant tous les médicaments (requête 2) ;
- des pharmaciens sans traitement d'ordonnance en décembre (requête 3) ;
- des médicaments jamais prescrits (requête 4).

Les colonnes `prix_après_remboursement` et `prixfinal` sont remplies par des `UPDATE` en fin de script.

Le sujet demande aussi un chargement massif avec **SQL\*Loader** (fichier `.ctl`). Aucun fichier de ce type n'est présent dans ce dossier.

## Requêtes (`requetes.sql`)

Les 20 requêtes utilisent entre autres : `INTERSECT`, division relationnelle (`HAVING COUNT(DISTINCT ...) = (SELECT COUNT(*) ...)`), `NOT EXISTS`, agrégats avec `GROUP BY`/`HAVING`, jointures externes (`LEFT JOIN`), sous-requêtes avec `>= ALL` ou `MAX`, `FETCH FIRST n ROWS ONLY`, et des paramètres saisis par l'utilisateur (`&nomclient`, `&id_ordonnance`).

Exemples : médicaments fournis à la fois par PharmaDis et HealthNord, top 5 des médicaments les plus vendus, quantités vendues en décembre, clients dont le taux de remboursement dépasse la moyenne, pharmaciens ayant vendu tous les médicaments, fournisseur le plus sollicité.

## Vues et droits (`vues.sql`)

| Vue | Description |
|---|---|
| `Stock_risque` | Médicaments dont le stock total est inférieur ou égal à 500 |
| `infos_ordonnance` | Ordonnances récentes avec patient, médicaments et quantités à délivrer |
| `Catalogue_Stock_medicament` | Catalogue avec stock total, date de péremption la plus proche et nombre de lots |
| `VUE_CA_MENSUEL` | Nombre de ventes et chiffre d'affaires par mois |
| `DEPENSE` | Dépenses mensuelles en commandes |
| `HISTORIQUE` | Historique d'achats d'un client |
| `Remboursement_Mutuelles` | Montant à recouvrer auprès de chaque mutuelle |

Rôles prévus : `COMPTABLE` (CA, dépenses, remboursements), `CLIENT` (son historique), `ADMINISTRATEUR`, `Gestionnaire_Commandes` et `Pharmacien`. Le script note que la création de rôles n'est pas possible sur Oracle Live ; une alternative par filtre sur le NSSI est proposée pour la vue `historique`.

## Triggers (`triggers.sql`)

1. `TRG_LIGNEVENTE_1_AUTO_LOT` : prélever le médicament dans le lot dont la péremption est la plus proche.
2. `LIGNEVENTE_CALCUL_PRIX` : calculer le prix d'une ligne selon le taux de remboursement du client.
3. `TRG_LIGNEVENTE_3_MAJ_STOCK` : décrémenter le stock du lot après une vente (erreur si stock insuffisant).
4. `Calcule_Prix_Vente` : recalculer le total de la vente après modification des lignes.
5. `verif_livraison_conforme` : vérifier qu'un lot livré correspond à la commande (avertissement si quantité différente, erreur si commande inexistante).
6. `verif_surdelivrance` : interdire de vendre plus que la quantité prescrite.
7. Validité d'ordonnance : interdire de traiter une ordonnance périmée.
8. `VERROUILLAGE_LIGNE` : interdire la modification ou suppression des lignes de vente d'un jour antérieur.

## Méta-données (`metadonnées.sql`)

- liste des triggers par table (`USER_TRIGGERS`) ;
- liste des contraintes par table avec type et corps (`USER_CONSTRAINTS`) ;
- nombre de lignes par table (`USER_TABLES`) ;
- relations entre tables via les clés étrangères (table fille, table parent, nom de la contrainte).

## Utilisation

Les scripts sont destinés à Oracle (testés selon les commentaires sur Oracle Live SQL ou la machine virtuelle Oracle). Ordre conseillé :

1. `schema.sql` : tables puis données
2. `triggers.sql`
3. `vues.sql`
4. `requetes.sql` et `metadonnées.sql`

Le bloc d'`INSERT` des lignes de vente est à exécuter **avant** de créer les triggers, sinon ceux-ci s'appliquent au chargement.

## Remarque

Certains scripts (vues, triggers, jeu de données, quelques requêtes) contiennent de petites erreurs de syntaxe ou de noms de colonnes et peuvent nécessiter des corrections avant exécution.