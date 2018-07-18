set search_path to 'ProgettoBD';


CREATE TABLE Utente(
username varchar(25) primary key,
psw varchar(20) not null,
nome varchar(20) not null,
cognome varchar(20) not null,
annoN date not null,
luogoN varchar(35) not null,
foto boolean not null,
tel varchar(10) not null,
matricola varchar(10) not null,
CorsoDiStudio varchar(20) not null,
tipo varchar(8) not null
check (tipo = 'standard' or tipo = 'premium')
check (annoN < current_date),
check(tel similar to '([0-9]+)')
);

CREATE TABLE Categoria(
nome varchar(20) primary key,
regolamento varchar(500) not null,
numGiocatori numeric(2) not null,
foto boolean default false
);

CREATE TABLE Torneo(
id numeric(8) primary key,
restrizioni varchar(50) default null,
descrizione varchar(100) default null,
modalità varchar(50) not null,
categoria varchar(20) not null,
sponsor varchar(20) default null,
premi varchar(20) not null,
tipo varchar(10) not null,
creatore varchar(20) default null,
foreign key(creatore) references Utente(username) on delete  no action on update cascade,
foreign key(categoria) references Categoria(nome) on delete no action on update cascade,
check(tipo = 'singolo' or tipo = 'a squadre'),
check(modalità = 'eliminazione diretta' or modalità = 'girone all''italiana' or modalità = 'misto')
);




CREATE TABLE Squadra(
nome varchar(30) not null,
categoria varchar(20) not null,
creatore varchar(25) default null,
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
nome varchar(25) primary key,
via varchar(50) not null,
telefono varchar(10) not null,
email varchar(20) not null,
longitudine float not null,
latitudine float not null,
check(telefono similar to '([0-9]+)')
);


CREATE TABLE Evento (
id numeric(8) primary key,
data date not null,
stato varchar(15) not null,
durata numeric(3) not null,
impianto varchar(25) not null,
categoria varchar(20) not null,
tipo varchar(10) not null,
creatore varchar(25) not null,
foreign key(impianto) references Impianto(nome) on delete  no action on update cascade,
foreign key(categoria) references Categoria(nome) on delete  no action on update cascade,
foreign key(creatore) references Utente(username) on delete  no action on update cascade,
check(durata > 0),
check(stato = 'aperto' or stato = 'chiuso'),
check(tipo = 'singolo' or tipo = 'a squadre')
);



CREATE TABLE EventoInTorneo(
idT numeric(8) references Torneo (id) on delete  no action on update cascade,
idEv numeric(8) references Evento (id) on delete  no action on update cascade,
primary key(idT, idEv)
);

CREATE TABLE EsitoSingolo(
idEv numeric(8) references Evento(id) on delete no action on update cascade,
giocatore1 varchar(25) references Utente(username) on delete no action on update cascade,
punteggioGiocatore1 numeric(2), 
giocatore2 varchar(25) references Utente(username) on delete no action on update cascade,
punteggioGiocatore2 numeric(2),
durata numeric(4), 
primary key(idEv),
check(punteggioGiocatore1 >= 0 and punteggioGiocatore2 >=0)
);

CREATE TABLE EsitoSquadre(
idEv numeric(8) references Evento (id) on delete  no action on update cascade,
nomeSquadra1 varchar(30) not null,
nomeSquadra2 varchar(30) not null,
categoriasq1 varchar(30) not null,
categoriasq2 varchar(30) not null,
puntisq1 numeric(2) not null,
puntisq2 numeric(2) not null,
foreign key(nomeSquadra1,categoriasq1) references Squadra(nome) on delete  no action on update cascade,
foreign key(nomeSquadra2,categoriasq2) references Squadra(nome) on delete  no action on update cascade,
primary key(idEv),
check(categoriasq1 = categoriasq2),
check(puntisq1 >= 0),
check(puntisq2 >= 0)
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
corsoDiStudi varchar(50),
categoria varchar(20),
foreign key (categoria)references Categoria(nome) on delete  no action on update cascade,
primary key(corsoDiStudi,categoria)
);

CREATE TABLE Post(
data date,
testo varchar(800) not null,
foto boolean not null,
creatore varchar(22) not null,
corsoDiStudi varchar(20) not null,  
categoria varchar(20) not null, 
foreign key (creatore)references Utente(username) on delete  no action on update cascade,
foreign key (corsoDiStudi,categoria) references Forum(corsoDiStudi,categoria) on delete  no action on update cascade,
primary key(data,creatore),
check(data <= current_date)
);

CREATE TABLE Candidatura(
stato varchar(9) not null,
supervisore varchar(25) not null,
candidato varchar(25) not null,
squadra varchar(30) not null,
categoria varchar(20) not null,
foreign key (candidato)references Utente(username) on delete  no action on update cascade,
foreign key (squadra,categoria)references Squadra(nome,categoria) on delete  no action on update cascade,
foreign key (supervisore)references Utente(username),
primary key (Candidato,Squadra,categoria),
check (stato = 'accettata' or stato = 'rifiutata'),
check (supervisore != candidato)
);

CREATE TABLE Iscrizione(
data date,
stato varchar(20) not null,
studente varchar(25) not null,
evento numeric(8) not null,
foreign key (studente)references Utente(username) on delete  no action on update cascade,
foreign key (evento)references Evento(id) on delete  no action on update cascade,
primary key (data,studente,evento),
check (stato = 'confermato' or stato = 'rifiutato'),
check(data <= current_date)
);

CREATE TABLE PartecipaATorneo(
torneo numeric(8) not null,
squadra varchar(30) not null, 
categoria varchar(20) not null,
foreign key (torneo)references Torneo(id)on delete  no action on update cascade,
foreign key (squadra,categoria)references Squadra(nome,categoria) on delete  no action on update cascade, 
primary key (torneo,squadra,categoria)
);

CREATE TABLE IscrittoATorneo(
torneo numeric(8),
studente varchar(25),
foreign key (torneo)references Torneo(id) on delete  no action on update cascade,
foreign key(studente)references Utente(username) on delete  no action on update cascade,
primary key (torneo,studente)
);
