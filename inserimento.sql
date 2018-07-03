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
