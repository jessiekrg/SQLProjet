-- CREATION DE TABLES (ORDRE PAS DEFINI IL FAUT REARRANGER)

CREATE TABLE MEDICAMENT(
    code_cip int primary key,
    nom VARCHAR(40),
    prix_public NUMBER(40),
    Categorie VARCHCAR(40),
    Statue_Vente VARCHAR(40),
    Laboratoire VARCHAR(40)

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

CREATE TABLE ORDONNANCE(
    id_Ordonnance int primary key,
    date_Prescription date,
    date_De_Peremption date,

    Id_RRPS int,
    NSSI int,

    foreign key (Id_RPPS) references medecin(Id_RPPS),
    foreign key (NSSI) references client(NSSI),
);

CREATE TABLE MEDECIN(
    Id_RPPS int,
    Prenom varchar(40),
    Nom varchar(40),
    Specialite varchar(40),
    Telephone varcha varchar(40),
    Email varchar(40),
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

CREATE TABLE COUVERTURE(
    Numero_AMC int,
    taux_de_remboursement int,
); 

CREATE TABLE VENTE(
    
);

CREATE TABLE LIGNEORDONNANCE(
);

CREATE TABLE LOT(
);

CREATE TABLE FOURNISSEUR(
);

CREATE TABLE COMMANDE(
);


-- CREATION DU JEU DE DONNÉES (des requêtes SQL (insert))

-- corrigé

CREATE TABLE MEDICAMENT(
    code_cip int primary key,
    nom VARCHAR(40),
    prix_public int,
    Categorie VARCHAR(40),
    Statue_Vente VARCHAR(40),
    Laboratoire VARCHAR(40)
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


CREATE TABLE COUVERTURE(
    Numero_AMC int primary key,
    taux_de_remboursement int
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



CREATE TABLE MEDECIN(
    Id_RPPS int primary key,
    Prenom varchar(40),
    Nom varchar(40),
    Specialite varchar(40),
    Telephone varchar(40),
    Email varchar(40)
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



INSERT INTO MEDICAMENT VALUES (340005,"Pararacétamol", 2.18, ,)