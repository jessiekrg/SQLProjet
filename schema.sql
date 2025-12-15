-- CREATION DE TABLES (ORDRE PAS DEFINI IL FAUT REARRANGER)

CREATE TABLE MEDICAMENT(
    code_cip int primary key,
    nom VARCHAR(40),
    prix_public NUMBER(40),
    Categorie VARCHCAR(40),
    Statue_Vente VARCHAR(40),
    Laboratoire VARCHAR(40)

);



CREATE TABLE MEDECIN(
    Id_RPPS int,
    Prenom varchar(40),
    Nom varchar(40),
    Specialite varchar(40),
    Telephone varcha varchar(40),
    Email varchar(40),
);



CREATE TABLE FOURNISSEUR(
    id_Fournisseur int primary key ,
    Mail varchar(40),
    Numero  varchar(40),
    Adresse varchar(40),
    Ville varchar(40)
);

CREATE TABLE COUVERTURE(
    Numero_AMC int primary key,
    taux_de_remboursement int
); 




CREATE TABLE ORDONNANCE(
    id_Ordonnance int primary key,
    date_Prescription date,
    date_De_Peremption date,

    Id_RRPS int,
    NSSI int,

    foreign key (Id_RPPS) references medecin(Id_RPPS),
    foreign key (NSSI) references client(NSSI),
);


CREATE TABLE CLIENT(
    NSSI int,
    Nom varchar(40),
    Prenom varchar(40),
    adresse varchar(40),
    Contact varchar(40),

    Numero_AMC varchar(40),

    foreign key (Numero_AMC) references COUVERTURE(Numero_AMC),
);

CREATE TABLE LIGNEVENTE(
    id_Lignevente int primary key,
    quantité_vendu int ,
    prix_après_remboursement int,

    id_Vente int,
    numero_de_lot int,

    foreign key (id_Vente) references vente(id_Vente),
    foreign key (numero_de_lot) reference lot(numero_de_lot),
);


CREATE TABLE CLIENT(
    NSSI int primary key,
    Nom varchar(40),
    Prenom varchar(40),
    adresse varchar(40),
    Contact varchar(40),
    Numero_AMC int,

    foreign key (Numero_AMC) references COUVERTURE(Numero_AMC)
);


CREATE TABLE ORDONNANCE(
    id_Ordonnance int primary key,
    date_Prescription date,
    date_De_Peremption date,

    Id_RPPS int,
    NSSI int,

    foreign key (Id_RPPS) references medecin(Id_RPPS),
    foreign key (NSSI) references client(NSSI)
);


CREATE TABLE VENTE(
    id_Vente int primary key;
    DateVente date;
    PrixFinal int;
    id_Pharmacien ;
    id_Client;

    foreign key (id_Pharmacien) references Pharmacien(id_RPS);
    foreign key (id_Client) references Client(NSSI);
);

CREATE TABLE LIGNEORDONNANCE(
    id_ligneordonnace int primary key,
    qt_délivré int,
    dosage_med int,
    duree_trait int,
    date_traitement date,
    id_medicament int,
    id_ordonnance int,
    id_RPPS int,

    foreign key (id_medicament) references Medicament(Code_CIP),
    foreign key (id_ordonnance) references Ordonnance(id_Ordonnance),
    foreign key (id_RPPS) references Pharmacien(id_RPPS)
);



CREATE TABLE COMMANDE(
    id_Commande int primary key,
    Date_Commande date,
    Statut varchar(40),
    Prix_Commande int,
    Quantite int,
    id_Fournisseur,

    foreign key (id_Fournisseur) references Fournisseur(Id_Fournisseur)
);


CREATE TABLE LOT(
    num_lot int primary key,
    Quantite int,
    Date_Peremption date,
    Date_Fabrication date,
    Id_Fournisseur int ,
    Id_LigneVente int,
    Id_Commande int,
    CODE_CIP int,

    foreign key (Id_Fournisseur) references Fournisseur(Id_Fournisseur),
    foreign key (CODE_CIP) references Medicament(CODE_CIP),
    foreign key (Id_Commande) references Commande(id_Commande)
);


CREATE TABLE PHARMACIEN(
    id_RPPS int primary key,
    Prenom varchar(40),
    Nom varchar(40),
    Mail varchar(40),
    Adresse varchar(40)
);



-- CREATION DU JEU DE DONNÉES (des requêtes SQL (insert))


-- Couverture :

INSERT INTO COUVERTURE VALUES ('MGEN', 0.80);
INSERT INTO COUVERTURE VALUES ('MAIF', 0.70);
INSERT INTO COUVERTURE VALUES ('MACIF', 75);
INSERT INTO COUVERTURE VALUES ('Harmonie Mutuelle', 0.85);
INSERT INTO COUVERTURE VALUES ('Malakoff Humanis', 0.90);
INSERT INTO COUVERTURE VALUES ('GMF', 0.70);
INSERT INTO COUVERTURE VALUES ('Swiss Life', 0.80);
INSERT INTO COUVERTURE VALUES ('MAAF', 0.75);
INSERT INTO COUVERTURE VALUES ('Mutuelle Générale', 0.65);
INSERT INTO COUVERTURE VALUES ('AG2R La Mondiale', 0.85);
INSERT INTO COUVERTURE VALUES ('Allianz', 0.80);
INSERT INTO COUVERTURE VALUES ('AXA', 0.75);
INSERT INTO COUVERTURE VALUES ('Groupama', 0.70);
INSERT INTO COUVERTURE VALUES ('La Mutuelle Générale', 0.65);
INSERT INTO COUVERTURE VALUES ('April', 0.60);
INSERT INTO COUVERTURE VALUES ('Swisscare', 0.78);
INSERT INTO COUVERTURE VALUES ('La Médicale', 0.72);
INSERT INTO COUVERTURE VALUES ('Mutuelle Bleue', 0.74);
INSERT INTO COUVERTURE VALUES ('Santéclair', 0.68);
INSERT INTO COUVERTURE VALUES ('Mutuelle Saint-Christophe', 0.71);
INSERT INTO COUVERTURE VALUES ('Mutuelle UMC', 0.69);
INSERT INTO COUVERTURE VALUES ('Mutuelle Familiale', 0.67);
INSERT INTO COUVERTURE VALUES ('Mutuelle Générale de l’Education', 0.80);
INSERT INTO COUVERTURE VALUES ('Mutuelle Entrain', 0.66);
INSERT INTO COUVERTURE VALUES ('Mutuelle Santé Plus', 0.73);
INSERT INTO COUVERTURE VALUES ('Mutuelle Fraternelle', 0.64);
INSERT INTO COUVERTURE VALUES ('Mutuelle Humanis', 0.79);
INSERT INTO COUVERTURE VALUES ('Mutuelle Assurance Vie', 0.62);
INSERT INTO COUVERTURE VALUES ('Mutuelle Prévention', 0.70);
INSERT INTO COUVERTURE VALUES ('Mutuelle Liberté', 0.76);


-- Client
insert into Client values(199057512345678,'Martin','Lucas','12 rue de Rivoli, 75001 Paris','06 12 34 56 78','MGEN');
insert into Client values(201116924531245,'Bernard','Emma','45 boulevard Saint-Germain, 75005 Paris','06 23 45 67 89','MAIF');
insert into Client values(198031340217891,'Dubois','Hugo','8 avenue de l’Opéra, 75002 Paris','06 34 56 78 90','MACIF');
insert into Client values(200073311965422,'Thomas','Léa','27 rue Oberkampf, 75011 Paris','07 11 22 33 44','Harmonie Mutuelle');
insert into Client values(197125932198710,'Robert','Nathan','1102 avenue de la République, 75011 Paris','07 22 33 44 55','Malakoff Humanis');
insert into Client values(202019221034566,'Richard','Camille','5 rue Mouffetard, 75005 Paris','06 98 76 54 32','GMF');
insert into Client values(196064411122233,'Petit','Thomas','60 boulevard Haussmann, 75009 Paris','07 65 43 21 09','Swiss Life');
insert into Client values(203093145678954,'Durand','Chloé','18 rue de Belleville, 75020 Paris','06 55 66 77 88','MAAF');
insert into Client values(195108433344481,'Leroy','Maxime','33 avenue des Champs-Élysées, 75008 Paris','07 88 77 66 55','Mutuelle Générale');
insert into Client values(204026755566609,'Moreau','Sarah','14 rue Lecourbe, 75015 Paris','06 44 33 22 11','AG2R La Mondiale');
insert into Client values(101234567890123,'Alexandre','Durand','11 rue de Rivoli, 75001 Paris','06 12 34 56 78','MGEN');
insert into Client values(202345678901234,'Clara','Lemoine','22 rue Saint-Honoré, 75001 Paris','06 23 45 67 89','MAIF');
insert into Client values(101456789012345,'Jules','Morel','33 rue de la Paix, 75002 Paris','07 34 56 78 90','MACIF');
insert into Client values(202567890123456,'Élodie','Fabre','44 rue Saint-Denis, 75002 Paris','06 45 67 89 01','Harmonie Mutuelle');
insert into Client values(101678901234567,'Victor','Benoît','55 avenue de l’Opéra, 75001 Paris','07 56 78 90 12','Malakoff Humanis');
insert into Client values(202789012345678,'Inès','Perrin','66 rue Faubourg St-Antoine, 75011 Paris','06 67 89 01 23','GMF');
insert into Client values(101890123456789,'Louis','Rousseau','77 rue Oberkampf, 75011 Paris','07 78 90 12 34','Swiss Life');
insert into Client values(202901234567890,'Manon','Gautier','88 rue de Charonne, 75011 Paris','06 89 01 23 45','MAAF');
insert into Client values(101012345678901,'Théo','Marchal','99 rue de Belleville, 75020 Paris','07 90 12 34 56','Mutuelle Générale');
insert into Client values(202123456789012,'Sarah','Colin','12 rue Lecourbe, 75015 Paris','06 01 23 45 67','AG2R La Mondiale');
insert into Client values(101234567890124,'Hugo','Fournier','15 rue des Martyrs, 75009 Paris','06 12 34 56 78','Allianz');
insert into Client values(202345678901235,'Léa','Mercier','18 rue Saint-Jacques, 75005 Paris','07 23 45 67 89','AXA');
insert into Client values(101456789012346,'Maxime','Giraud','21 rue de Bellefond, 75009 Paris','06 34 56 78 90','Groupama');
insert into Client values(202567890123457,'Chloé','Renard','24 rue de la Santé, 75013 Paris','07 45 67 89 01','Swisscare');
insert into Client values(101678901234568,'Lucas','Brun','27 rue du Temple, 75003 Paris','06 56 78 90 12','Mutuelle Bleue');
insert into Client values(202789012345679,'Emma','Vidal','30 rue Saint-Maur, 75011 Paris','07 67 89 01 23','Mutuelle Saint-Christophe');
insert into Client values(101890123456780,'Antoine','Lopez','33 rue Oberkampf, 75011 Paris','06 78 90 12 34','Mutuelle Familiale');
insert into Client values(202901234567891,'Camille','Faure','36 rue de Turbigo, 75003 Paris','07 89 01 23 45','Mutuelle Générale de l’Education');
insert into Client values(101012345678902,'Nathan','Picard','39 rue Faubourg du Temple, 75010 Paris','06 90 12 34 56','Mutuelle Santé Plus');
insert into Client values(202123456789013,'Lola','Garnier','42 rue Saint-Denis, 75001 Paris','07 01 23 45 67','Mutuelle Humanis');
insert into Client values(101234567890125,'Mathis','Bernard','14 rue de la République, 75011 Paris','06 11 22 33 44','MGEN');
insert into Client values(202345678901236,'Anaïs','Petit','17 rue de la Roquette, 75011 Paris','07 22 33 44 55','MAIF');




-- Pharmaciens

insert into Pharmacien values (10000000001,"Julien","Lefèvre","06 41 23 58 91","18 rue de la Roquette, 75011 Paris")
insert into Pharmacien values (10000000012,"Marie","Morel","07 52 14 69 30","42 rue Oberkampf, 75011 Paris")
insert into Pharmacien values (10000000023,"Antoine","Girard","06 78 34 12 56","9 rue Mouffetard, 75005 Paris")
insert into Pharmacien values (10000000034,"Claire","Fontaine","07 61 90 45 28","27 rue Monge, 75005 Paris")
insert into Pharmacien values (10000000045,"Nicolas","Roux","06 25 87 49 63","65 rue de Vaugirard, 75006 Paris")
insert into Pharmacien values (10000000056,"Sophie","Lambert","07 38 56 71 04","12 rue Monsieur-le-Prince, 75006 Paris")
insert into Pharmacien values (10000000067,"Paul","Blanchard","006 93 12 40 85","88 rue de Belleville, 75020 Paris")
insert into Pharmacien values (10000000078,"Laura","Chevalier","07 44 68 29 51","15 rue des Pyrénées, 75020 Paris")
insert into Pharmacien values (10000000089,"Vincent","Perrin","06 59 73 84 12","31 boulevard Voltaire, 75011 Paris")
insert into Pharmacien values (10000000090,"Émilie","Marchand","07 26 95 31 47","7 rue Saint-Jacques, 75005 Paris")
insert into Pharmacien values (10000000301,'Gabriel','Martin','06 21 43 65 87','44 rue de la Roquette, 75011 Paris');
insert into Pharmacien values (10000000312,'Julie','Dubois','07 32 54 76 98','46 rue Oberkampf, 75011 Paris');
insert into Pharmacien values (10000000101,'Mathieu','Benoît','06 12 34 56 78','20 rue Saint-Honoré, 75001 Paris');
insert into Pharmacien values (10000000112,'Camille','Fournier','07 23 45 67 89','25 rue du Faubourg Saint-Honoré, 75008 Paris');
insert into Pharmacien values (10000000123,'Lucas','Gautier','06 34 56 78 90','18 rue du Temple, 75003 Paris');
insert into Pharmacien values (10000000134,'Clara','Renard','07 45 67 89 01','32 rue Saint-Denis, 75001 Paris');
insert into Pharmacien values (10000000145,'Hugo','Faure','06 56 78 90 12','10 rue de la Paix, 75002 Paris');
insert into Pharmacien values (10000000156,'Léa','Brun','07 67 89 01 23','12 rue de Rivoli, 75001 Paris');
insert into Pharmacien values (10000000167,'Antoine','Picard','06 78 90 12 34','45 rue Oberkampf, 75011 Paris');
insert into Pharmacien values (10000000178,'Élodie','Marchal','07 89 01 23 45','28 rue de Charonne, 75011 Paris');
insert into Pharmacien values (10000000189,'Maxime','Lopez','06 90 12 34 56','50 rue du Faubourg Saint-Antoine, 75011 Paris');
insert into Pharmacien values (10000000190,'Sarah','Colin','07 01 23 45 67','14 rue de la Roquette, 75011 Paris');
insert into Pharmacien values (10000000201,'Nathan','Giraud','06 11 22 33 44','17 rue Saint-Maur, 75011 Paris');
insert into Pharmacien values (10000000212,'Emma','Vidal','07 22 33 44 55','19 rue Saint-Jacques, 75005 Paris');
insert into Pharmacien values (10000000223,'Théo','Fournier','06 33 44 55 66','22 rue de Belleville, 75020 Paris');
insert into Pharmacien values (10000000234,'Manon','Bernard','07 44 55 66 77','24 rue des Pyrénées, 75020 Paris');
insert into Pharmacien values (10000000245,'Louis','Durand','06 55 66 77 88','30 boulevard Voltaire, 75011 Paris');
insert into Pharmacien values (10000000256,'Chloé','Faure','07 66 77 88 99','33 rue Oberkampf, 75011 Paris');
insert into Pharmacien values (10000000267,'Alexandre','Petit','06 77 88 99 00','35 rue de la Roquette, 75011 Paris');
insert into Pharmacien values (10000000278,'Lola','Renault','07 88 99 00 11','37 rue de Charonne, 75011 Paris');
insert into Pharmacien values (10000000289,'Vincent','Leclerc','06 99 00 11 22','40 rue Saint-Denis, 75001 Paris');
insert into Pharmacien values (10000000290,'Émilie','Roux','07 00 11 22 33','42 rue de Rivoli, 75001 Paris');

