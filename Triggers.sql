
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
	IF (NEW.maxGiocatori <=  (SELECT numGiocatori FROM Categoria WHERE nome = NEW.categoria))
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

CREATE OR REPLACE FUNCTION check_state_event() RETURNS trigger AS
$check_state_event$
BEGIN
	IF NEW.idEv IN (SELECT id as idEv FROM Evento WHERE stato = 'chiuso')
		THEN return NEW;
	ELSE RAISE EXCEPTION 'questo evento non è terminato, non e'' possibile inserire la valutazione';
	END IF;
END;
$check_state_event$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_rating_for_player() RETURNS trigger AS
$check_rating_for_player$
BEGIN
	IF NEW.usernameValutatore IN (SELECT username as usernameValutatore FROM UtenteSingoloGioca 
					WHERE idEv IN (SELECT idEv FROM UtenteSingoloGioca WHERE username = NEW.usernameValutato))
		THEN return NEW;
	ELSE RAISE EXCEPTION 'i dati di giocatore valutato o di chi valuta non sono corretti';
	END IF;
END;
$check_rating_for_player$
LANGUAGE plpgsql;


-- un impianto non puo ospitare due eventi contemporaneamente --

CREATE OR REPLACE FUNCTION check_stadium_for_evento() RETURNS trigger AS
$check_stadium_for_evento$
BEGIN
	IF NEW.impianto NOT IN (SELECT impianto   FROM Evento WHERE impianto = NEW.impianto AND data = NEW.data)
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'L''impianto % in data % è occupato per un altro evento!',NEW.impianto,NEW.data;
	END IF;
END;
$check_stadium_for_evento$
LANGUAGE plpgsql;



-- una squadra non può giocare due eventi contemporaneamente --

CREATE OR REPLACE FUNCTION check_team_for_matches() RETURNS trigger AS
$check_team_for_matches$
BEGIN
	IF NEW.nomeSquadra NOT IN (SELECT nomeSquadra   FROM SquadraPartecipaEv  
							   WHERE nomeSquadra = NEW.nomeSquadra AND idEv <> NEW.idEv AND idEv 
							   IN(SELECT id FROM Evento  WHERE data = 
								  (SELECT data from Evento WHERE id = NEW.idEv )))
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'La squadra % in data % partecipa già ad un altro evento!',NEW.nomeSquadra,(SELECT data FROM Evento 
																							   WHERE id = NEW.idEv);
	END IF;
END;
$check_team_for_matches$
LANGUAGE plpgsql;


-- una giocatore non può giocare due eventi contemporaneamente --

CREATE OR REPLACE FUNCTION check_player_for_matches() RETURNS trigger AS
$check_player_for_matches$
BEGIN
	IF NEW.username NOT IN (SELECT username   FROM UtenteSingoloGioca  
							   WHERE username = NEW.username AND idEv <> NEW.idEv AND idEv 
							   IN(SELECT id FROM Evento  WHERE data = 
								  (SELECT data from Evento WHERE id = NEW.idEv )))
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'Il giocatore % in data % partecipa già ad un altro evento!',NEW.username,(SELECT data FROM Evento 
																							   WHERE id = NEW.idEv);
	END IF;
END;
$check_player_for_matches$
LANGUAGE plpgsql;


-- ad un evento singolo possono giocare solo due giocatori --

CREATE OR REPLACE FUNCTION check_partecipants_number_for_player() RETURNS trigger AS
$check_partecipants_number_for_player$
BEGIN
	IF (SELECT COUNT(*) FROM UtenteSingoloGioca WHERE idEv = NEW.idEv) <= 1
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'A questo evento: % possono partecipare solo due giocatori!',NEW.idEV;
	END IF;
END;
$check_partecipants_number_for_player$
LANGUAGE plpgsql;


-- ad un evento a squadre possono giocare solo due squadre --

CREATE OR REPLACE FUNCTION check_partecipants_number_for_team() RETURNS trigger AS
$check_partecipants_number_for_team$
BEGIN
	IF (SELECT COUNT(*) FROM SquadraPartecipaEv WHERE idEv = NEW.idEv) <= 1
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'A questo evento: % possono partecipare solo due squadre!',NEW.idEV;
	END IF;
END;
$check_partecipants_number_for_team$
LANGUAGE plpgsql;



-- un evento che deve ancora svolgersi non puo' avere lo stato chiuso. Un evento aperto non puo' essere già finito!
CREATE OR REPLACE FUNCTION check_event_date() RETURNS trigger AS
$check_event_date$
BEGIN
	IF (NEW.data <= current_date)
		THEN IF (NEW.stato = 'chiuso')
				THEN RETURN NEW;
			ELSE RAISE EXCEPTION 'l''evento % è stato svolto in data % , ergo non può avere lo stato ''aperto''',NEW.id,NEW.data;
			END IF;
	ELSE 
		IF(NEW.stato = 'aperto')
			THEN RETURN NEW;
		ELSE RAISE EXCEPTION 'l''evento % si svolgerà in data % , ergo non può avere lo stato ''chiuso''',NEW.id,NEW.data;
		END IF;
	END IF;
END;
$check_event_date$
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

CREATE TRIGGER check_state_event
BEFORE INSERT OR UPDATE ON ValutazioneUtenti
FOR EACH ROW
EXECUTE PROCEDURE check_state_event();

CREATE TRIGGER check_rating_for_player
BEFORE INSERT OR UPDATE ON ValutazioneUtenti
FOR EACH ROW
EXECUTE PROCEDURE check_rating_for_player();

-- un impianto non puo ospitare due eventi contemporaneamente --
CREATE TRIGGER check_stadium_for_event
BEFORE INSERT OR UPDATE ON Evento
FOR EACH ROW
EXECUTE PROCEDURE check_stadium_for_evento();

-- una squadra non può giocare due eventi contemporaneamente --
CREATE TRIGGER check_team_for_matches
BEFORE INSERT OR UPDATE ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE check_team_for_matches();

-- una giocatore non può giocare due eventi contemporaneamente --
CREATE TRIGGER check_player_for_matches
BEFORE INSERT OR UPDATE ON UtenteSingoloGioca
FOR EACH ROW
EXECUTE PROCEDURE check_player_for_matches();

-- ad un evento singolo possono giocare solo due giocatori --
CREATE TRIGGER check_partecipants_number_for_player
BEFORE INSERT OR UPDATE ON UtenteSingoloGioca
FOR EACH ROW
EXECUTE PROCEDURE check_partecipants_number_for_player();

-- ad un evento a squadre possono giocare solo due squadre --
CREATE TRIGGER check_partecipants_number_for_team
BEFORE INSERT OR UPDATE ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE check_partecipants_number_for_team();

-- un evento che deve ancora svolgersi non puo' avere lo stato chiuso. Un evento aperto non puo' essere già finito!
CREATE TRIGGER check_event_date
BEFORE INSERT OR UPDATE ON Evento
FOR EACH ROW
EXECUTE PROCEDURE check_event_date();
