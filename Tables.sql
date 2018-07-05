set search_path to 'ProgettoBD';


CREATE TABLE Utente(
username varchar(22) primary key,
psw varchar(20) not null,
nome varchar(20) not null,
cognome varchar(20) not null,
annoN date not null,
luogoN varchar(35) not null,
foto boolean,
tel varchar(10) not null,
matricola varchar(8) not null,
CorsoDiStudio varchar(20) not null,
tipo varchar(8) not null
check (tipo = 'standard' or tipo = 'premium')
check (annoN < current_date),
check(tel SIMILAR TO '([0-9]+)')
);

CREATE TABLE Categoria(
nome varchar(20) primary key,
regolamento varchar(50) not null,
numGiocatori numeric(2) not null,
foto boolean default false
);

CREATE TABLE Torneo(
id numeric(8) primary key,
restrizioni varchar(50) default null,
descrizione varchar(60) default null,
modalità varchar(35) not null,
categoria varchar(20) not null,
sponsor varchar(20) default null,
premi varchar(20) not null,
tipo varchar(10) not null,
creatore varchar(20) default null,
foreign key(creatore) references Utente(username) on delete  no action on update cascade,
foreign key(categoria) references Categoria(nome) on delete no action on update cascade,
check(tipo = 'singolo' or tipo = 'a squadre'),
check(modalità = 'Eliminazione diretta' or modalità = 'Girone all''italiana' or modalità = 'Misto')
);




CREATE TABLE Squadra(
nome varchar(30) not null,
categoria varchar(20) not null,
creatore varchar(20) default null,
maxGiocatori numeric(2) not null,
minGiocatori numeric(2) not null,
coloreMaglia varchar(10) not null,
note varchar(50) default null,
foreign key(categoria) references Categoria(nome) on delete  no action on update cascade,
foreign key(creatore) references Utente(username) on delete  no action on update cascade,
primary key (nome,categoria),
check(minGiocatori <= maxGiocatori),
check(minGiocatori > 0)
);



CREATE TABLE Impianto (
nome varchar(20) primary key,
via varchar(50) not null,
telefono varchar(10) not null,
email varchar(20) not null,
longitudine float not null,
latitudine float not null,
check(telefono SIMILAR TO '([0-9]+)')
);


CREATE TABLE Evento (
id numeric(8) primary key,
data date not null,
stato varchar(15) not null,
durata numeric(3) not null,
impianto varchar(20) not null,
categoria varchar(20) not null,
tipo varchar(15) not null,
foreign key(impianto) references Impianto(nome) on delete  no action on update cascade,
foreign key(categoria) references Categoria(nome) on delete  no action on update cascade,
check(data <= current_date),
check(durata > 0),
check(stato = 'aperto' or stato = 'chiuso'),
check(tipo = 'singolo' or tipo = 'a squadre')
);



CREATE TABLE EventoInTorneo(
idT numeric(8) references Torneo (id) on delete  no action on update cascade,
idEv numeric(8) references Evento (id) on delete  no action on update cascade,
primary key(idT, idEv)
);

CREATE TABLE SquadraPartecipaEv(
nomeSquadra varchar(30),
nomeC varchar(30),
idEv numeric(8) references Evento (id) on delete  no action on update cascade,
punti numeric(5) not null,
foreign key(nomeSquadra,nomeC) references Squadra(nome,categoria),
primary key(nomeSquadra, nomeC, idEv)
);

CREATE TABLE UtenteSingoloGioca(
username varchar(30) references Utente (username) on delete  no action on update cascade,
idEv numeric(8) references Evento (id) on delete  no action on update cascade,
setvinti numeric(3) not null,
primary key(username, idEv)
);

CREATE TABLE MatchDisputati(
username varchar(30) references Utente (username)on delete  no action on update cascade,
nomeC varchar(30) references Categoria (nome) on delete  no action on update cascade,
gareDisputate numeric(5),
primary key(username, nomeC)
);

CREATE TABLE ValutazioneUtenti(
usernameValutatore varchar(30) references Utente (username) on delete  no action on update cascade,
usernameValutato varchar(30) references Utente (username) on delete  no action on update cascade,
idEv numeric(8) references Evento (id) on delete  no action on update cascade,
voto numeric(2) check (voto  between 0 and 10),
check(usernameValutatore != usernameValutato),
primary key(usernameValutatore, usernameValutato,idEv)
);

CREATE TABLE Forum(
CorsoDiStudi VARCHAR(50),
Categoria VARCHAR(20),
FOREIGN KEY (Categoria)references Categoria(Nome) on delete  no action on update cascade,
PRIMARY KEY(CorsoDiStudi,Categoria)
);

CREATE TABLE Post(
Data CHAR(9),
Testo VARCHAR(800) NOT NULL,
Foto BOOLEAN DEFAULT NULL,
Creatore VARCHAR(22) NOT NULL,
CorsoDiStudi VARCHAR(20) NOT NULL,  
Categoria VARCHAR(20) NOT NULL, 
FOREIGN KEY (Creatore)references Utente(Username) on delete  no action on update cascade,
FOREIGN KEY (CorsoDiStudi,Categoria) references Forum(CorsoDiStudi,Categoria) on delete  no action on update cascade,
PRIMARY KEY(Data,Creatore)
);

CREATE TABLE Candidatura(
Stato VARCHAR(9) NOT NULL,
Supervisore VARCHAR(22) NOT NULL,
Candidato VARCHAR(22) NOT NULL,
Squadra VARCHAR(30) NOT NULL,
Categoira VARCHAR(20) NOT NULL,
FOREIGN KEY (Candidato)references Utente(Username) on delete  no action on update cascade,
FOREIGN KEY (Squadra,Categoria)references Squadra(Nome,Categoria) on delete  no action on update cascade,
FOREIGN KEY (Supervisore)references Utente(Username),
PRIMARY KEY (Candidato,Squadra),
CHECK (Stato = 'Accettata' OR Stato = 'Rifiutata'),
CHECK (Supervisore != Candidato)
);

CREATE TABLE Iscrizione(
Data CHAR(9),
Stato VARCHAR(9) NOT NULL,
Studente VARCHAR(22) NOT NULL,
Evento NUMERIC(8) NOT NULL,
FOREIGN KEY (Studente)references Utente(Username) on delete  no action on update cascade,
FOREIGN KEY (Evento)references Evento(Id) on delete  no action on update cascade,
PRIMARY KEY (Data,Studente,Evento),
CHECK (Stato = 'Confermato' OR Stato = 'Rifiutato')
);

CREATE TABLE PartecipaATorneo(
Torneo NUMERIC(8),
Squadra NUMERIC(8), 
Categoria VARCHAR(20),
FOREIGN KEY (Torneo)references Torneo(Id)on delete  no action on update cascade,
FOREIGN KEY (Squadra)references Squadra(Id) on delete  no action on update cascade, 
FOREIGN KEY (Categoria)references Categoria(Nome) on delete  no action on update cascade,
PRIMARY KEY (Torneo,Squadra,Categoria)
);

CREATE TABLE IscrittoATorneo(
Torneo NUMERIC(8),
Studente VARCHAR(22),
FOREIGN KEY (Torneo)references Torneo(Id) on delete  no action on update cascade,
FOREIGN KEY(Studente)references Utente(Username) on delete  no action on update cascade,
PRIMARY KEY (Torneo,Studente)
);
