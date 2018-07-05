
/* Functions */

CREATE OR REPLACE FUNCTION check_premium_for_teams() RETURNS trigger AS
$check_premium_for_teams$
BEGIN
	IF NEW.creatore NOT IN (SELECT username as creatore FROM Utente WHERE tipo = 'standard')
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'solo un utente premium può creare una squadra!';
	END IF;
END;
$check_premium_for_teams$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_players_number() RETURNS trigger AS
$check_players_number$
BEGIN
	IF NEW.maxGiocatori <=  (SELECT numGiocatori FROM Categoria WHERE nome = NEW.categoria)
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'questa categoria non prevede cosi tanti giocatori!';
	END IF;
END;
$check_players_number$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_event_type_for_team() RETURNS trigger AS
$check_event_type_for_team$
BEGIN
	IF NEW.idEv NOT IN (SELECT id  FROM Evento WHERE tipo = 'singolo')
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'una squadra non può partecipare ad un evento per singoli';
	END IF;
END;
$check_event_type_for_team$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION check_event_type_for_player() RETURNS trigger AS
$check_event_type_for_player$
BEGIN
	IF NEW.idEv NOT IN (SELECT id  FROM Evento WHERE tipo = 'a squadre')
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'un singolo non può giocare in un evento a squadre!';
	END IF;
END;
$check_event_type_for_player$
LANGUAGE plpgsql;


/* Triggers */

CREATE TRIGGER check_premium_for_teams
BEFORE INSERT OR UPDATE ON Squadra
FOR EACH ROW
EXECUTE PROCEDURE check_premium_for_teams();

CREATE TRIGGER check_players_number
BEFORE INSERT OR UPDATE ON Squadra
FOR EACH ROW
EXECUTE PROCEDURE check_players_number();

CREATE TRIGGER check_event_type_for_team
BEFORE INSERT OR UPDATE ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE check_event_type_for_team();

CREATE TRIGGER check_event_type_for_player
BEFORE INSERT OR UPDATE ON UtenteSingoloGioca
FOR EACH ROW
EXECUTE PROCEDURE check_event_type_for_player();


