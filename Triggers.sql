set search_path to 'ProgettoBD';


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
	IF (NEW.usernameValutatore IN (SELECT studente FROM Iscrizione
					WHERE evento = NEW.idEv
					AND stato = 'confermato')
		AND NEW.usernameValutato IN (SELECT studente FROM Iscrizione
					WHERE evento = NEW.idEv
					AND stato = 'confermato'))
	THEN return NEW;
	ELSE RAISE EXCEPTION 'il giocatore % e il giocatore % devono aver partecipato all''evento % per valutare o essere valutati', NEW.usernameValutatore, NEW.usernameValutato, NEW.idEv;
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
	IF NEW.data  <=   (SELECT data FROM Evento WHERE id = NEW.evento)
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


 -- non si puo mettere l'esito di un evento se esiste già un esito di qual giocatore per la stessa data			 
CREATE OR REPLACE FUNCTION check_team1_for_matches() RETURNS trigger AS
$check_team1_for_matches$
BEGIN 
	IF NEW.nomeSquadra1 NOT IN (SELECT nomeSquadra1 FROM EsitoSquadre WHERE nomeSquadra1 = NEW.nomeSquadra1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.nomeSquadra1 NOT IN (SELECT nomeSquadra2 FROM EsitoSquadre WHERE nomeSquadra2 = NEW.nomeSquadra1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'La squadra % in data % ha partecipato ad un altro evento!',NEW.nomeSquadra1,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv);
   END IF;
END;																						  
$check_team1_for_matches$
LANGUAGE plpgsql;


 -- non si puo mettere l'esito di un evento se esiste già un esito di qual giocatore per la stessa data			 
CREATE OR REPLACE FUNCTION check_team2_for_matches() RETURNS trigger AS
$check_team2_for_matches$
BEGIN 
	IF NEW.nomeSquadra2 NOT IN (SELECT nomeSquadra1 FROM EsitoSquadre WHERE nomeSquadra1 = NEW.nomeSquadra2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.nomeSquadra2 NOT IN (SELECT nomeSquadra2 FROM EsitoSquadre WHERE nomeSquadra2 = NEW.nomeSquadra2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'La squadra % in data % ha partecipato ad un altro evento!',NEW.nomeSquadra2,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv); 
   END IF;
END;																						   
$check_team2_for_matches$
LANGUAGE plpgsql;							  

								
 -- non si puo mettere l'esito di un evento se esiste già un esito di qual giocatore per la stessa data			 		  
CREATE OR REPLACE FUNCTION check_player1_for_matches() RETURNS trigger AS
$check_player1_for_matches$
BEGIN 
	IF NEW.giocatore1 NOT IN (SELECT giocatore1 FROM EsitoSingolo WHERE giocatore1 = NEW.giocatore1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.giocatore1 NOT IN (SELECT giocatore2 FROM EsitoSingolo WHERE giocatore2 = NEW.giocatore1 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'il giocatore % in data % ha partecipato ad un altro evento!',NEW.giocatore1,(SELECT data FROM Evento 
   																								WHERE id = NEW.idEv);
   END IF;
END;																						  
$check_player1_for_matches$
LANGUAGE plpgsql;


 -- non si puo mettere l'esito di un evento se esiste già un esito di qual giocatore per la stessa data			 
CREATE OR REPLACE FUNCTION check_player2_for_matches() RETURNS trigger AS
$check_player2_for_matches$
BEGIN 
	IF NEW.giocatore2 NOT IN (SELECT giocatore1 FROM EsitoSingolo WHERE giocatore1 = NEW.giocatore2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
	   AND NEW.giocatore2 NOT IN (SELECT giocatore2 FROM EsitoSingolo WHERE giocatore2 = NEW.giocatore2 AND
		idEv <> NEW.idEv AND idEv IN (SELECT id FROM Evento WHERE data = (SELECT data FROM Evento WHERE id = NEW.idEv)))
   THEN RETURN NEW;
   ELSE  RAISE EXCEPTION 'il giocatore % in data % ha partecipato  ad un altro evento!',NEW.giocatore2,(SELECT data FROM Evento 
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
													
	THEN RAISE EXCEPTION 'La somma dei punti dei giocatori supera i punti fatti dalla squadra % all''evento %',New.idEvento,Team;
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
								    
										  
--trigger che riempe in automatico le iscrizioni ad un evento con i membri di una squadra che partecipa!
CREATE OR REPLACE FUNCTION player_subscription_autofiller() RETURNS trigger AS
$player_subscription_autofiller$
DECLARE 
 dataIscrizione date;
 temp varchar(25);
BEGIN
	dataIscrizione = (SELECT data from  Evento WHERE id = NEW.evento);
	
	for temp in SELECT candidato FROM Candidatura WHERE Squadra = NEW.nomeSquadra AND categoria = NEW.nomeC AND stato = 'accettata'
	loop
		INSERT INTO Iscrizione VALUES (dataIscrizione,'confermato',temp ,NEW.evento);
	END LOOP;

  RETURN NEW;
END;
$player_subscription_autofiller$
LANGUAGE plpgsql;



--non si può inserire l'esito di un evento a cui i giocatori non sono iscritti
CREATE OR REPLACE FUNCTION check_subscription_for_match_result() RETURNS trigger AS
$check_subscription_for_match_result$
BEGIN
	IF (NEW.giocatore1 IN (SELECT studente FROM Iscrizione
			WHERE studente = NEW.giocatore1 AND evento = NEW.idEV)
		AND NEW.giocatore2 IN (SELECT studente FROM Iscrizione 
			WHERE studente = NEW.giocatore2 AND evento = NEW.idEv))
	THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'Non è possibile inserire l''esito dell''evento % a cui i giocatori % e % non sono iscritti',NEW.idEv, NEW.giocatore1,NEW.giocatore2;
	END IF;
END;
$check_subscription_for_match_result$
LANGUAGE plpgsql;


--non ci si può iscrivere a un evento che fa parte di un torneo se non si è iscritti al torneo in cui è disputato l'evento
CREATE OR REPLACE FUNCTION check_subscription_for_match_in_tournament() RETURNS trigger AS
$check_subscription_for_match_in_tournament$
BEGIN

	IF NEW.evento NOT IN (SELECT idEv FROM EventoInTorneo)
		OR NEW.evento IN (SELECT idEv FROM EventoInTorneo
				JOIN IscrittoATorneo ON torneo = idT
				AND idEv = NEW.evento 
				AND studente = NEW.studente)
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION '% deve essere iscritto al torneo per partecipare all''evento %',NEW.studente,NEW.evento;
	END IF;
END;
$check_subscription_for_match_in_tournament$
LANGUAGE plpgsql; 


--un utente non può fare punti in un evento a squadre se non fa parte di nessuna delle due squadre partecipanti
CREATE OR REPLACE FUNCTION check_if_player_belongs_team() RETURNS trigger AS
$check_if_player_belongs_team$
BEGIN
	IF NEW.username  NOT IN (SELECT candidato FROM Candidatura WHERE  candidato = NEW.username AND  stato = 'accettata' AND squadra IN 
		(SELECT squadra FROM SquadraPartecipaEv WHERE idEv = NEW.idEvento))
	THEN RAISE EXCEPTION '% non può aver fatto in quanto non fa parte di nessuna dell due squadre dell''evento %',NEW.username,NEW.idEvento;
	ELSE RETURN NEW;
	END IF;
END;
$check_if_player_belongs_team$
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

-- solo un utente premium può creare un evento 
CREATE OR REPLACE FUNCTION check_premium_for_events() RETURNS trigger AS
$check_premium_for_events$
BEGIN
	IF NEW.creatore NOT IN (SELECT username  FROM Utente WHERE tipo = 'standard')
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'L''utente % non è premium, non può creare l''evento!',NEW.creatore;
	END IF;
END;
$check_premium_for_events$
LANGUAGE plpgsql;

-- un utente può far parte di una sola squadra per categoria
CREATE OR REPLACE FUNCTION check_player_belongs_one_team_only() RETURNS trigger AS
$check_player_belongs_one_team_only$
BEGIN
	IF NEW.candidato IN (SELECT candidato FROM Candidatura WHERE categoria = NEW.categoria AND stato = 'accettata')
	THEN RAISE EXCEPTION '% fa già parte di una squadra per questa categoria: %',new.candidato,NEW.categoria;
	ELSE RETURN NEW;
	END IF;
END;
$check_player_belongs_one_team_only$
LANGUAGE plpgsql;

--un utente la cui candidatura per una certa squadra di una categoria è stata rifiutata non puo presentarne un'altra per la stessa squadra
CREATE OR REPLACE FUNCTION check_player_not_spam_nominations() RETURNS trigger AS
$check_player_not_spam_nominations$
BEGIN
	IF NEW.candidato IN (SELECT candidato FROM Candidatura WHERE categoria = NEW.categoria AND squadra = NEW.squadra AND stato = 'rifiutata')
	THEN RAISE EXCEPTION '% ha già presentato una candidatura per % della categoria % ma è stata rifiutata',NEW.candidato,NEW.squadra,NEW.categoria;
	ELSE RETURN NEW;
	END IF;
END;
$check_player_not_spam_nominations$
LANGUAGE plpgsql;


--una squadra non può partecipare a due eventi contemporaneamente
CREATE OR REPLACE FUNCTION check_team_for_match_partecipations() RETURNS trigger AS
$check_team_for_match_partecipations$
BEGIN
	IF NEW.nomeSquadra NOT IN (SELECT nomeSquadra  FROM SquadraPartecipaEv  
							   WHERE nomeSquadra = NEW.nomeSquadra AND idEv <> NEW.idEv AND idEv 
							   IN(SELECT id FROM Evento  WHERE data = 
								  (SELECT data from Evento WHERE id = NEW.idEv )))
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'la squadra % in data % partecipa già ad un altro evento!',NEW.nomeSquadra,(SELECT data FROM Evento 
																							   WHERE id = NEW.idEv);
	END IF;
END;
$check_team_for_match_partecipations$
LANGUAGE plpgsql;
								   

 			 /* da controllare, dà errore con autofiller 

--non si può inserire l'esito di un evento a squadre a cui le squadre non sono iscritte
CREATE OR REPLACE FUNCTION check_subscription_teams_for_match_result() RETURNS trigger AS
$check_subscription_teams_for_match_result$
BEGIN
	IF (NEW.nomeSquadra1 IN (SELECT nomeSquadra FROM SquadraPartecipaEv 
				WHERE nomeSquadra = NEW.nomeSquadra1 
				AND nomeC = NEW.categoriasq1
				AND idEv = NEW.idEv)
		AND NEW.nomeSquadra2 IN (SELECT nomeSquadra FROM SquadraPartecipaEv 
				WHERE nomeSquadra = NEW.nomeSquadra2 
				AND nomeC = NEW.categoriasq2
				AND idEv = NEW.idEv))
		THEN RETURN NEW;
	ELSE  RAISE EXCEPTION 'Non è possibile inserire l''esito dell''evento a squadre % se le squadre % e % non vi sono iscritte',NEW.idEv, NEW.nomeSquadra1,NEW.nomeSquadra2;
	END IF;
END;
$check_subscription_teams_for_match_result$
LANGUAGE plpgsql;

						*/

---------------------------------TRIGGER----------------------------------------------------------------

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


-- non si possono isrivere più giocatori a un evento dei giocatori possibili per quell'evento --			 
CREATE TRIGGER  player_subscription_autofiller
BEFORE INSERT ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE  player_subscription_autofiller();

--non si può inserire l'esito di un evento a cui i giocatori non sono iscritti
CREATE TRIGGER check_subscription_for_match_result
BEFORE INSERT OR UPDATE ON EsitoSingolo
FOR EACH ROW
EXECUTE PROCEDURE check_subscription_for_match_result();


--non ci si può iscrivere a un evento che fa parte di un torneo se non si è iscritti al torneo in cui è disputato l'evento
CREATE TRIGGER check_subscription_for_match_in_tournament
BEFORE INSERT OR UPDATE ON Iscrizione
FOR EACH ROW
EXECUTE PROCEDURE check_subscription_for_match_in_tournament();

--un utente non può fare punti in un evento a squadre se non fa parte di nessuna delle due squadre partecipanti
CREATE TRIGGER check_if_player_belongs_team
BEFORE INSERT OR UPDATE ON UtenteFaPunti
FOR EACH ROW
EXECUTE PROCEDURE check_if_player_belongs_team();

-- ad un evento a squadre possono giocare solo due squadre 
CREATE TRIGGER check_partecipants_number_for_team
BEFORE INSERT OR UPDATE ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE check_partecipants_number_for_team(); 

-- solo un utente premium può creare un evento 
CREATE TRIGGER check_premium_for_events
BEFORE INSERT OR UPDATE ON Evento
FOR EACH ROW
EXECUTE PROCEDURE check_premium_for_events(); 

-- un utente può far parte di una sola squadra per categoria
CREATE TRIGGER check_player_belongs_one_team_only
BEFORE INSERT OR UPDATE ON Candidatura
FOR EACH ROW
EXECUTE PROCEDURE check_player_belongs_one_team_only(); 

--un utente la cui candidatura per una certa squadra di una categoria è stata rifiutata non puo presentarne un'altra per la stessa squadra
CREATE TRIGGER check_player_not_spam_nominations
BEFORE INSERT OR UPDATE ON Candidatura
FOR EACH ROW
EXECUTE PROCEDURE check_player_not_spam_nominations(); 

--una squadra non può partecipare a due eventi contemporaneamente
CREATE TRIGGER check_team_for_match_partecipations
BEFORE INSERT OR UPDATE ON SquadraPartecipaEv
FOR EACH ROW
EXECUTE PROCEDURE check_team_for_match_partecipations(); 

			 /* da controllare, dà errore con autofiller 
					 
--non si può inserire l'esito di un evento a squadre a cui le squadre non sono iscritte
CREATE TRIGGER check_subscription_teams_for_match_result
BEFORE INSERT OR UPDATE ON EsitoSquadre
FOR EACH ROW
EXECUTE PROCEDURE check_subscription_teams_for_match_result(); 

					 */






