/*INTERROGAZIONI SEMPLICI*/
set search_path to 'ProgettoBD';

/* AAA NON FUNZIONA
a. determinare le categorie per cui ci sono eventi non ancora chiusi in programma in un
certo impianto insieme al numero di posti giocatori ancora disponibili per quell’evento
NOTE: + 1 è perchè anche l'arbitro è iscritto all'evento */
SELECT Evento.categoria, id, studente, Iscrizione.tipo, Categoria.numgiocatori - COUNT(Iscrizione.studente) AS posti_ancora_disponibili, Evento.impianto FROM Evento 
JOIN Categoria ON categoria = nome
LEFT OUTER JOIN Iscrizione ON id = evento
WHERE Evento.stato = 'aperto'
AND Iscrizione.stato ='confermato'
--AND Iscrizione.studente NOT IN (SELECT studente FROM Iscrizione WHERE stato = 'rifiutato')
GROUP BY categoria, numgiocatori, studente, impianto, id, Iscrizione.tipo;

/*
b. determinare gli impianti disponibili in una certa data che siano
percentualmente meno utilizzati (vedi vista 1.)
*/

SELECT nome FROM Impianto
WHERE nome NOT IN (SELECT impianto FROM Evento WHERE Evento.data = '15/08/2018')
AND nome = (SELECT nomeimpianto FROM Programma 
			WHERE percentualeutilizzo = (SELECT MIN(percentualeutilizzo) FROM Programma))
GROUP BY nome;

/*
c. determinare per i giocatori candidati a un certo evento quelli che hanno un numero di
partite disputate nella categoria dell’evento più alta.
*/

/*vista che conta partite disputate dallo studente per ogni categoria*/
CREATE OR REPLACE VIEW partitedisputate_categoria (giocatore, numero_partite, categoria) AS
SELECT Iscrizione.studente, COUNT(Iscrizione.evento), Evento.categoria FROM Iscrizione
JOIN Evento ON Iscrizione.evento = Evento.id
WHERE Iscrizione.stato = 'confermato'
AND Evento.stato = 'chiuso' 
AND Iscrizione.tipo = 'giocatore'
AND Evento.data < CURRENT_DATE
GROUP BY Iscrizione.studente, Evento.categoria;

/* interrogazione */
SELECT I.evento, I.studente, P.categoria, P.numero_partite FROM Evento E
JOIN Iscrizione I ON I.evento = E.id 
JOIN partitedisputate_categoria P ON P.categoria = E.categoria
WHERE I.stato = 'confermato'
AND I.tipo = 'giocatore'
AND I.evento = 15690
AND P.numero_partite = (SELECT MAX(numero_partite) FROM partitedisputate_categoria WHERE categoria = E.categoria AND studente = I.studente)
GROUP BY I.studente, I.evento, P.categoria, P.numero_partite;

/*
d. Determinare gli utenti che si sono candidati come giocatori e non sono mai stati
accettati e quelli che sono stati accettati tutte le volte che si sono candidati.
*/

/* sempre accettati */
SELECT DISTINCT studente AS studenti_sempre_accettati FROM Iscrizione
WHERE tipo = 'giocatore'
AND studente NOT IN (SELECT studente FROM Iscrizione WHERE stato = 'rifiutato')
ORDER BY studente ASC;

/* mai accettati */
SELECT DISTINCT studente AS studenti_mai_accettati FROM Iscrizione
WHERE tipo = 'giocatore'
AND studente NOT IN (SELECT studente FROM Iscrizione WHERE stato = 'confermato');


/* e. Studenti che sono utenti ma non si sono iscritti a un evento come giocatore 
nella categoria di eventi più disputati*/
SELECT DISTINCT studente, categoria FROM Iscrizione
JOIN Evento ON id = evento 
WHERE Iscrizione.tipo = 'giocatore'
EXCEPT
SELECT studente, categoria FROM Iscrizione
JOIN Evento ON id = evento
WHERE categoria IN (SELECT categoria FROM Evento 
GROUP BY categoria
HAVING COUNT(id) >= ALL (SELECT COUNT(E.id) FROM Evento E  WHERE categoria = E.categoria
GROUP BY E.categoria))
GROUP BY studente, categoria;


/* f.studenti con più iscrizioni accettate negli eventi per la tipologia di evento più disputata */
SELECT studente, COUNT(evento), categoria FROM Iscrizione
JOIN Evento E ON id = evento
WHERE Iscrizione.stato = 'confermato'
GROUP BY studente, categoria
HAVING COUNT(evento) >= ALL (SELECT COUNT(I.evento) FROM Iscrizione I JOIN Evento ON id = evento 
				WHERE I.stato = 'confermato' 
				AND studente = I.studente 
				GROUP BY I.studente, categoria)
EXCEPT
SELECT studente, COUNT(evento), categoria FROM Iscrizione
JOIN Evento E ON id = evento
WHERE Iscrizione.stato = 'confermato'
AND categoria NOT IN (SELECT categoria FROM Evento
			GROUP BY categoria
			HAVING COUNT(id) >= ALL (SELECT COUNT(E.id) FROM Evento E  WHERE categoria = E.categoria
			GROUP BY E.categoria))
GROUP BY studente, categoria;