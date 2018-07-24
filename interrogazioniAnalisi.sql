/* Interrogazioni di analisi */
set search_path to 'ProgettoBD';

--torneo/i con piu affluenza e con piu attivita proposte
SELECT I.torneo FROM IscrittoATorneo I
GROUP BY torneo
HAVING COUNT(studente) >= ALL (SELECT COUNT(studente) FROM IscrittoATorneo
				GROUP BY torneo)
INTERSECT

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
quella categoria con età < 20 anni 
*/

SELECT categoria, CorsoDiStudio, COUNT(DISTINCT username) FROM Utente 
JOIN Iscrizione ON studente = username
JOIN Evento ON id = evento
AND Iscrizione.stato = 'confermato'
WHERE  (CURRENT_DATE - annon)/365 <= 20
GROUP BY categoria, CorsoDiStudio;
