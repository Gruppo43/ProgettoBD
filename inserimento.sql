/* USER INSERTIONS */
INSERT INTO Utente VALUES ('YouKnowNothing', 'h7eRl97T', 'Jon', 'Snow', '02/10/1997', 'Winterfell', false , '3986665289', 'S4557890', 'Filosofia','premium' );
INSERT INTO Utente VALUES ('LupoSolitario', 'h9fQl966', 'Arya', 'Stark', '25/01/1995', 'Winterfell', true , '3996876528', 'S4265782', 'Chimica','standard' );
INSERT INTO Utente VALUES ('MortoCheCammina', 'd5eRo93W', 'Glenn', 'Rhee', '21/12/1983', 'Yeun Sang-yeop', false , '3419535289', 'S4297611', 'Informatica', 'premium');
INSERT INTO Utente VALUES ('LaMiaLucille', 'h7eRl97T', 'Negan', 'Morgan', '22/04/1966', 'Seattle', false , '398667933', 'S8364027', 'Informatica' , 'premium');
INSERT INTO Utente VALUES ('BlueMeth22', 's3jPl912', 'Jesse', 'Pinkman', '08/03/1998', 'Albuquerque', true , '3996876528', 'S4265782', 'Chimica', 'standard');
INSERT INTO Utente VALUES ('UsatoChePiace', 'k1jGlkd6', 'Piper', 'Chapman', '06/11/1980', 'Boston', true , '3996000221', 'S4261295', 'Economia' , 'standard');
INSERT INTO Utente VALUES ('CantaStorie', 'l0jHlhd23', 'Suzanne', 'Warren', '10/09/1992', 'Boston', true , '346898181', 'S4325914', 'Economia', 'premium' );
INSERT INTO Utente VALUES ('StarLord', 'GhOOgj830', 'Peter Jason', 'Quill', '30/01/1965', 'Denver', true , '399765432', 'S8907319', 'Filosofia' , 'premium');
INSERT INTO Utente VALUES ('DontKnowWhereSoulGemIs', 'Khdo97jd54', 'Gamora', 'Ben Titan', '23/09/1999', 'Planet Zen-Whoberi', true , '3996663331', 'S8395512', 'Informatica', 'standard' );
INSERT INTO Utente VALUES ('Pagina394', 'TiOdioPotter', 'Severus', 'Piton', '01/09/1960', 'Eileen Prince', false , '3771234568', 'S4356013', 'Stregoneria', 'premium' );
INSERT INTO Utente VALUES ('Polisucco61', 'Mad-eye11', 'Alastor', 'Moody', '21/09/1961', 'Somewhere in Scotland', false , '3359916523', 'S5491132', 'Stregoneria', 'standard' );
INSERT INTO Utente VALUES ('HobbitCoraggioso', '748hdi8HF89', 'Bilbo', 'Baggins', '22/05/1930', 'Hobbiton', false , '339291755', 'S8229951', 'Stregoneria', 'premium' );


/* Categories */

INSERT INTO Categoria VALUES ('Calcio', 'vince la squadra che totalizza più goal',32,true);
INSERT INTO Categoria VALUES ('Tennis', 'vince chi totalizza più punti', 2);
INSERT INTO Categoria VALUES ('Pallavolo', 'vince chi fa più punti',24);
INSERT INTO Categoria VALUES ('PingPong', 'vince chi fa più punti',2);
INSERT INTO Categoria VALUES ('Quiddich','vince chi cattura il boccino fatto di oro', 12);
INSERT INTO Categoria VALUES ('Scacchi','vince chi fa scacco matto',2 ,true);


/* Teams */

/*Quiddich*/

INSERT INTO Squadra VALUES('The North Remembers','Quiddich','YouKnowNothing',12,8,'bianco','The King of the north');
INSERT INTO Squadra VALUES('Guardians of the Galaxy','Quiddich','StarLord',12,8,'rosso','Rocket mi ha rubato di nuovo il pc?');
INSERT INTO Squadra VALUES('Ordine della Fenice','Quiddich','Pagina394',12,8,'verde','Giuro solennemente di non avere buone intenzioni');
INSERT INTO Squadra VALUES('Compagnia dell''anello', 'Quiddich','HobbitCoraggioso',12,8,'viola','il mio tesoro');
INSERT INTO Squadra VALUES('Team Alexandria','Quiddich','LaMiaLucille',12,8,'giallo','Ambarabaccicicoco');
INSERT INTO Squadra VALUES('Virtus Piscatella', 'Quiddich','CantaStorie',12,8,'blu','Crazy eyes');


/*Calcio */

INSERT INTO Squadra VALUES('The North Remembers','Calcio','YouKnowNothing',30,15,'bianco','The King of the north');
INSERT INTO Squadra VALUES('Guardians of the Galaxy','Calcio','StarLord',30,15,'rosso','Rocket mi ha rubato di nuovo il pc?');
INSERT INTO Squadra VALUES('Ordine della Fenice','Calcio','Pagina394',30,15,'verde','Giuro solennemente di non avere buone intenzioni');
INSERT INTO Squadra VALUES('Compagnia dell''anello', 'Calcio','HobbitCoraggioso',30,15,'viola','il mio tesoro');
INSERT INTO Squadra VALUES('Team Alexandria','Calcio','LaMiaLucille',30,15,'giallo','Ambarabaccicicoco');
INSERT INTO Squadra VALUES('Virtus Piscatella', 'Calcio','CantaStorie',30,15,'blu','Crazy eyes');


/*pallavolo*/

INSERT INTO Squadra VALUES('The North Remembers','Pallavolo','YouKnowNothing',20,12,'bianco','The King of the north');
INSERT INTO Squadra VALUES('Guardians of the Galaxy','Pallavolo','StarLord',20,12,'rosso','Rocket mi ha rubato di nuovo il pc?');
INSERT INTO Squadra VALUES('Ordine della Fenice','Pallavolo','Pagina394',20,12,'verde','Giuro solennemente di non avere buone intenzioni');
INSERT INTO Squadra VALUES('Compagnia dell''anello', 'Pallavolo','HobbitCoraggioso',20,12,'viola','il mio tesoro');
INSERT INTO Squadra VALUES('Team Alexandria','Pallavolo','LaMiaLucille',20,12,'giallo','Ambarabaccicicoco');
INSERT INTO Squadra VALUES('Virtus Piscatella', 'Pallavolo','CantaStorie',20,12,'blu','Crazy eyes');



/* impianti */

INSERT INTO Impianto VALUES ('La Terra di mezzo','Baker street 21B','345692145','Orda@gmail.com',314.22,112.13);
INSERT INTO Impianto VALUES ('Accademia Beauxbaton','via dei babbani 14','333999838','Fleaur@gmail.com',390.22,10.43);
INSERT INTO Impianto VALUES ('Castel Granito','fondo delle pulci 24','345673845','HoldTheDoor@gmail.it',4.1,22.13);
INSERT INTO Impianto VALUES ('Terminus','via segui le rotaie 11','949490015','SafePlace@gmail.com',10,2.112);




/* to be modified */
/*
INSERT INTO Forma  VALUES (12, 132);
INSERT INTO Forma  VALUES (13, 132);
INSERT INTO Forma  VALUES (12, 133);
INSERT INTO Forma  VALUES (12, 12);
INSERT INTO Forma  VALUES (12, 13);
INSERT INTO Forma  VALUES (121, 132);

INSERT INTO PartecipaEv VALUES ('I cani', 'Calcio', 12, 2);
INSERT INTO PartecipaEv VALUES ('I gatti' 'Calcio', 13, 1);
INSERT INTO PartecipaEv VALUES ('Vincitori', 'Pallavolo', 132, 0);
INSERT INTO PartecipaEv VALUES ('Perdenti', 'Pallavolo', 132, 1);
INSERT INTO PartecipaEv VALUES ('Buffi', 'Pallavolo', 133, 3);

INSERT INTO UtenteGioca VALUES ('ciro', 132, 2);
INSERT INTO UtenteGioca VALUES ('ciro2', 133, 1);
INSERT INTO UtenteGioca VALUES ('anna', 11, 0);
INSERT INTO UtenteGioca VALUES ('pippo', 122, 2);
INSERT INTO UtenteGioca VALUES ('pluto', 14, 3);

INSERT INTO Gare VALUES ('pippo', 'Calcio', 4);
INSERT INTO Gare VALUES ('pluto', 'Calcio', 2);
INSERT INTO Gare VALUES ('pluto', 'Pallavolo', 1);
INSERT INTO Gare VALUES ('ciro', 'Calcio', 1);
INSERT INTO Gare VALUES ('ciro2', 'Calcio', 2);
INSERT INTO Gare VALUES ('ciro', 'Tennis', 2);

INSERT INTO Valutazione VALUES ('pippo', 'pluto', 14, 5);
INSERT INTO Valutazione VALUES ('pippo', 'ciro', 132, 7);
INSERT INTO Valutazione VALUES ('pluto', 'pippo', 122, 9);
INSERT INTO Valutazione VALUES ('ciro', 'pluto', 122, 8);
INSERT INTO Valutazione VALUES ('anna', 'pluto', 14, 1);
*/
