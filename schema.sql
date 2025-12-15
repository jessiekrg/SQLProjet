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

-- Client
insert into Client values(1 99 05 75 123 456 78,"Martin","Lucas","12 rue de Rivoli, 75001 Paris","06 12 34 56 78")
insert into Client values(2 01 11 69 245 312 45,"Bernard","Emma","45 boulevard Saint-Germain, 75005 Paris","06 23 45 67 89")
insert into Client values(1 98 03 13 402 178 91,"Dubois","Hugo","8 avenue de l’Opéra, 75002 Paris","06 34 56 78 90")
insert into Client values(2 00 07 33 119 654 22,"Thomas","Léa","27 rue Oberkampf, 75011 Paris","07 11 22 33 44")
insert into Client values(1 97 12 59 321 987 10,"Robert","Nathan","1102 avenue de la République, 75011 Paris","07 22 33 44 55")
insert into Client values(2 02 01 92 210 345 66,"Richard","Camille","5 rue Mouffetard, 75005 Paris","06 98 76 54 32")
insert into Client values(1 96 06 44 111 222 33,"Petit","Thomas","60 boulevard Haussmann, 75009 Paris","07 65 43 21 09")
insert into Client values(2 03 09 31 456 789 54,"Durand","Chloé","18 rue de Belleville, 75020 Paris","06 55 66 77 88")
insert into Client values(1 95 10 84 333 444 81,"Leroy","Maxime","33 avenue des Champs-Élysées, 75008 Paris","07 88 77 66 55")
insert into Client values(2 04 02 67 555 666 09,"Moreau","Sarah","14 rue Lecourbe, 75015 Paris","06 44 33 22 11")


-- Pharmacien

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

