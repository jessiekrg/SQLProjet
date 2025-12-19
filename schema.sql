-- CREATION DE TABLES (ORDRE PAS DEFINI IL FAUT REARRANGER)


DROP TABLE LIGNEVENTE CASCADE CONSTRAINTS;
DROP TABLE VENTE CASCADE CONSTRAINTS;
DROP TABLE ORDONNANCE CASCADE CONSTRAINTS;
DROP TABLE LOT CASCADE CONSTRAINTS;
DROP TABLE MEDICAMENT CASCADE CONSTRAINTS;
DROP TABLE CLIENT CASCADE CONSTRAINTS;
DROP TABLE COUVERTURE CASCADE CONSTRAINTS;
DROP TABLE PHARMACIEN CASCADE CONSTRAINTS;
DROP TABLE LIGNEORDONNANCE CASCADE CONSTRAINTS;
DROP TABLE MEDECIN CASCADE CONSTRAINTS;
DROP TABLE FOURNISSEUR CASCADE CONSTRAINTS;
DROP TABLE COMMANDE CASCADE CONSTRAINTS;


CREATE TABLE MEDICAMENT(
    code_cip NUMBER primary key,
    nom VARCHAR(40),
    prix_public number(8,2),
    Categorie VARCHAR(40),
    Statut_Vente VARCHAR(40), 
    Laboratoire VARCHAR(40),

    CONSTRAINT check_code_cip CHECK (LENGTH(TO_CHAR(code_cip)) = 12),
    CONSTRAINT check_prix_public CHECK (prix_public > 0),
    CONSTRAINT check_statut_vente CHECK (Statut_Vente IN ('Libre','Ordonnance'))
);


CREATE TABLE MEDECIN(
    Id_RPPS NUMBER primary key,
    Prenom varchar(40),
    Nom varchar(40),
    Specialite varchar(40),
    Telephone varchar(40),
    Email varchar(40),

    CONSTRAINT check_Id_RPPS CHECK (LENGTH(TO_CHAR(Id_RPPS)) = 11),
    CONSTRAINT check_Telephone CHECK (LENGTH(Telephone) = 10),
    CONSTRAINT check_Email CHECK (Email LIKE '%_@_%._%')
);



CREATE TABLE FOURNISSEUR(
    Nom VARCHAR(40) primary key ,
    Mail varchar(40),
    Numero  varchar(40),
    Adresse varchar(40),
    Ville varchar(40)
);

CREATE TABLE COUVERTURE(
    Nom_mutuelle varchar(40) primary key,
    taux_de_remboursement number(3,0),

    CONSTRAINT check_Remboursement CHECK (taux_de_remboursement BETWEEN 0 AND 100)
); 



CREATE TABLE CLIENT(
    NSSI NUMBER primary key,
    Nom varchar(40),
    Prenom varchar(40),
    adresse varchar(40),
    Contact varchar(40),
    Nom_mutuelle varchar(40),

    foreign key (Nom_mutuelle) references COUVERTURE(Nom_mutuelle),

    CONSTRAINT check_NSSI CHECK (LENGTH(TO_CHAR(NSSI)) = 15),
    CONSTRAINT check_Contact CHECK (LENGTH((Contact))= 10)
);

CREATE TABLE ORDONNANCE(
    id_Ordonnance NUMBER primary key,
    date_Prescription date,
    date_De_Peremption date,

    Id_RPPS NUMBER,
    NSSI NUMBER,

    foreign key (Id_RPPS) references medecin(Id_RPPS),
    foreign key (NSSI) references client(NSSI),

    CONSTRAINT check_id_Ordonnance CHECK (LENGTH(TO_CHAR(id_Ordonnance)) = 11),
    CONSTRAINT check_date_ordonnance CHECK (date_Prescription < date_De_Peremption)
);

CREATE TABLE PHARMACIEN(
    id_RPPS NUMBER primary key,
    Prenom varchar(40),
    Nom varchar(40),
    Mail varchar(40),
    Adresse varchar(40)
);


CREATE TABLE VENTE(
    id_Vente NUMBER primary key,
    DateVente date,
    PrixFinal NUMBER(8,2),
    id_Pharmacien NUMBER,
    id_Client NUMBER,

    foreign key (id_Pharmacien) references Pharmacien(id_RPPS),
    foreign key (id_Client) references Client(NSSI),

    CONSTRAINT check_prixfinal CHECK (PrixFinal >= 0)
);


CREATE TABLE LOT(
    num_lot NUMBER primary key,
    Quantite NUMBER,
    Date_Peremption date,
    Date_Fabrication date,
    Nom VARCHAR(40) ,

    Id_LigneVente NUMBER,
    Id_Commande NUMBER,
    CODE_CIP NUMBER,

    foreign key (Nom) references Fournisseur(Nom),
    foreign key (CODE_CIP) references Medicament(CODE_CIP),
    foreign key (Id_Commande) references Commande(id_Commande)
);


CREATE TABLE LIGNEVENTE(
    id_Lignevente NUMBER primary key,
    quantité_vendu NUMBER ,
    prix_après_remboursement number(8,2),

    id_Vente NUMBER,
    numero_de_lot NUMBER,
    id_ordonnance NUMBER,

    foreign key (id_Vente) references vente(id_Vente),
    foreign key (numero_de_lot) references lot(num_lot),
    foreign key (id_ordonnance) references ordonnance(id_Ordonnance),

    CONSTRAINT check_quantite_vendu CHECK (quantite_vendu >= 0),
    CONSTRAINT check_prix_apres_remboursement CHECK (prix_apres_remboursement >= 0)
);



CREATE TABLE LIGNEORDONNANCE(
    id_ligneordonnace NUMBER primary key,
    qt_delivre NUMBER,
    duree_trait NUMBER,
    date_traitement date,
    id_medicament NUMBER,
    id_ordonnance NUMBER,
    id_RPPS NUMBER,

    foreign key (id_medicament) references Medicament(Code_CIP),
    foreign key (id_ordonnance) references Ordonnance(id_Ordonnance),
    foreign key (id_RPPS) references Pharmacien(id_RPPS),

    CONSTRAINT check_qt_delivre CHECK (qt_delivre > 0),
    CONSTRAINT check_duree_trait CHECK (duree_trait > 0)
);


CREATE TABLE COMMANDE(
    id_Commande NUMBER primary key,
    Date_Commande date,
    Statut varchar(40),
    Prix_Commande NUMBER,
    Quantite NUMBER,
    Nom VARCHAR(40),

    foreign key (Nom) references Fournisseur(Nom)
);






-- CREATION DU JEU DE DONNÉES (des requêtes SQL (insert))


-- Couverture :

INSERT INTO COUVERTURE VALUES ('MGEN', 80);
INSERT INTO COUVERTURE VALUES ('MAIF', 70);
INSERT INTO COUVERTURE VALUES ('MACIF', 75);
INSERT INTO COUVERTURE VALUES ('Harmonie Mutuelle', 85);
INSERT INTO COUVERTURE VALUES ('Malakoff Humanis', 90);
INSERT INTO COUVERTURE VALUES ('GMF', 70);
INSERT INTO COUVERTURE VALUES ('Swiss Life', 80);
INSERT INTO COUVERTURE VALUES ('MAAF', 75);
INSERT INTO COUVERTURE VALUES ('Mutuelle Générale', 65);
INSERT INTO COUVERTURE VALUES ('AG2R La Mondiale', 85);
INSERT INTO COUVERTURE VALUES ('Allianz', 80);
INSERT INTO COUVERTURE VALUES ('AXA', 75);
INSERT INTO COUVERTURE VALUES ('Groupama', 70);
INSERT INTO COUVERTURE VALUES ('La Mutuelle Générale', 65);
INSERT INTO COUVERTURE VALUES ('April', 60);
INSERT INTO COUVERTURE VALUES ('Swisscare', 78);
INSERT INTO COUVERTURE VALUES ('La Médicale', 72);
INSERT INTO COUVERTURE VALUES ('Mutuelle Bleue', 74);
INSERT INTO COUVERTURE VALUES ('Santéclair', 68);
INSERT INTO COUVERTURE VALUES ('Mutuelle Saint-Christophe', 71);
INSERT INTO COUVERTURE VALUES ('Mutuelle UMC', 69);
INSERT INTO COUVERTURE VALUES ('Mutuelle Familiale', 67);
INSERT INTO COUVERTURE VALUES ('Mutuelle Générale de l’Education', 80);
INSERT INTO COUVERTURE VALUES ('Mutuelle Entrain', 66);
INSERT INTO COUVERTURE VALUES ('Mutuelle Santé Plus', 73);
INSERT INTO COUVERTURE VALUES ('Mutuelle Fraternelle', 64);
INSERT INTO COUVERTURE VALUES ('Mutuelle Humanis', 79);
INSERT INTO COUVERTURE VALUES ('Mutuelle Assurance Vie', 62);
INSERT INTO COUVERTURE VALUES ('Mutuelle Prévention', 70);
INSERT INTO COUVERTURE VALUES ('Mutuelle Liberté', 76);


-- Client
insert into Client values(199057512345678,'Martin','Lucas','12 rue de Rivoli 75001 Paris','06 12 34 56 78','MGEN');
insert into Client values(201116924531245,'Bernard','Emma','45 boulevard Saint-Germain, 75005 Paris','06 23 45 67 89','MAIF');
insert into Client values(198031340217891,'Dubois','Hugo','8 avenue de Opéra, 75002 Paris','06 34 56 78 90','MACIF');
insert into Client values(200073311965422,'Thomas','Léa','27 rue Oberkampf, 75011 Paris','07 11 22 33 44','Harmonie Mutuelle');
insert into Client values(197125932198710,'Robert','Nathan','1102 avenue de la République, 75011 Paris','07 22 33 44 55','Malakoff Humanis');
insert into Client values(202019221034566,'Richard','Camille','5 rue Mouffetard 75005 Paris','06 98 76 54 32','GMF');
insert into Client values(196064411122233,'Petit','Thomas','60 boulevard Haussmann, 75009 Paris','07 65 43 21 09','Swiss Life');
insert into Client values(203093145678954,'Durand','Chloé','18 rue de Belleville 75020 Paris','06 55 66 77 88','MAAF');
insert into Client values(195108433344481,'Leroy','Maxime','33 avenue des Champs-Élysées, 75008 Paris','07 88 77 66 55','Mutuelle Générale');
insert into Client values(204026755566609,'Moreau','Sarah','14 rue Lecourbe 75015 Paris','06 44 33 22 11','AG2R La Mondiale');
insert into Client values(101234567890123,'Durand','Alexandre','11 rue de Rivoli 75001 Paris','06 12 34 56 78','MGEN');
insert into Client values(202345678901234,'Lemoine','Clara','22 rue Saint-Honoré 75001 Paris','06 23 45 67 89','MAIF');
insert into Client values(101456789012345,'Morel','Jules','33 rue de la Paix 75002 Paris','07 34 56 78 90','MACIF');
insert into Client values(202567890123456,'Fabre','Élodie','44 rue Saint-Denis 75002 Paris','06 45 67 89 01','Harmonie Mutuelle');
insert into Client values(101678901234567,'Benoît','Victor','55 avenue de Opéra, 75001 Paris','07 56 78 90 12','Malakoff Humanis');
insert into Client values(202789012345678,'Perrin','Inès','66 rue Faubourg St-Antoine 75011 Paris','06 67 89 01 23','GMF');
insert into Client values(101890123456789,'Rousseau','Louis','77 rue Oberkampf 75011 Paris','07 78 90 12 34','Swiss Life');
insert into Client values(202901234567890,'Gautier','Manon','88 rue de Charonne 75011 Paris','06 89 01 23 45','MAAF');
insert into Client values(101012345678901,'Marchal','Théo','99 rue de Belleville 75020 Paris','07 90 12 34 56','Mutuelle Générale');
insert into Client values(202123456789012,'Colin','Sarah','12 rue Lecourbe 75015 Paris','06 01 23 45 67','AG2R La Mondiale');
insert into Client values(101234567890124,'Fournier','Hugo','15 rue des Martyrs 75009 Paris','06 12 34 56 78','Allianz');
insert into Client values(202345678901235,'Mercier','Léa','18 rue Saint-Jacques 75005 Paris','07 23 45 67 89','AXA');
insert into Client values(101456789012346,'Giraud','Maxime','21 rue de Bellefond 75009 Paris','06 34 56 78 90','Groupama');
insert into Client values(202567890123457,'Renard','Chloé','24 rue de la Santé 75013 Paris','07 45 67 89 01','Swisscare');
insert into Client values(101678901234568,'Brun','Lucas','27 rue du Temple 75003 Paris','06 56 78 90 12','Mutuelle Bleue');
insert into Client values(202789012345679,'Vidal','Emma','30 rue Saint-Maur 75011 Paris','07 67 89 01 23','Mutuelle Saint-Christophe');
insert into Client values(101890123456780,'Lopez','Antoine','33 rue Oberkampf 75011 Paris','06 78 90 12 34','Mutuelle Familiale');
insert into Client values(202901234567891,'Faure','Camille','36 rue de Turbigo 75003 Paris','07 89 01 23 45','Mutuelle Générale de l’Education');
insert into Client values(101012345678902,'Picard','Nathan','39 rue Faubourg du Temple 75010 Paris','06 90 12 34 56','Mutuelle Santé Plus');
insert into Client values(202123456789013,'Garnier','Lola','42 rue Saint-Denis 75001 Paris','07 01 23 45 67','Mutuelle Humanis');
insert into Client values(101234567890125,'Bernard','Mathis','14 rue de la République 75011 Paris','06 11 22 33 44','MGEN');
insert into Client values(202345678901236,'Petit','Anaïs','17 rue de la Roquette 75011 Paris','07 22 33 44 55','MAIF');

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
insert into Pharmacien values (10000000123,'Lucas','Gautier','06 34 56 78 90','18 rue du Temple, 75003 Paris');
insert into Pharmacien values (10000000134,'Clara','Renard','07 45 67 89 01','32 rue Saint-Denis, 75001 Paris');
insert into Pharmacien values (10000000145,'Hugo','Faure','06 56 78 90 12','10 rue de la Paix, 75002 Paris');
insert into Pharmacien values (10000000156,'Léa','Brun','07 67 89 01 23','12 rue de Rivoli, 75001 Paris');
insert into Pharmacien values (10000000167,'Antoine','Picard','06 78 90 12 34','45 rue Oberkampf, 75011 Paris');
insert into Pharmacien values (10000000178,'Élodie','Marchal','07 89 01 23 45','28 rue de Charonne, 75011 Paris');
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

-- Médecinss

INSERT INTO MEDECIN
(Id_RPPS, Prenom, Nom, Specialite, Telephone, Email)
VALUES
('10101234567', 'Alice', 'Martin', 'Cardiologie', '0612345678', 'alice.martin@hopital.fr'),
('10102345678', 'Karim', 'Benali', 'Dermatologie', '0623456789', 'karim.benali@hopital.fr'),
('10103456789', 'Fatou', 'Diallo', 'Pédiatrie', '0634567890', 'fatou.diallo@hopital.fr'),
('10104567890', 'Lucas', 'Dupont', 'Médecine générale', '0645678901', 'lucas.dupont@hopital.fr'),
('10105678901', 'Leila', 'Haddad', 'Gynécologie', '0656789012', 'leila.haddad@hopital.fr'),
('10106789012', 'Thomas', 'Bernard', 'Neurologie', '0667890123', 'thomas.bernard@hopital.fr'),
('10107890123', 'Aissata', 'Kone', 'Ophtalmologie', '0678901234', 'aissata.kone@hopital.fr'),
('10108901234', 'Youssef', 'Omar', 'Radiologie', '0689012345', 'youssef.omar@hopital.fr'),
('10109012345', 'Nadia', 'Lefevre', 'Endocrinologie', '0690123456', 'nadia.lefevre@hopital.fr'),
('10110123456', 'Julien', 'Moreau', 'Chirurgie', '0601234567', 'julien.moreau@hopital.fr'),
('10111234567', 'Samira', 'Boukari', 'Psychiatrie', '0613456789', 'samira.boukari@hopital.fr'),
('10112345678', 'Antoine', 'Renaud', 'ORL', '0624567890', 'antoine.renaud@hopital.fr'),
('10113456789', 'Mariam', 'Sow', 'Oncologie', '0635678901', 'mariam.sow@hopital.fr'),
('10114567890', 'Pierre', 'Lambert', 'Urologie', '0646789012', 'pierre.lambert@hopital.fr'),
('10115678901', 'Imane', 'El Amrani', 'Néphrologie', '0657890123', 'imane.elamrani@hopital.fr'),
('10116789012', 'Nicolas', 'Faure', 'Rhumatologie', '0668901234', 'nicolas.faure@hopital.fr'),
('10117890123', 'Amina', 'Cherif', 'Hématologie', '0679012345', 'amina.cherif@hopital.fr'),
('10118901234', 'Maxime', 'Giraud', 'Gastro-entérologie', '0680123456', 'maxime.giraud@hopital.fr'),
('10119012345', 'Rania', 'Hassan', 'Pneumologie', '0691234567', 'rania.hassan@hopital.fr'),
('10120123456', 'David', 'Cohen', 'Anesthésie', '0602345678', 'david.cohen@hopital.fr'),
('10121234567', 'Sofia', 'Alves', 'Médecine interne', '0614567890', 'sofia.alves@hopital.fr'),
('10122345678', 'Mehdi', 'Zaoui', 'Urgences', '0625678901', 'mehdi.zaoui@hopital.fr'),
('10123456789', 'Claire', 'Perrin', 'Immunologie', '0636789012', 'claire.perrin@hopital.fr'),
('10124567890', 'Omar', 'Belkacem', 'Gériatrie', '0647890123', 'omar.belkacem@hopital.fr'),
('10125678901', 'Élodie', 'Marchand', 'Nutrition', '0658901234', 'elodie.marchand@hopital.fr'),
('10126789012', 'Ibrahim', 'Keita', 'Médecine du sport', '0669012345', 'ibrahim.keita@hopital.fr'),
('10127890123', 'Laura', 'Benoit', 'Allergologie', '0670123456', 'laura.benoit@hopital.fr'),
('10128901234', 'Hamza', 'Saidi', 'Infectiologie', '0681234567', 'hamza.saidi@hopital.fr'),
('10130000001', 'Paul', 'Dumont', 'Médecine générale', '0692345678', 'paul.dumont@hopital.fr'),
('10130000002', 'Noura', 'Aziz', 'Cardiologie', '0673456789', 'noura.aziz@hopital.fr');



UPDATE MEDECIN
SET Specialite = 'Médecine générale'
WHERE Id_RPPS IN (
  '10101234567',
  '10102345678',
  '10103456789',
  '10104567890',
  '10105678901',
  '10106789012',
  '10107890123',
  '10108901234',
  '10109012345',
  '10110123456',
  '10111234567',
  '10112345678',
  '10113456789',
  '10114567890'
);

-- FOURNISSEURS 

INSERT INTO FOURNISSEUR (Nom ,Mail,Numero,Adresse ,Ville) VALUES 
('PharmaDis', 'contact@pharmadis.fr', '0145678901', '12 rue des Pharmaciens', 'Paris'),
('MediLux', 'info@medilux.fr', '0156789012', '8 avenue de la Santé', 'Paris'),
('BioCare', 'contact@biocare.fr', '0167890123', '25 boulevard Pasteur', 'Paris'),
('PharmaTech', 'support@pharmatech.fr', '0178901234', '3 rue des Laboratoires', 'Paris'),
('Medexia', 'vente@medexia.fr', '0189012345', '40 rue Saint-Jacques', 'Paris'),
('PharmaSud', 'contact@pharmasud.fr', '0491234567', '15 avenue du Prado', 'Marseille'),
('MediSud', 'info@medisud.fr', '0492345678', '6 rue de la Canebière', 'Marseille'),
('BioHealth', 'vente@biohealth.fr', '0493456789', '22 boulevard Michelet', 'Marseille'),
('PharmaPlus', 'support@pharmaplus.fr', '0494567890', '9 rue Paradis', 'Marseille'),
('MediLog', 'contact@medilog.fr', '0495678901', '31 avenue du Littoral', 'Marseille'),
('PharmaLyon', 'contact@pharmalyon.fr', '0478123456', '18 rue de la République', 'Lyon'),
('MediLyon', 'info@medilyon.fr', '0478234567', '5 rue Victor Hugo', 'Lyon'),
('BioLyon', 'vente@biolyon.fr', '0478345678', '27 cours Lafayette', 'Lyon'),
('LyonPharma', 'support@lyonpharma.fr', '0478456789', '14 rue Garibaldi', 'Lyon'),
('HealthLyon', 'contact@healthlyon.fr', '0478567890', '33 avenue Jean Jaurès', 'Lyon'),
('PharmaNord', 'contact@pharmanord.fr', '0320123456', '10 rue Nationale', 'Lille'),
('MediNord', 'info@medinord.fr', '0320234567', '21 rue Faidherbe', 'Lille'),
('NordBio', 'vente@nordbio.fr', '0320345678', '7 boulevard Vauban', 'Lille'),
('LillePharma', 'support@lillepharma.fr', '0320456789', '19 rue Solférino', 'Lille'),
('HealthNord', 'contact@healthnord.fr', '0320567890', '28 rue de Béthune', 'Lille'),
('PharmaTLS', 'contact@pharmatoulouse.fr', '0561123456', '11 rue d’Alsace', 'Toulouse'),
('MediTLS', 'info@meditoulouse.fr', '0561234567', '4 boulevard Carnot', 'Toulouse'),
('BioTLS', 'vente@biotls.fr', '0561345678', '26 rue du Taur', 'Toulouse'),
('TLSPharma', 'support@toulousepharma.fr', '0561456789', '9 allée Jean Jaurès', 'Toulouse'),
('HealthTLS', 'contact@healthtls.fr', '0561567890', '35 rue Matabiau', 'Toulouse'),
('PharmaBDX', 'contact@pharmabdx.fr', '0556123456', '6 cours de l’Intendance', 'Bordeaux'),
('MediBDX', 'info@medibdx.fr', '0556234567', '17 rue Sainte-Catherine', 'Bordeaux'),
('BioBDX', 'vente@biobdx.fr', '0556345678', '29 quai des Chartrons', 'Bordeaux'),
('BDXPharma', 'support@bordeauxpharma.fr', '0556456789', '13 rue Judaïque', 'Bordeaux'),
('HealthBDX', 'contact@healthbdx.fr', '0556567890', '41 rue Fondaudège', 'Bordeaux');

insert into ORDONNANCE values (10000000001, TO_DATE('2025-12-01','YYYY-MM-DD'), TO_DATE('2026-01-01','YYYY-MM-DD'), '10101234567', 199057512345678);
insert into ORDONNANCE values (10000000002, TO_DATE('2025-12-02','YYYY-MM-DD'), TO_DATE('2026-01-02','YYYY-MM-DD'), '10102345678', 201116924531245);
insert into ORDONNANCE values (10000000003, TO_DATE('2025-12-03','YYYY-MM-DD'), TO_DATE('2026-01-03','YYYY-MM-DD'), '10103456789', 198031340217891);
insert into ORDONNANCE values (10000000004, TO_DATE('2025-12-04','YYYY-MM-DD'), TO_DATE('2026-01-04','YYYY-MM-DD'), '10104567890', 200073311965422);
insert into ORDONNANCE values (10000000005, TO_DATE('2025-12-05','YYYY-MM-DD'), TO_DATE('2026-01-05','YYYY-MM-DD'), '10105678901', 197125932198710);
insert into ORDONNANCE values (10000000006, TO_DATE('2025-12-06','YYYY-MM-DD'), TO_DATE('2026-01-06','YYYY-MM-DD'), '10106789012', 202019221034566);
insert into ORDONNANCE values (10000000007, TO_DATE('2025-12-07','YYYY-MM-DD'), TO_DATE('2026-01-07','YYYY-MM-DD'), '10107890123', 196064411122233);
insert into ORDONNANCE values (10000000008, TO_DATE('2025-12-08','YYYY-MM-DD'), TO_DATE('2026-01-08','YYYY-MM-DD'), '10108901234', 203093145678954);
insert into ORDONNANCE values (10000000009, TO_DATE('2025-12-09','YYYY-MM-DD'), TO_DATE('2026-01-09','YYYY-MM-DD'), '10109012345', 195108433344481);
insert into ORDONNANCE values (10000000010, TO_DATE('2025-12-10','YYYY-MM-DD'), TO_DATE('2026-01-10','YYYY-MM-DD'), '10110123456', 204026755566609);
insert into ORDONNANCE values (10000000011, TO_DATE('2025-12-11','YYYY-MM-DD'), TO_DATE('2026-01-11','YYYY-MM-DD'), '10101234567', 199057512345678);
insert into ORDONNANCE values (10000000012, TO_DATE('2025-12-12','YYYY-MM-DD'), TO_DATE('2026-01-12','YYYY-MM-DD'), '10103456789', 198031340217891);
insert into ORDONNANCE values (10000000013, TO_DATE('2025-12-13','YYYY-MM-DD'), TO_DATE('2026-01-13','YYYY-MM-DD'), '10102345678', 201116924531245);
insert into ORDONNANCE values (10000000014, TO_DATE('2025-12-14','YYYY-MM-DD'), TO_DATE('2026-01-14','YYYY-MM-DD'), '10104567890', 200073311965422);
insert into ORDONNANCE values (10000000015, TO_DATE('2025-12-15','YYYY-MM-DD'), TO_DATE('2026-01-15','YYYY-MM-DD'), '10105678901', 197125932198710);
insert into ORDONNANCE values (10000000016, TO_DATE('2025-12-16','YYYY-MM-DD'), TO_DATE('2026-01-16','YYYY-MM-DD'), '10106789012', 202019221034566);
insert into ORDONNANCE values (10000000017, TO_DATE('2025-12-17','YYYY-MM-DD'), TO_DATE('2026-01-17','YYYY-MM-DD'), '10107890123', 196064411122233);
insert into ORDONNANCE values (10000000018, TO_DATE('2025-12-18','YYYY-MM-DD'), TO_DATE('2026-01-18','YYYY-MM-DD'), '10108901234', 203093145678954);
insert into ORDONNANCE values (10000000019, TO_DATE('2025-12-19','YYYY-MM-DD'), TO_DATE('2026-01-19','YYYY-MM-DD'), '10109012345', 195108433344481);
insert into ORDONNANCE values (10000000020, TO_DATE('2025-12-20','YYYY-MM-DD'), TO_DATE('2026-01-20','YYYY-MM-DD'), '10110123456', 204026755566609);
insert into ORDONNANCE values (10000000021, TO_DATE('2025-12-21','YYYY-MM-DD'), TO_DATE('2026-01-21','YYYY-MM-DD'), '10111234567', 199057512345678);
insert into ORDONNANCE values (10000000022, TO_DATE('2025-12-22','YYYY-MM-DD'), TO_DATE('2026-01-22','YYYY-MM-DD'), '10112345678', 201116924531245);
insert into ORDONNANCE values (10000000023, TO_DATE('2025-12-23','YYYY-MM-DD'), TO_DATE('2026-01-23','YYYY-MM-DD'), '10113456789', 198031340217891);
insert into ORDONNANCE values (10000000024, TO_DATE('2025-12-24','YYYY-MM-DD'), TO_DATE('2026-01-24','YYYY-MM-DD'), '10114567890', 200073311965422);
insert into ORDONNANCE values (10000000025, TO_DATE('2025-12-25','YYYY-MM-DD'), TO_DATE('2026-01-25','YYYY-MM-DD'), '10115678901', 197125932198710);
insert into ORDONNANCE values (10000000026, TO_DATE('2025-12-26','YYYY-MM-DD'), TO_DATE('2026-01-26','YYYY-MM-DD'), '10116789012', 202019221034566);
insert into ORDONNANCE values (10000000027, TO_DATE('2025-12-27','YYYY-MM-DD'), TO_DATE('2026-01-27','YYYY-MM-DD'), '10117890123', 196064411122233);
insert into ORDONNANCE values (10000000028, TO_DATE('2025-12-28','YYYY-MM-DD'), TO_DATE('2026-01-28','YYYY-MM-DD'), '10118901234', 203093145678954);
insert into ORDONNANCE values (10000000029, TO_DATE('2025-12-29','YYYY-MM-DD'), TO_DATE('2026-01-29','YYYY-MM-DD'), '10119012345', 195108433344481);
insert into ORDONNANCE values (10000000030, TO_DATE('2025-12-30','YYYY-MM-DD'), TO_DATE('2026-01-30','YYYY-MM-DD'), '10120123456', 204026755566609);

-- MEDICAMENT


INSERT INTO MEDICAMENT (code_cip,nom,prix_public ,Categorie,Statue_Vente,Laboratoire) VALUES
('340093000001', 'Doliprane 500mg', 1.95, 'Antalgique', 'Libre', 'Sanofi'),
('340093000002', 'Doliprane 1000mg', 2.50, 'Antalgique', 'Libre', 'Sanofi'),
('340093000003', 'Efferalgan 500mg', 2.10, 'Antalgique', 'Libre', 'UPSA'),
('340093000004', 'Efferalgan 1000mg', 2.90, 'Antalgique', 'Libre', 'UPSA'),
('340093000005', 'Paracetamol Biogaran', 1.60, 'Antalgique', 'Libre', 'Biogaran'),
('340093000006', 'Ibuprofene 200mg', 2.30, 'Anti-inflammatoire', 'Libre', 'Mylan'),
('340093000007', 'Ibuprofene 400mg', 3.10, 'Anti-inflammatoire', 'Libre', 'Mylan'),
('340093000008', 'Spasfon', 3.50, 'Antispasmodique', 'Libre', 'Teva'),
('340093000009', 'Smecta', 3.80, 'Gastro', 'Libre', 'Ipsen'),
('340093000010', 'Gaviscon', 4.20, 'Gastro', 'Libre', 'Reckitt'),
('340093000011', 'Augmentin 1g', 7.20, 'Antibiotique', 'Ordonnance', 'GSK'),
('340093000012', 'Amoxicilline 500mg', 5.10, 'Antibiotique', 'Ordonnance', 'Biogaran'),
('340093000013', 'Azithromycine', 6.40, 'Antibiotique', 'Ordonnance', 'Pfizer'),
('340093000014', 'Ventoline', 4.30, 'Respiratoire', 'Ordonnance', 'GSK'),
('340093000015', 'Seretide', 18.90, 'Respiratoire', 'Ordonnance', 'GSK'),
('340093000016', 'Levothyrox', 2.10, 'Hormonal', 'Ordonnance', 'Merck'),
('340093000017', 'Aerius', 3.90, 'Antihistaminique', 'Libre', 'MSD'),
('340093000018', 'Zyrtec', 4.10, 'Antihistaminique', 'Libre', 'UCB'),
('340093000019', 'Xanax', 2.80, 'Anxiolytique', 'Ordonnance', 'Pfizer'),
('340093000020', 'Lexomil', 2.60, 'Anxiolytique', 'Ordonnance', 'Roche'),
('340093000021', 'Imodium', 3.20, 'Gastro', 'Libre', 'Janssen'),
('340093000022', 'Dafalgan', 2.00, 'Antalgique', 'Libre', 'UPSA'),
('340093000023', 'Forlax', 5.50, 'Laxatif', 'Libre', 'Ipsen'),
('340093000024', 'Maalox', 3.70, 'Gastro', 'Libre', 'Sanofi'),
('340093000025', 'Inexium', 8.90, 'Gastro', 'Ordonnance', 'AstraZeneca'),
('340093000026', 'Omeprazole', 4.60, 'Gastro', 'Ordonnance', 'Teva'),
('340093000027', 'Plavix', 21.00, 'Cardiologie', 'Ordonnance', 'Sanofi'),
('340093000028', 'Kardegic', 3.40, 'Cardiologie', 'Libre', 'Sanofi'),
('340093000029', 'Lovenox', 12.80, 'Anticoagulant', 'Ordonnance', 'Sanofi'),
('340093000030', 'Doliprane Pediatrique', 2.20, 'Antalgique', 'Libre', 'Sanofi');



-- COMMANDE 

-- Pour résultat requete 4  bruh j'ai fait ça pour rien
INSERT INTO COMMANDE VALUES (61, TO_DATE('2024-02-10','YYYY-MM-DD'), 'Livrée', 760, 50, 'MediNord');
INSERT INTO COMMANDE VALUES (62, TO_DATE('2024-05-18','YYYY-MM-DD'), 'Livrée', 700, 50, 'MediNord');


INSERT INTO COMMANDE (id_Commande, Date_Commande, Statut, Prix_Commande, Quantite, Nom) VALUES
(1,  TO_DATE('2025-01-05','YYYY-MM-DD'), 'En cours', 1200.50, 50, 'PharmaDis'),
(2,  TO_DATE('2025-01-06','YYYY-MM-DD'), 'Livrée', 980.00, 40, 'MediLux'),
(3,  TO_DATE('2025-01-07','YYYY-MM-DD'), 'Livrée', 1500.75, 60, 'BioCare'),
(4,  TO_DATE('2025-01-08','YYYY-MM-DD'), 'En cours', 760.20, 30, 'PharmaTech'),
(5,  TO_DATE('2025-01-09','YYYY-MM-DD'), 'Annulée', 0.00, 0, 'HealthNord'),
(6,  TO_DATE('2025-01-10','YYYY-MM-DD'), 'Livrée', 2100.00, 90, 'PharmaDis'),
(7,  TO_DATE('2025-01-11','YYYY-MM-DD'), 'Livrée', 1340.40, 55, 'MediSud'),
(8,  TO_DATE('2025-01-12','YYYY-MM-DD'), 'En cours', 890.00, 35, 'BioHealth'),
(9,  TO_DATE('2025-01-13','YYYY-MM-DD'), 'Livrée', 1760.80, 70, 'LillePharma'),
(10, TO_DATE('2025-01-14','YYYY-MM-DD'), 'Livrée', 990.30, 45, 'BioHealth'),
(11, TO_DATE('2025-01-15','YYYY-MM-DD'), 'En cours', 1600.00, 65, 'PharmaLyon'),
(12, TO_DATE('2025-01-16','YYYY-MM-DD'), 'Livrée', 1420.90, 60, 'MediLyon'),
(13, TO_DATE('2025-01-17','YYYY-MM-DD'), 'Livrée', 870.50, 30, 'PharmaDis'),
(14, TO_DATE('2025-01-18','YYYY-MM-DD'), 'En cours', 1950.00, 80, 'LyonPharma'),
(15, TO_DATE('2025-01-19','YYYY-MM-DD'), 'Livrée', 1100.25, 48, 'HealthLyon'),
(16, TO_DATE('2025-01-20','YYYY-MM-DD'), 'Livrée', 1300.00, 52, 'PharmaNord'),
(17, TO_DATE('2025-01-21','YYYY-MM-DD'), 'En cours', 920.75, 38, 'LillePharma'),
(18, TO_DATE('2025-01-22','YYYY-MM-DD'), 'Livrée', 1580.60, 66, 'LyonPharma'),
(19, TO_DATE('2025-01-23','YYYY-MM-DD'), 'Livrée', 1010.40, 42, 'LillePharma'),
(20, TO_DATE('2025-01-24','YYYY-MM-DD'), 'En cours', 1875.90, 75, 'HealthNord'),
(21, TO_DATE('2025-01-25','YYYY-MM-DD'), 'Livrée', 1430.00, 58, 'PharmaTLS'),
(22, TO_DATE('2025-01-26','YYYY-MM-DD'), 'En cours', 980.60, 41, 'MediTLS'),
(23, TO_DATE('2025-01-27','YYYY-MM-DD'), 'Livrée', 1675.20, 69, 'BioHealth'),
(24, TO_DATE('2025-01-28','YYYY-MM-DD'), 'Livrée', 1120.80, 46, 'LyonPharma'),
(25, TO_DATE('2025-01-29','YYYY-MM-DD'), 'En cours', 1890.00, 78, 'HealthTLS'),
(26, TO_DATE('2025-01-30','YYYY-MM-DD'), 'Livrée', 1350.40, 54, 'PharmaDis'),
(27, TO_DATE('2025-01-31','YYYY-MM-DD'), 'Livrée', 990.90, 43, 'HealthNord'),
(28, TO_DATE('2025-02-01','YYYY-MM-DD'), 'En cours', 1620.70, 67, 'BioBDX'),
(29, TO_DATE('2025-02-02','YYYY-MM-DD'), 'Livrée', 1085.30, 44, 'MediSud'),
(30, TO_DATE('2025-02-03','YYYY-MM-DD'), 'En cours', 1750.00, 72, 'MediSud');

-- Création des commandes pour MediNord POUR FAIRE REQUETE 2
INSERT INTO COMMANDE (id_Commande, Date_Commande, Statut, Prix_Commande, Quantite, Nom) VALUES
(31, TO_DATE('2025-01-05','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(32, TO_DATE('2025-02-01','YYYY-MM-DD'), 'reçu', 900, 400, 'MediNord'),
(33, TO_DATE('2025-03-10','YYYY-MM-DD'), 'reçu', 950, 450, 'MediNord'),
(34, TO_DATE('2025-01-20','YYYY-MM-DD'), 'reçu', 980, 480, 'MediNord'),
(35, TO_DATE('2025-04-12','YYYY-MM-DD'), 'reçu', 1020, 520, 'MediNord'),
(36, TO_DATE('2025-05-18','YYYY-MM-DD'), 'reçu', 970, 470, 'MediNord'),
(37, TO_DATE('2025-06-08','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(38, TO_DATE('2025-07-01','YYYY-MM-DD'), 'reçu', 930, 430, 'MediNord'),
(39, TO_DATE('2025-08-15','YYYY-MM-DD'), 'reçu', 960, 460, 'MediNord'),
(40, TO_DATE('2025-09-05','YYYY-MM-DD'), 'reçu', 980, 480, 'MediNord'),
(41, TO_DATE('2025-10-10','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(42, TO_DATE('2025-11-12','YYYY-MM-DD'), 'reçu', 950, 450, 'MediNord'),
(43, TO_DATE('2025-12-01','YYYY-MM-DD'), 'reçu', 970, 470, 'MediNord'),
(44, TO_DATE('2025-01-28','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(45, TO_DATE('2025-02-18','YYYY-MM-DD'), 'reçu', 1020, 520, 'MediNord'),
(46, TO_DATE('2025-03-15','YYYY-MM-DD'), 'reçu', 980, 480, 'MediNord'),
(47, TO_DATE('2025-04-05','YYYY-MM-DD'), 'reçu', 950, 450, 'MediNord'),
(48, TO_DATE('2025-05-12','YYYY-MM-DD'), 'reçu', 970, 470, 'MediNord'),
(49, TO_DATE('2025-06-01','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(50, TO_DATE('2025-07-15','YYYY-MM-DD'), 'reçu', 980, 480, 'MediNord'),
(51, TO_DATE('2025-08-20','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(52, TO_DATE('2025-09-05','YYYY-MM-DD'), 'reçu', 970, 470, 'MediNord'),
(53, TO_DATE('2025-10-10','YYYY-MM-DD'), 'reçu', 950, 450, 'MediNord'),
(54, TO_DATE('2025-11-20','YYYY-MM-DD'), 'reçu', 980, 480, 'MediNord'),
(55, TO_DATE('2025-12-15','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(56, TO_DATE('2025-01-18','YYYY-MM-DD'), 'reçu', 970, 470, 'MediNord'),
(57, TO_DATE('2025-02-12','YYYY-MM-DD'), 'reçu', 950, 450, 'MediNord'),
(58, TO_DATE('2025-03-25','YYYY-MM-DD'), 'reçu', 980, 480, 'MediNord'),
(59, TO_DATE('2025-04-18','YYYY-MM-DD'), 'reçu', 1000, 500, 'MediNord'),
(60, TO_DATE('2025-05-10','YYYY-MM-DD'), 'reçu', 970, 470, 'MediNord');


insert into LigneOrdonnance values (101, 10, 5, TO_DATE('2025-12-01','YYYY-MM-DD'), 340093000001, 10000000001, 10000000290);
insert into LigneOrdonnance values (102, 5, 7, TO_DATE('2025-12-02','YYYY-MM-DD'), 340093000002, 10000000002, 10000000012);
insert into LigneOrdonnance values (103, 8, 10, TO_DATE('2025-12-03','YYYY-MM-DD'), 340093000003, 10000000003, 10000000134);
insert into LigneOrdonnance values (104, 6, 14, TO_DATE('2025-12-03','YYYY-MM-DD'), 340093000004, 10000000003, 10000000034);
insert into LigneOrdonnance values (105, 12, 7, TO_DATE('2025-12-04','YYYY-MM-DD'), 340093000005, 10000000004, 10000000045);
insert into LigneOrdonnance values (106, 15, 10, TO_DATE('2025-12-05','YYYY-MM-DD'), 340093000006, 10000000005,10000000101);
insert into LigneOrdonnance values (107, 10, 5, TO_DATE('2025-12-06','YYYY-MM-DD'), 340093000007, 10000000006, 10000000067);
insert into LigneOrdonnance values (108, 8, 7, TO_DATE('2025-12-07','YYYY-MM-DD'), 340093000008, 10000000007, 10000000078);
insert into LigneOrdonnance values (109, 6, 10, TO_DATE('2025-12-08','YYYY-MM-DD'), 340093000009, 10000000008, 10000000089);
insert into LigneOrdonnance values (110, 12, 14, TO_DATE('2025-12-09','YYYY-MM-DD'), 340093000010, 10000000009, 10000000212);
insert into LigneOrdonnance values (111, 5, 7, TO_DATE('2025-12-10','YYYY-MM-DD'), 340093000001, 10000000010, 10000000301);
insert into LigneOrdonnance values (112, 10, 5, TO_DATE('2025-12-11','YYYY-MM-DD'), 340093000002, 10000000011, 10000000312);
insert into LigneOrdonnance values (113, 6, 10, TO_DATE('2025-12-12','YYYY-MM-DD'), 340093000003, 10000000012, 10000000089);
insert into LigneOrdonnance values (114, 8, 7, TO_DATE('2025-12-13','YYYY-MM-DD'), 340093000004, 10000000013, 10000000145);
insert into LigneOrdonnance values (115, 12, 14, TO_DATE('2025-12-14','YYYY-MM-DD'), 340093000005, 10000000014, 10000000123);
insert into LigneOrdonnance values (116, 5, 10, TO_DATE('2025-12-15','YYYY-MM-DD'), 340093000006, 10000000015, 10000000134);
insert into LigneOrdonnance values (117, 10, 5, TO_DATE('2025-12-16','YYYY-MM-DD'), 340093000007, 10000000016, 10000000145);
insert into LigneOrdonnance values (118, 6, 7, TO_DATE('2025-12-17','YYYY-MM-DD'), 340093000008, 10000000017, 10000000089);
insert into LigneOrdonnance values (119, 8, 10, TO_DATE('2025-12-18','YYYY-MM-DD'), 340093000009, 10000000018, 10000000167);
insert into LigneOrdonnance values (120, 12, 14, TO_DATE('2025-12-19','YYYY-MM-DD'), 340093000010, 10000000019, 10000000212);
insert into LigneOrdonnance values (121, 5, 5, TO_DATE('2025-12-20','YYYY-MM-DD'), 340093000011, 10000000020, 10000000178);
insert into LigneOrdonnance values (122, 8, 7, TO_DATE('2025-12-21','YYYY-MM-DD'), 340093000012, 10000000021, 10000000101);
insert into LigneOrdonnance values (123, 10, 10, TO_DATE('2025-12-22','YYYY-MM-DD'), 340093000013, 10000000022, 10000000201);
insert into LigneOrdonnance values (124, 6, 14, TO_DATE('2025-12-23','YYYY-MM-DD'), 340093000014, 10000000023, 10000000212);
insert into LigneOrdonnance values (125, 12, 7, TO_DATE('2025-12-24','YYYY-MM-DD'), 340093000015, 10000000024, 10000000223);
insert into LigneOrdonnance values (126, 5, 10, TO_DATE('2025-12-25','YYYY-MM-DD'), 340093000016, 10000000025, 10000000234);
insert into LigneOrdonnance values (127, 8, 5, TO_DATE('2025-12-26','YYYY-MM-DD'), 340093000017, 10000000026, 10000000245);
insert into LigneOrdonnance values (128, 10, 7, TO_DATE('2025-12-27','YYYY-MM-DD'), 340093000018, 10000000027, 10000000256);
insert into LigneOrdonnance values (129, 6, 10, TO_DATE('2025-12-28','YYYY-MM-DD'), 340093000019, 10000000028, 10000000290);
insert into LigneOrdonnance values (130, 12, 14, TO_DATE('2025-12-29','YYYY-MM-DD'), 340093000020, 10000000029, 10000000134);
insert into LigneOrdonnance values (131, 7, 10, TO_DATE('2025-12-30','YYYY-MM-DD'), 340093000021, 10000000030, 10000000289);
insert into LigneOrdonnance values (132, 9, 14, TO_DATE('2025-12-30','YYYY-MM-DD'), 340093000022, 10000000030, 10000000290);



-- LOT 

-- Pour résultat requete 4 bruh j'ai fait ça pour rien
INSERT INTO LOT VALUES (61, 0, TO_DATE('2026-11-30','YYYY-MM-DD'), TO_DATE('2024-01-15','YYYY-MM-DD'), 'MediNord', 61,340093000001);
INSERT INTO LOT VALUES (62, 0, TO_DATE('2027-04-30','YYYY-MM-DD'), TO_DATE('2024-03-20','YYYY-MM-DD'), 'MediNord', 62, 34009300000);

INSERT INTO LOT (num_lot, Quantite, Date_Peremption, Date_Fabrication, Nom, Id_Commande, CODE_CIP) VALUES
(1, 200, TO_DATE('2027-06-30','YYYY-MM-DD'), TO_DATE('2024-06-30','YYYY-MM-DD'), 'PharmaDis', 1, '340093000001'),
(2, 180, TO_DATE('2027-07-31','YYYY-MM-DD'), TO_DATE('2024-07-31','YYYY-MM-DD'), 'MediLux', 2, '340093000006'),
(3, 150, TO_DATE('2026-12-31','YYYY-MM-DD'), TO_DATE('2024-01-01','YYYY-MM-DD'), 'BioCare', 3, '340093000006'),
(4, 140, TO_DATE('2026-11-30','YYYY-MM-DD'), TO_DATE('2024-02-01','YYYY-MM-DD'), 'PharmaTech', 4, '340093000004'),
(5, 300, TO_DATE('2027-03-31','YYYY-MM-DD'), TO_DATE('2024-03-01','YYYY-MM-DD'), 'HealthNord', 5, '340093000005'),
(6, 220, TO_DATE('2026-08-31','YYYY-MM-DD'), TO_DATE('2024-04-15','YYYY-MM-DD'), 'PharmaDis', 6, '340093000001'),
(7, 210, TO_DATE('2026-09-30','YYYY-MM-DD'), TO_DATE('2024-04-20','YYYY-MM-DD'), 'MediSud', 7, '340093000007'),
(8, 160, TO_DATE('2026-10-31','YYYY-MM-DD'), TO_DATE('2024-05-01','YYYY-MM-DD'), 'BioHealth', 8, '340093000008'),
(9, 190, TO_DATE('2026-12-15','YYYY-MM-DD'), TO_DATE('2024-05-10','YYYY-MM-DD'), 'LillePharma', 9, '340093000009'),
(10,170, TO_DATE('2026-11-15','YYYY-MM-DD'), TO_DATE('2024-05-15','YYYY-MM-DD'), 'BioHealth', 10, '340093000008'),
(11,120, TO_DATE('2026-04-30','YYYY-MM-DD'), TO_DATE('2024-01-20','YYYY-MM-DD'), 'PharmaLyon', 11, '340093000011'),
(12,130, TO_DATE('2026-05-31','YYYY-MM-DD'), TO_DATE('2024-02-10','YYYY-MM-DD'), 'MediLyon', 12, '340093000020'),
(13,110, TO_DATE('2026-06-30','YYYY-MM-DD'), TO_DATE('2024-02-15','YYYY-MM-DD'), 'PharmaDis', 13, '340093000009'),
(14,100, TO_DATE('2026-07-31','YYYY-MM-DD'), TO_DATE('2024-03-01','YYYY-MM-DD'), 'LyonPharma', 14, '340093000005'),
(15,90,  TO_DATE('2026-08-31','YYYY-MM-DD'), TO_DATE('2024-03-05','YYYY-MM-DD'), 'HealthLyon', 15, '340093000009'),
(16,200, TO_DATE('2027-01-31','YYYY-MM-DD'), TO_DATE('2024-04-01','YYYY-MM-DD'), 'PharmaNord', 16, '340093000016'),
(17,210, TO_DATE('2027-02-28','YYYY-MM-DD'), TO_DATE('2024-04-05','YYYY-MM-DD'), 'LillePharma', 17, '340093000017'),
(18,220, TO_DATE('2027-03-31','YYYY-MM-DD'), TO_DATE('2024-04-10','YYYY-MM-DD'), 'LyonPharma', 18, '340093000014'),
(19,80,  TO_DATE('2026-01-31','YYYY-MM-DD'), TO_DATE('2024-01-10','YYYY-MM-DD'), 'LillePharma', 19, '340093000019'),
(20,85,  TO_DATE('2026-02-28','YYYY-MM-DD'), TO_DATE('2024-01-15','YYYY-MM-DD'), 'HealthNord', 20, '340093000020'),
(21,160, TO_DATE('2026-09-30','YYYY-MM-DD'), TO_DATE('2024-05-20','YYYY-MM-DD'), 'PharmaTLS', 21, '340093000021'),
(22,180, TO_DATE('2026-10-31','YYYY-MM-DD'), TO_DATE('2024-06-01','YYYY-MM-DD'), 'MediTLS', 22, '340093000009'),
(23,140, TO_DATE('2026-11-30','YYYY-MM-DD'), TO_DATE('2024-06-05','YYYY-MM-DD'), 'BioHealth', 23, '340093000008'),
(24,150, TO_DATE('2026-12-31','YYYY-MM-DD'), TO_DATE('2024-06-10','YYYY-MM-DD'), 'LyonPharma', 24, '340093000005'),
(25,95,  TO_DATE('2026-03-31','YYYY-MM-DD'), TO_DATE('2024-02-01','YYYY-MM-DD'), 'PharmaDis', 25, '340093000002'),
(26,160, TO_DATE('2026-04-30','YYYY-MM-DD'), TO_DATE('2024-02-05','YYYY-MM-DD'), 'PharmaBDX', 26, '340093000014'),
(27,70,  TO_DATE('2026-05-31','YYYY-MM-DD'), TO_DATE('2024-02-10','YYYY-MM-DD'), 'HealthNord', 27, '340093000027'),
(28,130, TO_DATE('2026-06-30','YYYY-MM-DD'), TO_DATE('2024-03-01','YYYY-MM-DD'), 'BioBDX', 28, '340093000020'),
(29,60,  TO_DATE('2026-07-31','YYYY-MM-DD'), TO_DATE('2024-03-05','YYYY-MM-DD'), 'MediSud', 29, '340093000029'),
(30,190, TO_DATE('2027-04-30','YYYY-MM-DD'), TO_DATE('2024-07-01','YYYY-MM-DD'), 'MediSud', 30, '340093000014');


--  POUR FAIRE REQUETE 2

INSERT INTO LOT (num_lot, Quantite, Date_Peremption, Date_Fabrication, Nom, Id_Commande, CODE_CIP) VALUES
(31, 500, TO_DATE('2027-08-15','YYYY-MM-DD'), TO_DATE('2025-01-10','YYYY-MM-DD'), 'MediNord', 31, '340093000001'),
(32, 400, TO_DATE('2027-09-10','YYYY-MM-DD'), TO_DATE('2025-02-05','YYYY-MM-DD'), 'MediNord', 32, '340093000002'),
(33, 450, TO_DATE('2027-07-20','YYYY-MM-DD'), TO_DATE('2025-03-12','YYYY-MM-DD'), 'MediNord', 33, '340093000003'),
(34, 480, TO_DATE('2027-10-05','YYYY-MM-DD'), TO_DATE('2025-01-25','YYYY-MM-DD'), 'MediNord', 34, '340093000004'),
(35, 520, TO_DATE('2027-11-18','YYYY-MM-DD'), TO_DATE('2025-04-15','YYYY-MM-DD'), 'MediNord', 35, '340093000005'),
(36, 470, TO_DATE('2027-12-02','YYYY-MM-DD'), TO_DATE('2025-05-20','YYYY-MM-DD'), 'MediNord', 36, '340093000006'),
(37, 500, TO_DATE('2027-08-30','YYYY-MM-DD'), TO_DATE('2025-06-10','YYYY-MM-DD'), 'MediNord', 37, '340093000007'),
(38, 430, TO_DATE('2027-09-25','YYYY-MM-DD'), TO_DATE('2025-07-05','YYYY-MM-DD'), 'MediNord', 38, '340093000008'),
(39, 460, TO_DATE('2027-10-30','YYYY-MM-DD'), TO_DATE('2025-08-15','YYYY-MM-DD'), 'MediNord', 39, '340093000009'),
(40, 480, TO_DATE('2027-11-12','YYYY-MM-DD'), TO_DATE('2025-09-01','YYYY-MM-DD'), 'MediNord', 40, '340093000010'),
(41, 500, TO_DATE('2027-12-20','YYYY-MM-DD'), TO_DATE('2025-10-05','YYYY-MM-DD'), 'MediNord', 41, '340093000011'),
(42, 450, TO_DATE('2027-08-18','YYYY-MM-DD'), TO_DATE('2025-11-15','YYYY-MM-DD'), 'MediNord', 42, '340093000012'),
(43, 470, TO_DATE('2027-09-22','YYYY-MM-DD'), TO_DATE('2025-12-10','YYYY-MM-DD'), 'MediNord', 43, '340093000013'),
(44, 500, TO_DATE('2027-10-18','YYYY-MM-DD'), TO_DATE('2025-01-30','YYYY-MM-DD'), 'MediNord', 44, '340093000014'),
(45, 520, TO_DATE('2027-11-05','YYYY-MM-DD'), TO_DATE('2025-02-20','YYYY-MM-DD'), 'MediNord', 45, '340093000015'),
(46, 480, TO_DATE('2027-12-15','YYYY-MM-DD'), TO_DATE('2025-03-12','YYYY-MM-DD'), 'MediNord', 46, '340093000016'),
(47, 450, TO_DATE('2027-08-25','YYYY-MM-DD'), TO_DATE('2025-04-05','YYYY-MM-DD'), 'MediNord', 47, '340093000017'),
(48, 470, TO_DATE('2027-09-30','YYYY-MM-DD'), TO_DATE('2025-05-10','YYYY-MM-DD'), 'MediNord', 48, '340093000018'),
(49, 500, TO_DATE('2027-10-28','YYYY-MM-DD'), TO_DATE('2025-06-01','YYYY-MM-DD'), 'MediNord', 49, '340093000019'),
(50, 480, TO_DATE('2027-11-22','YYYY-MM-DD'), TO_DATE('2025-07-15','YYYY-MM-DD'), 'MediNord', 50, '340093000020'),
(51, 500, TO_DATE('2027-12-30','YYYY-MM-DD'), TO_DATE('2025-08-20','YYYY-MM-DD'), 'MediNord', 51, '340093000021'),
(52, 470, TO_DATE('2027-08-12','YYYY-MM-DD'), TO_DATE('2025-09-05','YYYY-MM-DD'), 'MediNord', 52, '340093000022'),
(53, 450, TO_DATE('2027-09-18','YYYY-MM-DD'), TO_DATE('2025-10-10','YYYY-MM-DD'), 'MediNord', 53, '340093000023'),
(54, 480, TO_DATE('2027-10-25','YYYY-MM-DD'), TO_DATE('2025-11-20','YYYY-MM-DD'), 'MediNord', 54, '340093000024'),
(55, 500, TO_DATE('2027-11-30','YYYY-MM-DD'), TO_DATE('2025-12-15','YYYY-MM-DD'), 'MediNord', 55, '340093000025'),
(56, 470, TO_DATE('2027-12-10','YYYY-MM-DD'), TO_DATE('2025-01-18','YYYY-MM-DD'), 'MediNord', 56, '340093000026'),
(57, 450, TO_DATE('2027-08-28','YYYY-MM-DD'), TO_DATE('2025-02-12','YYYY-MM-DD'), 'MediNord', 57, '340093000027'),
(58, 480, TO_DATE('2027-09-29','YYYY-MM-DD'), TO_DATE('2025-03-25','YYYY-MM-DD'), 'MediNord', 58, '340093000028'),
(59, 500, TO_DATE('2027-10-31','YYYY-MM-DD'), TO_DATE('2025-04-18','YYYY-MM-DD'), 'MediNord', 59, '340093000029'),
(60, 470, TO_DATE('2027-12-05','YYYY-MM-DD'), TO_DATE('2025-05-10','YYYY-MM-DD'), 'MediNord', 60, '340093000030');





INSERT INTO VENTE VALUES (1, TO_DATE('2025-12-01','YYYY-MM-DD'), NULL, 10000000001, 199057512345678);
INSERT INTO VENTE VALUES (2, TO_DATE('2025-12-02','YYYY-MM-DD'), NULL, 10000000012, 201116924531245);
INSERT INTO VENTE VALUES (3, TO_DATE('2025-12-02','YYYY-MM-DD'), NULL, 10000000023, 198031340217891);
INSERT INTO VENTE VALUES (4, TO_DATE('2025-12-02','YYYY-MM-DD'), NULL, 10000000034, 200073311965422);
INSERT INTO VENTE VALUES (5, TO_DATE('2025-12-02','YYYY-MM-DD'), NULL, 10000000045, 197125932198710);
INSERT INTO VENTE VALUES (6, TO_DATE('2025-12-02','YYYY-MM-DD'), NULL, 10000000301, 199057512345678);
INSERT INTO VENTE VALUES (7, TO_DATE('2025-12-05','YYYY-MM-DD'), NULL, 10000000012, 198031340217891);
INSERT INTO VENTE VALUES (9, TO_DATE('2025-12-05','YYYY-MM-DD'), NULL, 10000000167, 203093145678954);
INSERT INTO VENTE VALUES (10, TO_DATE('2025-12-05','YYYY-MM-DD'),NULL, 10000000134, 197125932198710);
INSERT INTO VENTE VALUES (12, TO_DATE('2025-12-08','YYYY-MM-DD'),NULL, 10000000101, 197125932198710);
INSERT INTO VENTE VALUES (13, TO_DATE('2025-12-08','YYYY-MM-DD'),NULL, 10000000023, 101890123456789);
INSERT INTO VENTE VALUES (14, TO_DATE('2025-12-08','YYYY-MM-DD'),NULL, 10000000212, 202901234567891);
INSERT INTO VENTE VALUES (15, TO_DATE('2025-12-10','YYYY-MM-DD'),NULL, 10000000301, 101234567890125);
INSERT INTO VENTE VALUES (16, TO_DATE('2025-12-10','YYYY-MM-DD'),NULL, 10000000134, 101456789012345);
INSERT INTO VENTE VALUES (17, TO_DATE('2025-12-12','YYYY-MM-DD'),NULL, 10000000167, 200073311965422);
INSERT INTO VENTE VALUES (18, TO_DATE('2025-12-12','YYYY-MM-DD'),NULL, 10000000245, 201116924531245);
INSERT INTO VENTE VALUES (19, TO_DATE('2025-12-12','YYYY-MM-DD'),NULL, 10000000012, 197125932198710);
INSERT INTO VENTE VALUES (20, TO_DATE('2025-12-13','YYYY-MM-DD'),NULL, 10000000023, 197125932198710);
INSERT INTO VENTE VALUES (23, TO_DATE('2025-12-13','YYYY-MM-DD'),NULL, 10000000278, 202901234567891);
INSERT INTO VENTE VALUES (24, TO_DATE('2025-12-13','YYYY-MM-DD'),NULL, 10000000145, 101456789012346);
INSERT INTO VENTE VALUES (25, TO_DATE('2025-12-13','YYYY-MM-DD'),NULL, 10000000101, 202567890123457);
INSERT INTO VENTE VALUES (26, TO_DATE('2025-12-14','YYYY-MM-DD'),NULL, 10000000023, 198031340217891);  
INSERT INTO VENTE VALUES (27, TO_DATE('2025-12-14','YYYY-MM-DD'),NULL, 10000000245, 201116924531245);  
INSERT INTO VENTE VALUES (28, TO_DATE('2025-12-14','YYYY-MM-DD'),NULL, 10000000212, 203093145678954); 
INSERT INTO VENTE VALUES (29, TO_DATE('2025-12-15','YYYY-MM-DD'),NULL, 10000000123, 101234567890125); 
INSERT INTO VENTE VALUES (30, TO_DATE('2025-12-15','YYYY-MM-DD'),NULL, 10000000245, 202789012345679); 
INSERT INTO VENTE VALUES (31, TO_DATE('2025-12-20','YYYY-MM-DD'),NULL, 10000000245, 101678901234568); 
INSERT INTO VENTE VALUES (32, TO_DATE('2025-12-20','YYYY-MM-DD'),NULL, 10000000178, 202123456789013);  
INSERT INTO VENTE VALUES (33, TO_DATE('2025-12-20','YYYY-MM-DD'),NULL, 10000000078, 101890123456780);  
INSERT INTO VENTE VALUES (34, TO_DATE('2025-12-20','YYYY-MM-DD'),NULL, 10000000167, 101456789012345);



insert into LigneOrdonnance values (101, 10, 5, TO_DATE('2025-12-01','YYYY-MM-DD'), 340093000001, 10000000001, 10000000290);
insert into LigneOrdonnance values (102, 5, 7, TO_DATE('2025-12-02','YYYY-MM-DD'), 340093000002, 10000000002, 10000000012);
insert into LigneOrdonnance values (103, 8, 10, TO_DATE('2025-12-02','YYYY-MM-DD'), 340093000003, 10000000003, 10000000134);
insert into LigneOrdonnance values (104, 6, 14, TO_DATE('2025-12-02','YYYY-MM-DD'), 340093000004, 10000000003, 10000000034);
insert into LigneOrdonnance values (105, 12, 7, TO_DATE('2025-12-02','YYYY-MM-DD'), 340093000005, 10000000004, 10000000045);
insert into LigneOrdonnance values (106, 15, 10, TO_DATE('2025-12-02','YYYY-MM-DD'), 340093000006, 10000000005,10000000101);
insert into LigneOrdonnance values (107, 10, 5, TO_DATE('2025-12-05','YYYY-MM-DD'), 340093000007, 10000000006, 10000000067);
insert into LigneOrdonnance values (108, 8, 7, TO_DATE('2025-12-05','YYYY-MM-DD'), 340093000008, 10000000007, 10000000078);
insert into LigneOrdonnance values (109, 6, 10, TO_DATE('2025-12-08','YYYY-MM-DD'), 340093000009, 10000000008, 10000000089);
insert into LigneOrdonnance values (110, 12, 14, TO_DATE('2025-12-08','YYYY-MM-DD'), 340093000010, 10000000009, 10000000212);
insert into LigneOrdonnance values (111, 5, 7, TO_DATE('2025-12-08','YYYY-MM-DD'), 340093000001, 10000000010, 10000000301);
insert into LigneOrdonnance values (112, 10, 5, TO_DATE('2025-12-10','YYYY-MM-DD'), 340093000002, 10000000011, 10000000312);
insert into LigneOrdonnance values (113, 6, 10, TO_DATE('2025-12-12','YYYY-MM-DD'), 340093000003, 10000000012, 10000000089);
insert into LigneOrdonnance values (114, 8, 7, TO_DATE('2025-12-13','YYYY-MM-DD'), 340093000004, 10000000013, 10000000145);
insert into LigneOrdonnance values (115, 12, 14, TO_DATE('2025-12-14','YYYY-MM-DD'), 340093000005, 10000000014, 10000000123);
insert into LigneOrdonnance values (116, 5, 10, TO_DATE('2025-12-15','YYYY-MM-DD'), 340093000006, 10000000015, 10000000134);
insert into LigneOrdonnance values (117, 10, 5, TO_DATE('2025-12-20','YYYY-MM-DD'), 340093000007, 10000000016, 10000000145);
insert into LigneOrdonnance values (118, 6, 7, TO_DATE('2025-12-17','YYYY-MM-DD'), 340093000008, 10000000017, 10000000089);
insert into LigneOrdonnance values (119, 8, 10, TO_DATE('2025-12-20','YYYY-MM-DD'), 340093000009, 10000000018, 10000000167);
insert into LigneOrdonnance values (120, 12, 14, TO_DATE('2025-12-13','YYYY-MM-DD'), 340093000010, 10000000019, 10000000212);
insert into LigneOrdonnance values (121, 5, 5, TO_DATE('2025-12-20','YYYY-MM-DD'), 340093000011, 10000000020, 10000000178);
insert into LigneOrdonnance values (122, 8, 7, TO_DATE('2025-12-13','YYYY-MM-DD'), 340093000012, 10000000021, 10000000101);
insert into LigneOrdonnance values (123, 10, 10, TO_DATE('2025-12-22','YYYY-MM-DD'), 340093000013, 10000000022, 10000000201);
insert into LigneOrdonnance values (124, 6, 14, TO_DATE('2025-12-14','YYYY-MM-DD'), 340093000014, 10000000023, 10000000212);
insert into LigneOrdonnance values (125, 12, 7, TO_DATE('2025-12-13','YYYY-MM-DD'), 340093000015, 10000000024, 10000000223);
insert into LigneOrdonnance values (126, 5, 10, TO_DATE('2025-12-15','YYYY-MM-DD'), 340093000016, 10000000025, 10000000234);
insert into LigneOrdonnance values (127, 8, 5, TO_DATE('2025-12-14','YYYY-MM-DD'), 340093000017, 10000000026, 10000000245);
insert into LigneOrdonnance values (128, 10, 7, TO_DATE('2025-12-27','YYYY-MM-DD'), 340093000018, 10000000027, 10000000256);
insert into LigneOrdonnance values (129, 6, 10, TO_DATE('2025-12-28','YYYY-MM-DD'), 340093000019, 10000000028, 10000000290);
insert into LigneOrdonnance values (130, 12, 14, TO_DATE('2025-12-29','YYYY-MM-DD'), 340093000020, 10000000029, 10000000134);
insert into LigneOrdonnance values (131, 7, 10, TO_DATE('2025-12-30','YYYY-MM-DD'), 340093000021, 10000000030, 10000000289);
insert into LigneOrdonnance values (132, 9, 14, TO_DATE('2025-12-30','YYYY-MM-DD'), 340093000022, 10000000030, 10000000290);



-- Vente n°1 (Client Martin Lucas, Pharmacien Julien Lefèvre)
INSERT INTO LIGNEVENTE VALUES (1, 2, NULL, 1, 1,10000000001);   
INSERT INTO LIGNEVENTE VALUES (2, 1, NULL, 1, 2,NULL );  

-- Vente n°2 (Client Bernard Emma)
INSERT INTO LIGNEVENTE VALUES (3, 1, NULL, 2, 25);
INSERT INTO LIGNEVENTE VALUES (25, 1, NULL, 2, 1);   


-- Vente n°3

INSERT INTO LIGNEVENTE VALUES (4, 3, NULL, 3, 3);
INSERT INTO LIGNEVENTE VALUES (26, 1, NULL, 3, 2);   


-- Vente n°4 (Client Thomas Léa)
INSERT INTO LIGNEVENTE VALUES (5, 1, NULL, 4, 4);   

-- Vente n°5 (Client Robert Nathan)
INSERT INTO LIGNEVENTE VALUES (6, 2, NULL, 5, 20); 

-- Vente n°6 (Client Martin Lucas)
INSERT INTO LIGNEVENTE VALUES (7, 1, NULL, 6, 6);   

-- Vente n°9 (Client Durand Chloé)
INSERT INTO LIGNEVENTE VALUES (8, 2, NULL, 9, 10);
INSERT INTO LIGNEVENTE VALUES (27, 2, NULL, 9, 8);   


-- Vente n°10 (Client Robert Nathan)
INSERT INTO LIGNEVENTE VALUES (9, 1, NULL, 10, 13); 

-- Vente n°12 (Client Robert Nathan)
INSERT INTO LIGNEVENTE VALUES (10, 4, NULL, 12, 5); 

-- Vente n°13 (Client Rousseau Louis)
INSERT INTO LIGNEVENTE VALUES (11, 1, NULL, 13, 19); 

-- Vente n°14 (Client Faure Camille)
INSERT INTO LIGNEVENTE VALUES (12, 2, NULL, 14, 17); 

-- Vente n°15 (Client Bernard Mathis)
INSERT INTO LIGNEVENTE VALUES (13, 1, NULL, 15, 25); 

-- Vente n°16 (Client Morel Jules)
INSERT INTO LIGNEVENTE VALUES (14, 1, NULL, 16, 18);
INSERT INTO LIGNEVENTE VALUES (28, 1, NULL, 14, 1);  


-- Vente n°17 (Client Thomas Léa)
INSERT INTO LIGNEVENTE VALUES (15, 2, NULL, 17, 4);  

-- Vente n°23 (Client Faure Camille)
INSERT INTO LIGNEVENTE VALUES (16, 1, NULL, 23, 8);  
INSERT INTO LIGNEVENTE VALUES (17, 1, NULL, 23, 1);  

-- Vente n°25 (Client Renard Chloé)
INSERT INTO LIGNEVENTE VALUES (18, 3, NULL, 25, 12);

-- Vente n°26 (Client Dubois Hugo)
INSERT INTO LIGNEVENTE VALUES (19, 1, NULL, 26, 24);

-- Vente n°28 (Client Durand Chloé)
INSERT INTO LIGNEVENTE VALUES (20, 2, NULL, 28, 9);
INSERT INTO LIGNEVENTE VALUES (29, 3, NULL, 20, 20); 


-- Vente n°30 (Client Vidal Emma)
INSERT INTO LIGNEVENTE VALUES (21, 1, NULL, 30, 30); 

-- Vente n°31 (Client Brun Lucas)
INSERT INTO LIGNEVENTE VALUES (22, 1, NULL, 31, 16); 

-- Vente n°32 (Client Garnier Lola)
INSERT INTO LIGNEVENTE VALUES (23, 2, NULL, 32, 28);

-- Vente n°33 (Client Lopez Antoine)
INSERT INTO LIGNEVENTE VALUES (24, 1, NULL, 33, 7); 

-- Vente 34

INSERT INTO LIGNEVENTE VALUES (30, 1, NULL, 34, 4);



-- Vente n°1 (Client Martin Lucas, Pharmacien Julien Lefèvre)
INSERT INTO LIGNEVENTE VALUES (1, 2, NULL, 1, 1, 10000000001);   
INSERT INTO LIGNEVENTE VALUES (2, 1, NULL, 1, 2, NULL);  

-- Vente n°2 (Client Bernard Emma)
INSERT INTO LIGNEVENTE VALUES (3, 1, NULL, 2, 25, 10000000002);
INSERT INTO LIGNEVENTE VALUES (25, 1, NULL, 2, 1, 10000000002);   

-- Vente n°3
INSERT INTO LIGNEVENTE VALUES (4, 3, NULL, 3, 3, 10000000003);
INSERT INTO LIGNEVENTE VALUES (26, 1, NULL, 3, 2, NULL);   

-- Vente n°4 (Client Thomas Léa)
INSERT INTO LIGNEVENTE VALUES (5, 1, NULL, 4, 4, NULL);   

-- Vente n°5 (Client Robert Nathan)
INSERT INTO LIGNEVENTE VALUES (6, 2, NULL, 5, 20, 10000000005); 

-- Vente n°6 (Client Martin Lucas)
INSERT INTO LIGNEVENTE VALUES (7, 1, NULL, 6, 6, 10000000006);   

-- Vente n°9 (Client Durand Chloé)
INSERT INTO LIGNEVENTE VALUES (8, 2, NULL, 9, 10, 10000000009);
INSERT INTO LIGNEVENTE VALUES (27, 2, NULL, 9, 8, 10000000009);   

-- Vente n°10 (Client Robert Nathan)
INSERT INTO LIGNEVENTE VALUES (9, 1, NULL, 10, 13, 10000000010); 

-- Vente n°12 (Client Robert Nathan)
INSERT INTO LIGNEVENTE VALUES (10, 4, NULL, 12, 5, NULL); 

-- Vente n°13 (Client Rousseau Louis)
INSERT INTO LIGNEVENTE VALUES (11, 1, NULL, 13, 19, 10000000013); 

-- Vente n°14 (Client Faure Camille)
INSERT INTO LIGNEVENTE VALUES (12, 2, NULL, 14, 17, 10000000014); 

-- Vente n°15 (Client Bernard Mathis)
INSERT INTO LIGNEVENTE VALUES (13, 1, NULL, 15, 25, 10000000015); 

-- Vente n°16 (Client Morel Jules)
INSERT INTO LIGNEVENTE VALUES (14, 1, NULL, 16, 18, 10000000016);
INSERT INTO LIGNEVENTE VALUES (28, 1, NULL, 14, 1, 10000000014);   

-- Vente n°17 (Client Thomas Léa)
INSERT INTO LIGNEVENTE VALUES (15, 2, NULL, 17, 4, 10000000017);  

-- Vente n°23 (Client Faure Camille)
INSERT INTO LIGNEVENTE VALUES (16, 1, NULL, 23, 8, 10000000023);  
INSERT INTO LIGNEVENTE VALUES (17, 1, NULL, 23, 1, 10000000023);  

-- Vente n°25 (Client Renard Chloé)
INSERT INTO LIGNEVENTE VALUES (18, 3, NULL, 25, 12, 10000000025);

-- Vente n°26 (Client Dubois Hugo)
INSERT INTO LIGNEVENTE VALUES (19, 1, NULL, 26, 24, NULL);

-- Vente n°28 (Client Durand Chloé)
INSERT INTO LIGNEVENTE VALUES (20, 2, NULL, 28, 9, 10000000028);
INSERT INTO LIGNEVENTE VALUES (29, 3, NULL, 20, 20, NULL);   

-- Vente n°30 (Client Vidal Emma)
INSERT INTO LIGNEVENTE VALUES (21, 1, NULL, 30, 30, 10000000030); 

-- Vente n°31 (Client Brun Lucas)
INSERT INTO LIGNEVENTE VALUES (22, 1, NULL, 31, 16, 10000000022); 

-- Vente n°32 (Client Garnier Lola)
INSERT INTO LIGNEVENTE VALUES (23, 2, NULL, 32, 28, 10000000032);  

-- Vente n°33 (Client Lopez Antoine)
INSERT INTO LIGNEVENTE VALUES (24, 1, NULL, 33, 7, 10000000033); 

-- Vente 34
INSERT INTO LIGNEVENTE VALUES (30, 1, NULL, 34, 4, 10000000034);  



-- Initialisation des prix après remboursement ou pas des lignes de ventes
UPDATE LIGNEVENTE lv
SET lv.PRIX_APRÈS_REMBOURSEMENT = (
    SELECT (lv.quantité_vendu * m.prix_public) * (1 - (couv.taux_de_remboursement / 100))
    FROM LOT l
    JOIN MEDICAMENT m ON l.code_cip = m.code_cip
    JOIN VENTE v ON lv.id_Vente = v.id_Vente
    JOIN CLIENT c ON v.id_Client = c.NSSI
    JOIN COUVERTURE couv ON c.Nom_mutuelle = couv.Nom_mutuelle
    WHERE l.num_lot = lv.numero_de_lot
); -- PAS COMPLET, on ne prend  pas en compte la cas où pas ordonnance

--SOLUTION:

UPDATE LIGNEVENTE lv
SET lv.prix_après_remboursement =
    CASE
        WHEN lv.id_ordonnance IS NOT NULL THEN
            (
                SELECT lv.quantité_vendu * m.prix_public
                       * (1 - couv.taux_de_remboursement / 100)
                FROM LOT l
                JOIN MEDICAMENT m ON l.code_cip = m.code_cip
                JOIN VENTE v ON lv.id_Vente = v.id_Vente
                JOIN CLIENT c ON v.id_Client = c.NSSI
                JOIN COUVERTURE couv ON c.Nom_mutuelle = couv.Nom_mutuelle
                WHERE l.num_lot = lv.numero_de_lot
            )
        ELSE
            (
                SELECT lv.quantité_vendu * m.prix_public
                FROM LOT l
                JOIN MEDICAMENT m ON l.code_cip = m.code_cip
                WHERE l.num_lot = lv.numero_de_lot
            )
    END;



-- Initialisation du prix final des  ventes

update vente v
set v.PrixFinal = (
    select sum(lv.prix_après_remboursement)
    from lignevente lv
    where lv.id_Vente = v.id_Vente
);

