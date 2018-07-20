


--solo un utente premium può creare una squadra
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


--il numero minimo massimo di giocatori di una squadra non può essere minore del numero minimo previsto per quella categoria
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

--ci si può valutare solamente se l'evento si è chiuso
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


-- verificare che il valutatore ed il valutato abbiano giocato effettivamente lo stesso evento
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


-- una squadra non può giocare due eventi contemporaneamente per prima squadra --
CREATE OR REPLACE FUNCTION check_team1_for_matches() RETURNS trigger AS
$check_team1_for_matches$
BEGIN 
	IF NEW.nomeSquadra1 NOT IN (SELECT nomeSquadra1 FROM EsitoSquadre WHERE nomeSquadra1 = NEW.nomeSquadra1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.nomeSquadra1 NOT IN (SELECT nomeSquadra2 FROM EsitoSquadre WHERE nomeSquadra2 = NEW.nomeSquadra1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'La squadra % in data % partecipa già ad un altro evento!',NEW.nomeSquadra1,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv);
   END IF;
END;																						  
$check_team1_for_matches$
LANGUAGE plpgsql;

-- una squadra non può giocare due eventi contemporaneamente per seconda squadra --
CREATE OR REPLACE FUNCTION check_team2_for_matches() RETURNS trigger AS
$check_team2_for_matches$
BEGIN 
	IF NEW.nomeSquadra2 NOT IN (SELECT nomeSquadra1 FROM EsitoSquadre WHERE nomeSquadra1 = NEW.nomeSquadra2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.nomeSquadra2 NOT IN (SELECT nomeSquadra2 FROM EsitoSquadre WHERE nomeSquadra2 = NEW.nomeSquadra2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'La squadra % in data % partecipa già ad un altro evento!',NEW.nomeSquadra2,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv); 
   END IF;
END;																						   
$check_team2_for_matches$
LANGUAGE plpgsql;							  

										  
 -- una giocatore non può giocare due eventi contemporaneamente per primo giocatore --			 
CREATE OR REPLACE FUNCTION check_player1_for_matches() RETURNS trigger AS
$check_player1_for_matches$
BEGIN 
	IF NEW.giocatore1 NOT IN (SELECT giocatore1 FROM EsitoSingolo WHERE giocatore1 = NEW.giocatore1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.giocatore1 NOT IN (SELECT giocatore2 FROM EsitoSingolo WHERE giocatore2 = NEW.giocatore1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'il giocatore % in data % partecipa già ad un altro evento!',NEW.giocatore1,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv);
   END IF;
END;																						  
$check_player1_for_matches$
LANGUAGE plpgsql;


 -- una giocatore non può giocare due eventi contemporaneamente per secondo giocatore --			 
CREATE OR REPLACE FUNCTION check_player2_for_matches() RETURNS trigger AS
$check_player2_for_matches$
BEGIN 
	IF NEW.giocatore2 NOT IN (SELECT giocatore1 FROM EsitoSingolo WHERE giocatore1 = NEW.giocatore2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.giocatore2 NOT IN (SELECT giocatore2 FROM EsitoSingolo WHERE giocatore2 = NEW.giocatore2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'il giocatore % in data % partecipa già ad un altro evento!',NEW.giocatore2,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv); 
   END IF;
END;																						   
$check_player2_for_matches$
LANGUAGE plpgsql;


--la somma dei punti dei giocatori di una squadra non deve superare i punti fatti dalla stessa								  
CREATE OR REPLACE FUNCTION check_sum_of_points() RETURNS trigger AS
$check_sum_of_points$

DECLARE 
	TeamPoints NUMERIC(2);
	Team VARCHAR(25);
BEGIN 
	IF(SELECT COUNT(nomeSquadra1) FROM EsitoSquadre WHERE  idEv = NEW.idEvento AND 
					nomeSquadra1 IN (SELECT squadra FROM Candidatura  WHERE candidato = NEW.username AND stato = 'accettata' AND 
						categoria = categoriasq1)) <> 0
	 THEN TeamPoints = (SELECT puntisq1 FROM EsitoSquadre WHERE idEv = NEW.idEvento);
	 ELSE TeamPoints = (SELECT puntisq2 FROM EsitoSquadre WHERE idEv = NEW.idEvento);
	 END IF;
	
	if(select count(nome) FROM squadra WHERE nome IN(SELECT nomeSquadra1 FROM EsitoSquadre WHERE idEv = NEW.idEvento
		AND nome  IN (SELECT squadra FROM Candidatura  WHERE candidato = NEW.username AND stato = 'accettata' AND 
		categoria = categoriasq1))) > 0
	then Team = (SELECT nomeSquadra1 FROM EsitoSquadre WHERE idEv = NEW.idEvento);
	ELSE  Team = (SELECT nomeSquadra2 FROM EsitoSquadre WHERE idEv = NEW.idEvento);
	END IF;
	
	
	IF (SELECT SUM(punti) FROM UtenteFaPunti WHERE idEvento = NEW.idEvento AND username IN (SELECT candidato FROM Candidatura WHERE 
		stato = 'accettata' AND categoria IN(SELECT categoriasq1 FROM EsitoSquadre WHERE idEv = NEW.idEvento) AND 
													squadra = Team))+ NEW.punti > TeamPoints
													
	THEN RAISE EXCEPTION 'La somma dei punti dei giocatori supera i punti fatti dalla squadra % all''evento % somma = %  puntisquadra = % ',New.idEvento,Team;
	ELSE RETURN NEW;
	
	END IF;
END 
$check_sum_of_points$
LANGUAGE plpgsql;										  
										  
										  
--non si possono iscrivere più giocatori all'evento se il numero max di gioc per quell'evento è stato raggiunto
CREATE OR REPLACE FUNCTION check_subscription_max_players() RETURNS trigger AS
$check_subscription_max_players$
BEGIN
	IF ((SELECT COUNT(studente) FROM Iscrizione WHERE evento = NEW.evento) <
		(SELECT DISTINCT (numGiocatori) FROM Categoria C JOIN Evento E ON C.nome = E.categoria	WHERE E.id = NEW.evento))
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'Numero massimo di giocatori iscritti all''evento % raggiunto, impossibile inserirne altri',NEW.evento;
	END IF;
END;
$check_subscription_max_players$
LANGUAGE plpgsql;							    
								    
										  
										  

--solo un utente premium può creare una squadra
CREATE TRIGGER check_premium_for_teams
BEFORE INSERT OR UPDATE ON Squadra
FOR EACH ROW
EXECUTE PROCEDURE check_premium_for_teams();

--il numero minimo massimo di giocatori di una squadra non può essere minore del numero minimo previsto per quella categoria
CREATE TRIGGER check_players_number
BEFORE INSERT OR UPDATE ON Squadra
FOR EACH ROW
EXECUTE PROCEDURE check_players_number();

--ci si può valutare solamente se l'evento si è chiuso
CREATE TRIGGER check_state_event
BEFORE INSERT OR UPDATE ON ValutazioneUtenti
FOR EACH ROW
EXECUTE PROCEDURE check_state_event();

--due utenti devono aver partecipato al medesimo evento per potersi valutare
CREATE TRIGGER check_rating_for_player
BEFORE INSERT OR UPDATE ON ValutazioneUtenti
FOR EACH ROW
EXECUTE PROCEDURE check_rating_for_player();

-- un impianto non puo ospitare due eventi contemporaneamente --
CREATE TRIGGER check_stadium_for_event
BEFORE INSERT OR UPDATE ON Evento
FOR EACH ROW
EXECUTE PROCEDURE check_stadium_for_evento();

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

-- non si puo aggiungere un esito di un evento aperto
CREATE  TRIGGER check_if_accessible_event_for_player
BEFORE INSERT OR UPDATE ON EsitoSingolo
FOR EACH ROW
EXECUTE PROCEDURE check_if_accessible_event();

-- non si puo aggiungere un esito di un evento aperto
CREATE  TRIGGER check_if_accessible_event_for_player
BEFORE INSERT OR UPDATE ON EsitoSquadre
FOR EACH ROW
EXECUTE PROCEDURE check_if_accessible_event();

-- una squadra non può giocare due eventi contemporaneamente per prima squadra --
CREATE TRIGGER check_team2_for_matches
BEFORE INSERT OR UPDATE ON EsitoSquadre
FOR EACH ROW
EXECUTE PROCEDURE check_team2_for_matches();
				 
 -- una squadra non può giocare due eventi contemporaneamente per seconda squadra --
CREATE TRIGGER check_team1_for_matches
BEFORE INSERT OR UPDATE ON EsitoSquadre
FOR EACH ROW
EXECUTE PROCEDURE check_team1_for_matches();
				 
 -- una giocatore non può giocare due eventi contemporaneamente per primo giocatore --			 
CREATE TRIGGER check_player2_for_matches
BEFORE INSERT OR UPDATE ON EsitoSingolo
FOR EACH ROW
EXECUTE PROCEDURE check_player2_for_matches();
				 
 -- una giocatore non può giocare due eventi contemporaneamente per secondo giocatore --			 
CREATE TRIGGER check_player1_for_matches
BEFORE INSERT OR UPDATE ON EsitoSingolo
FOR EACH ROW
EXECUTE PROCEDURE check_player1_for_matches();
								    
--la somma dei punti dei giocatori di una squadra non deve superare i punti fatti dalla stessa								  						    
CREATE TRIGGER check_sum_of_points
BEFORE INSERT OR UPDATE ON UtenteFaPunti
FOR EACH ROW
EXECUTE PROCEDURE check_sum_of_points(); 
					
-- non si possono isrivere più giocatori a un evento dei giocatori possibili per quell'evento --			 
CREATE TRIGGER check_subscription_max_players
BEFORE INSERT OR UPDATE ON Iscrizione
FOR EACH ROW
EXECUTE PROCEDURE check_subscription_max_players();
