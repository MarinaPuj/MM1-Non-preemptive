# MM1-Non-preemptive

Cua FIFO M/M/1 amb prioritat non-preemptive (no s'interrompen serveis). 

Hi ha un servidor i fa dos tasques: Serveix als clients i fa tasques de manteniment.
Els clients tenen proritat sobre les tasques.
Quan arriba un client si s'està servint una tasca de manteniment, no s'interromp (non-preemptive).
Els temps de serveis de les dues tasques (clients i manteniment) están distribuits exponencialment.
Els clients arriben dacord una distribució de Poisson. (10 clients per hora)

Hi ha dos fitxers, la diferència està en l'arribada de les tasques no prioritaries.
### Tasca no prioritaria amb arribada exponencial
Les tasques de manteniment arriben dacord una distribució de Poisson.  (3 tasques per hora)
Quan s'ha atès a tots els clients es fan tasques de manteniment si n'hi ha.

### Tasca no prioritaria sempre disponible
Quan no hi ha clients es fan tasques de manteniment (sempre disponibles)

## Resultat

En ambdòs fitxers tindrem tres taules com a resultat
* C. Dades de les tasques dels clients.
* M. Dades tasques manteniment
* CM. Dades d'ambdós

Les taules mostraràn la següent informació:
* Número de tasca (Num_tasca)
* Número de client servit. 'Num_Client'
* Número de manteniment servit. 'Num_manteniment'
* Priority. 1 = Client, 2 = Manteniment
* Temps d'arribada. 'Arrival_Time'
* Temps en que es comença a servir. 'Time_Service_Begins'
* Temps en que s'acaba de servir. 'Time_Service_Ends'
* Temps que ha tardat en servir-se. 'Service_Time'
* Temps que ha estat a la cua. 'Wq'
* Temps total al sistema. 'W'
* Temps de descans del servidor. 'Idle_Time' (Només en el fitxer amb arribada exponencial)
