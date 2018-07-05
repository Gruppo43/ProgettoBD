
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

CREATE OR REPLACE FUNCTION check_premium_for_application() RETURNS trigger AS
$check_premium_for_application$
BEGIN
	IF NEW.Supervisore NOT IN (SELECT Username AS Supervisore FROM Utente WHERE Tipo = 'Standard')
		THEN RETURN NEW;
	ELSE RAISE EXCEPTION 'Solo un utente premium può accettare le candidature!';
	END IF;
END;
$check_premium_for_application$
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

CREATE TRIGGER check_premium_for_application
BEFORE INSERT OR UPDATE ON Candidatura
FOR EACH ROW
EXECUTE PROCEDURE check_premium_for_application();
