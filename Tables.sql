set search_path to  'progettoBD';


CREATE TABLE Utente(
username varchar(20) primary key,
psw varchar(20) not null,
nome varchar(20) not null,
cognome varchar(20) not null,
annoN date not null,
luogoN varchar(20) not null,
foto boolean,
tel integer(10) not null,
matricola varchar(8) not null,
CorsoDiStudio varchar(20) not null,
tipo varchar(8) not null
check (tipo = 'standard' or tipo = 'premium')
check (annoN < current_date)
);

CREATE TABLE Torneo(
id varchar(20) primary key,
restrizioni varchar(50) default null,
descrizione varchar(60) default null,
modalità varchar(20) not null,
sponsor varchar(20) default null,
premi varchar(20) not null,
tipo varchar(10) not null,
creatore varchar(20) default null,
foreign key(creatore) references Utente(username) on delete  no action on update cascade,
check(tipo = 'singolo' or tipo = 'a squadre')
);


CREATE TABLE Categoria(
nome varchar(20) primary key,
regolamento varchar(50) not null,
numGiocatori int not null,
foto boolean default false
);

CREATE TABLE Squadra(
nome varchar(20) not null,
categoria varchar(20) not null,
creatore varchar(20) default null,
maxGiocatori integer(2) not null,
minGiocatori integer(2) not null,
coloreMaglia varchar(10) not null,
note varchar(50) default null,
primary key(nome,categoria),
foreign key(categoria) references Categoria(nome) on delete  no action on update cascade,
foreign key(creatore) references Utente(username) on delete  no action on update cascade,
check(minGiocatori < maxGiocatori)
);



CREATE TABLE Impianto (
nome varchar(20) primary key,
via varchar(50) not null,
telefono integer(10) not null,
email varchar(20) not null,
longitudine float not null,
latitudine float not null
);


CREATE TABLE Evento (
id varchar(20) primary key,
data date not null,
stato varchar(15) not null,
durata integer(3) not null,
nomeSquadraCasa varchar(20) default null,
nomeSquadraOspite varchar(20) default null,
impianto varchar(20) not null,
categoria varchar(20) not null,
tipo varchar(15) not null,
foreign key(impianto) references Impianto(nome) on delete  no action on update cascade,
foreign key(categoria) references Categoria(nome) on delete  no action on update cascade,
check(data <= current_date),
check(durata > 0),
check(stato = 'aperto' or stato = 'chiuso'),
check(tipo = 'singolo' or tipo = 'a squadre')
-- maybe, should i add player 1 and player 2?
-- remember to create the trigger!! cannot exist sq1 or sq2 field if type == singolo!
);



﻿CREATE TABLE Forma(
idT integer(8) references Torneo (id) on delete  no action on update cascade,
idEv integer(8) references Evento (id) on delete  no action on update cascade,
primary key(idT, idEv)
);

CREATE TABLE PartecipaEv(
nomeS varchar(30) references Squadra (nomeS)  on delete  no action on update cascade,
nomeC varchar(30) references Categoria (nomeC)on delete  no action on update cascade,
idEv integer(8) references Evento (id) on delete  no action on update cascade,
punti integer(5) not null,
primary key(nomeS, nomeC, idEv)
);

CREATE TABLE UtenteGioca(
username varchar(30) references Utente (username) on delete  no action on update cascade,
idEv integer(8) references Evento (id) on delete  no action on update cascade,
setvinti integer(3),
primary key(username, idEv)
);

CREATE TABLE Gare(
username varchar(30) references Utente (username)on delete  no action on update cascade,
nomeC varchar(30) references Categoria (nomeC) on delete  no action on update cascade,
gareDisputate integer(5),
primary key(username, nomeC)
);

CREATE TABLE Valutazione(
usernameValutatore varchar(30) references Utente (username) on delete  no action on update cascade,
usernameValutato varchar(30) references Utente (username) on delete  no action on update cascade,
idEv integer(8) references Evento (id) on delete  no action on update cascade,
voto integer(2) check (voto  between 0 and 10),
primary key(usernameValutatore, usernameValutato, username)
);