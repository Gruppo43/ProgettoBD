

/* Functions */

CREATE OR REPLACE FUNCTION check_premium_for_teams() RETURNS trigger AS
$check_premium_for_teams$
BEGIN
	IF NEW.creatore NOT IN (SELECT username  FROM Utente WHERE tipo = 'standard')
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'L''utente % non è premium, non può creare la squadra!',NEW.creatore;
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
	IF NEW.idEv IN (SELECT id  FROM Evento WHERE stato = 'chiuso')
		THEN return NEW;
	ELSE RAISE EXCEPTION 'questo evento non è terminato, non e'' possibile inserire la valutazione';
	END IF;
END;
$check_state_event$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_rating_for_player() RETURNS trigger AS
$check_rating_for_player$
BEGIN
	IF NEW.usernameValutatore IN (SELECT username  FROM UtenteSingoloGioca 
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


-- un evento deve essere della stessa categoria del torneo di cui fa parte!
CREATE OR REPLACE FUNCTION check_tournament_category() RETURNS trigger AS
$check_tournament_category$
BEGIN
	IF ((SELECT categoria FROM Torneo where id = NEW.idT) <> (SELECT categoria FROM Evento WHERE id = NEW.idEV))
		THEN RAISE EXCEPTION 'L''evento % fa parte di una categoria divergente da quella del torneo %',NEW.idEV,NEW.idT;
	ELSE RETURN NEW;
	END IF;
END;
$check_tournament_category$
LANGUAGE plpgsql;


-- un determinato evento non puo far parte di due o piu tornei
CREATE OR REPLACE FUNCTION check_unique_event_in_tournament() RETURNS trigger AS
$check_unique_event_in_tournament$
BEGIN
	IF (SELECT count(*) FROM EventoInTorneo WHERE idEV = NEW.idEV) = 1
		THEN RAISE EXCEPTION 'L''evento % fa già parte di un altro torneo!',NEW.idEV;
	ELSE RETURN NEW;
	END IF;
END;
$check_unique_event_in_tournament$
LANGUAGE plpgsql;


-- solo un utente premium puo creare un torneo
CREATE OR REPLACE FUNCTION check_premium_for_tournament() RETURNS trigger AS
$check_premium_for_tournament$
BEGIN
	IF NEW.creatore NOT IN (SELECT username  FROM Utente WHERE tipo = 'standard')
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'L''utente % non è premium, non può creare il torneo!',NEW.creatore;
	END IF;
END;
$check_premium_for_tournament$
LANGUAGE plpgsql;


-- non si puo aggiungere un esito fi un evento aperto
CREATE OR REPLACE FUNCTION check_if_accessible_event() RETURNS trigger AS
$check_if_accessible_event$
BEGIN
	IF ((SELECT stato FROM Evento WHERE id = NEW.idEV) = 'aperto')
		THEN RAISE EXCEPTION 'L''evento % risulta essere aperto, non è possibile quindi aggiuungere un esito!
		Se l''evento si è concluso preghiamo il gestore del database di modificare lo stato dell''evento da ''aperto''
		a ''chiuso''',NEW.idEv;
	
	ELSE RETURN NEW;
	END IF;
END;
$check_if_accessible_event$
LANGUAGE plpgsql;


--solo un utente premium può accettare o rifiutare le candidature
CREATE OR REPLACE FUNCTION check_premium_accepts_applications() RETURNS trigger AS 
$check_premium_accepts_applications$
BEGIN
	IF 
		NEW.Supervisore NOT IN (SELECT Username  FROM Utente WHERE Tipo = 'standard')
	THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Solo un utente premium può accettare o rifiutare le candidature!';
	END IF;
END;
$check_premium_accepts_applications$
LANGUAGE plpgsql;
				
--un utente può iscriversi solo ad un evento aperto
CREATE OR REPLACE FUNCTION sign_up_for_open_events_only() RETURNS trigger AS
$sign_up_for_open_events_only$
BEGIN
	IF NEW.Evento NOT IN (SELECT Id  FROM Evento WHERE Stato = 'chiuso')
	THEN RETURN NEW;
	ELSE RAISE EXCEPTION 'Un utente può iscriversi solo ad un evento aperto!';
	END IF;
END;
$sign_up_for_open_events_only$
LANGUAGE plpgsql


-- una squadra non puo partecipare ad un evento se non ha raggiunto il numero minimo di candidature
CREATE OR REPLACE FUNCTION check_min_players_for_team() RETURNS trigger AS
$check_min_players_for_team$
BEGIN
	IF ((SELECT count(*) FROM Candidatura WHERE Squadra = NEW.nomeSquadra AND categoria = NEW.nomeC AND stato = 'accettata') 
		>= (SELECT minGiocatori FROM Squadra WHERE nome = NEW.nomeSquadra AND categoria = NEW.nomeC))
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'la squadra % della categoria % non ha raggiunto il numero minimo di candidature per disputare questo
	evento',NEW.nomeSquadra,NEW.nomeC;
	END IF;
END;
$check_min_players_for_team$
LANGUAGE plpgsql;


-- una squadra non puo' superare il numero massimo di giocatori previsto
CREATE OR REPLACE FUNCTION check_max_players_for_team() RETURNS trigger AS
$check_max_players_for_team$
BEGIN
	IF (NEW.stato = 'accettata')
		THEN IF ((SELECT count(*) FROM Candidatura WHERE squadra = NEW.squadra AND categoria = NEW.categoria) = 
				(SELECT maxGiocatori FROM Squadra WHERE nome = NEW.squadra AND categoria = NEW.categoria))
		 		THEN RAISE EXCEPTION 'Non si possono accettare ulteriori candidature per l squadra %
			 	della categoria %',NEW.Squadra,NEW.categoria;
			 ELSE RETURN NEW;
			END IF;
	ELSE  RETURN NEW;
	END IF;
END;
$check_max_players_for_team$
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

-- un evento deve essere della stessa categoria del torneo di cui fa parte!
CREATE TRIGGER check_tournament_category
BEFORE INSERT OR UPDATE ON EventoInTorneo
FOR EACH ROW
EXECUTE PROCEDURE check_tournament_category();

-- un determinato evento non puo far parte di due o piu tornei
CREATE TRIGGER check_unique_event_in_tournament
BEFORE INSERT OR UPDATE ON EventoInTorneo
FOR EACH ROW
EXECUTE PROCEDURE check_unique_event_in_tournament();

-- solo un utente premium puo creare un torneo
CREATE TRIGGER check_premium_for_tournament
BEFORE INSERT OR UPDATE ON Torneo
FOR EACH ROW
EXECUTE PROCEDURE check_premium_for_tournament();

-- non si puo aggiungere un esito di un evento aperto
CREATE TRIGGER check_if_accessible_event_for_team
BEFORE INSERT OR UPDATE ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE check_if_accessible_event();*/

--solo un utente premium può accettare o rifiutare le candidature
CREATE TRIGGER check_premius_accepts_applications
BEFORE INSERT OR UPDATE ON Candidatura
FOR EACH ROW
EXECUTE PROCEDURE check_premium_accepts_applications();
				
--un utente può iscriversi solo ad un evento aperto
CREATE TRIGGER sign_up_for_open_events_only
BEFORE INSERT OR UPDATE ON Iscrizione
FOR EACH ROW
EXECUTE PROCEDURE sign_up_for_open_events_only();



