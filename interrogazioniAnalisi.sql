/* Interrogazioni di analisi */
set search_path to 'ProgettoBD';

/*
a. determinare il torneo di più successo (in termini di partecipazione) e quella più “ricca”
in termini di diverse attività proposte.
*/
SELECT I.torneo FROM IscrittoATorneo I
GROUP BY torneo
HAVING COUNT(studente) >= ALL (SELECT COUNT(studente) FROM IscrittoATorneo
				GROUP BY torneo)
INTERSECT
-- ? attività proposte ???? --
SELECT idT FROM EventoInTorneo
GROUP BY idT
HAVING COUNT(idEv) >= ALL (SELECT COUNT(idEv) FROM EventoInTorneo GROUP BY idT);


/*
b. determinare le categorie in cui sono attivi tutti i corsi di laurea.
*/

SELECT categoria FROM Evento
JOIN Iscrizione ON evento = id
JOIN Utente ON username = studente
GROUP BY categoria, studente
HAVING COUNT(DISTINCT CorsoDiStudio) > (SELECT COUNT(DISTINCT CorsoDiStudio) FROM Utente);




/* CORSI DI STUDIO PER CATEGORIA */
SELECT categoria,  COUNT(DISTINCT CorsoDiStudio)  FROM Evento
JOIN Iscrizione ON evento = id
JOIN Utente ON username = studente
GROUP BY categoria; 

/* controllo corsi di studio totali */
SELECT COUNT(DISTINCT CorsoDiStudio) FROM Utente;
SELECT DISTINCT CorsoDiStudio FROM Utente; 

/*tornei e numero eventi in torneo*/
SELECT idT, COUNT(idEv) FROM EventoInTorneo
GROUP BY idT;


/* categoria eventi con più eventi disputati */
SELECT categoria, COUNT(id) FROM Evento 
GROUP BY categoria
HAVING COUNT(id) >= ALL (SELECT COUNT(E.id) FROM Evento E  WHERE categoria = E.categoria
GROUP BY E.categoria);


/* c. determinare per ogni categoria e corso di studi la frazione di partecipanti a eventi di
quella categoria con età < 20 anni sul totale dei partecipanti provenienti da quel
corso di studi.
*/

SELECT categoria, CorsoDiStudio, COUNT(studente) AS partecipanti_ventenni FROM Iscrizione
JOIN Evento ON id = evento
JOIN Utente U ON studente = username
GROUP BY categoria, CorsoDiStudio
HAVING COUNT(studente) = (SELECT COUNT(username) FROM Utente 
				WHERE  (CURRENT_DATE - annon)/365 <= 20
				AND U.CorsoDIStudio = CorsoDiStudio
				GROUP BY CorsoDiStudio);


SELECT COUNT(username), CorsoDiStudio FROM Utente 
WHERE  (CURRENT_DATE - annon)/365 <= 20
GROUP BY CorsoDiStudio;