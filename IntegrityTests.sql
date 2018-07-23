

--verrà attivato un trigger, perchè in quello stesso momento terminus ospita già un altro evento 
--update  Evento SET impianto = 'Terminus' WHERE id = 15689;

--verrà attivato un trigger poichè la somma dei goal dei giocatori di una squadra deve essere uguale ai punti
--fatti dalla stessa!
--update  UtenteFaPunti SET punti = 3 WHERE idEvento = 15691 and username = 'MercyPrevailsWrath'; 

--viene attivato un trigger. ad una partita possono giocare alpiù due squadre !
--insert into SquadraPartecipaEv values('Virtus Piscatella','Pallavolo',16691); 

-- questa coppia di inserimenti genererà un eccezzione di un trigger poichè una squadra non può
--giocare contemporaneamente due eventi!
--insert into evento values (111,'09/01/2018','chiuso',90,'Castel Granito','Calcio','a squadre','LaMiaLucille'); 
--insert into squadraPartecipaEv values ('The North Remembers','Calcio',111);

--ERROR: update or delete on table "evento" violates
--foreign key constraint "squadrapartecipaev_idev_fkey" on table "squadrapartecipaev"
--delete from evento where  impianto = 'La Terra di mezzo';

--ERROR: update or delete on table "torneo" violates foreign key constraint 
--"eventointorneo_idt_fkey" on table "eventointorneo" 
--DETAIL: Key (id)=(1) is still referenced from table "eventointorneo".
--delete from Torneo  where id = 00001;
