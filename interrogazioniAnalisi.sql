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

SELECT categoria, CorsoDiStudio, COUNT(studente) AS partecipanti_ventenni FROM Iscrizione
JOIN Evento ON id = evento
JOIN Utente U ON studente = username
WHERE  (CURRENT_DATE - annon)/365 <= 20
GROUP BY categoria, CorsoDiStudio
HAVING COUNT(studente) >= (SELECT COUNT(username) FROM Utente 
				WHERE  (CURRENT_DATE - annon)/365 <= 20
				AND U.CorsoDIStudio = CorsoDiStudio
				GROUP BY CorsoDiStudio)
ORDER BY categoria;


/* d. minuti totali disputati per impianto e categoria
*/
SELECT impianto, SUM(durata), categoria FROM Evento 
JOIN Iscrizione I ON evento = id 
GROUP BY categoria, impianto ORDER BY impianto;

/* e. numero partecipanti per ogni corso di studi
*/
SELECT COUNT(studente), corsodistudio FROM Iscrizione JOIN Utente ON username = studente
WHERE stato = 'confermato' GROUP BY corsodistudio;

/* f. studenti che hanno disputato partite per categoria
*/
SELECT categoria, COUNT(studente) FROM Iscrizione JOIN Evento ON evento = id
WHERE iscrizione.stato = 'confermato'
GROUP BY categoria;
