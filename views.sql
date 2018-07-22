	/* AUXILIARY VIEWS */
	
CREATE OR REPLACE VIEW Arbitro(Evento,Arbitro) AS
select evento, studente From Iscrizione  WHERE tipo = 'arbitro' AND stato = 'confermato'
	group by evento, studente  order by evento asc;

CREATE OR REPLACE VIEW ResultMerge(evento,puntiCasa,puntiOspite) AS 
(select esitoSquadre.idEv,esitoSquadre.puntiSq1,esitoSquadre.puntiSq2 FROM esitoSquadre
order by idEv asc)
union
(select esitoSingolo.idEv,esitoSingolo.punteggioGiocatore1,esitoSingolo.punteggiogiocatore2 FROM esitoSingolo
order by idEv asc);


CREATE OR REPLACE VIEW Partecipanti(evento, partecipanti) as
select iscrizione.evento, string_agg(studente,', ') FROM Iscrizione WHERE stato = 'confermato' AND tipo='giocatore' GROUP BY
iscrizione.evento
order by iscrizione.evento asc;




create or replace view durataPerMese(impianto,mese,durata,categoria) as
select evento.impianto,EXTRACT(MONTH FROM evento.data),sum(evento.durata),evento.categoria From Evento WHERE stato = 'chiuso'
group by impianto,EXTRACT(MONTH FROM evento.data),categoria order by impianto,EXTRACT(MONTH FROM evento.data)asc;


create or replace view MonthCounter(impianto,mese,numEventi,NumTornei) as
select evento.impianto, EXTRACT(MONTH FROM evento.data),count(distinct eventoInTorneo.idEv),count(distinct eventoINTorneo.idT)
FROM Evento JOIN eventoINTorneo ON eventoInTorneo.idEv = evento.id WHERE evento.stato ='chiuso' 
group by  evento.impianto, EXTRACT(MONTH FROM evento.data) order by  evento.impianto,
EXTRACT(MONTH FROM evento.data) asc;


create or replace view numberOfPlayers(impianto,mese,numGiocatori,numCorsi) as
select evento.impianto,EXTRACT(MONTH FROM evento.data),count(DISTINCT iscrizione.studente),
count(DISTINCT utente.corsoDiStudio)FROM Evento JOIN Iscrizione ON iscrizione.evento = evento.id
JOIN Utente ON utente.username = iscrizione.studente WHERE iscrizione.stato = 'confermato' AND
iscrizione.tipo = 'giocatore' AND evento.stato = 'chiuso'
GROUP BY evento.impianto,EXTRACT(MONTH FROM evento.data) ORDER BY
evento.impianto,EXTRACT(MONTH FROM evento.data);






   /* MAIN VIEWS */
CREATE OR REPLACE VIEW ProgrammaTorneo (Torneo,Evento,Fase,PuntiCasa,PuntiOspite,Data,Tipologia,Impianto,Arbitro,Partecipanti) as
Select eventointorneo.idT,eventointorneo.idEv,eventointorneo.fase,ResultMerge.punticasa,
ResultMerge.puntiospite,evento.data,evento.tipo,evento.impianto,arbitro.arbitro,partecipanti.partecipanti FROM
eventoInTorneo JOIN evento ON evento.id = eventoInTorneo.idEv JOIN ResultMerge ON ResultMerge.evento = eventoInTorneo.idEv
JOIN arbitro on arbitro.evento = evento.id JOIN Partecipanti ON partecipanti.evento = evento.id GROUP BY eventointorneo.idT,
eventointorneo.idEv,eventointorneo.fase,ResultMerge.punticasa,
ResultMerge.puntiospite,evento.data,evento.tipo,evento.impianto,arbitro.arbitro,
partecipanti.partecipanti
order by eventointorneo.idT asc;

/* select * From ProgrammaTorneo; */


CREATE OR REPLACE VIEW Programma
(NomeImpianto,Mese,Categoria,NumeroTornei,NumeroEventi,NumeroPartecipanti,NumCorsiDiStudio,TempoUtilizzo, PercentualeUtilizzo) AS
SELECT durataPerMese.impianto,durataPerMese.mese,durataPerMese.categoria,COUNT(DISTINCT EventoInTorneo.idT),
	COUNT(DISTINCT evento.id),COUNT(DISTINCT iscrizione.studente),COUNT(DISTINCT utente.corsoDiStudio),
	 durataPerMese.durata, (durataPerMese.durata/(1400*(CURRENT_DATE - '2018/01/01'))*100) FROM durataPerMese JOIN evento ON evento.impianto = durataPerMese.impianto
	 JOIN EventoInTorneo ON evento.id = EventoInTorneo.idEv JOIN Iscrizione ON  evento.id = Iscrizione.evento 
	 JOIN Utente ON utente.username = iscrizione.studente
	 WHERE Iscrizione.stato = 'confermato' AND evento.stato = 'chiuso'
	 group by durataPerMese.impianto,durataPerMese.mese,durataPerMese.categoria,durataPerMese.durata, durataPerMese.durata/(1400*(CURRENT_DATE - '2018/01/01'))*100 ORDER BY 
durataPerMese.impianto,durataPerMese.mese,durataPerMese.categoria asc;

/*select * From Programma; */



