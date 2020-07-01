close all
clear all
clc
format long;

%% Simulació Cua M/M/1 FIFO. Prioritat non-preemptive
%El servidor fa dos tasques: Serveix als clients i fa tasques de manteniment.
%Els clients tenen proritat.
%Els clients i les tasques de manteniment arriben dacord una distribució de Poisson. 10 clients per hora i 3 tasques per hora
%Quan arriba un client si s'està servint una tasca de manteniment, no s'interromp.
%Els temps de serveis de les dues tasques (clients i manteniment) están distribuits exponencialment.

lambda_clients=6; %10 customers per hour = 10/60= 1/6 customers per minut 
lambda_manteniment=20; %3 tasques per hora = 3/60= 1/20 tasques per minut
mu=4; %15 services per hour = 15/60= 1/4 customers per minut
n=1000; %1000 costumers;

%Clients + manteniment
zero=(zeros(1,n))';
noms={'Num_tasca', 'Num_client','Num_manteniment','Priority','Arrival_Time','Time_Service_Begins','Time_Service_Ends','W','Wq','Service_Time','Idle_Time'};
CM=table(zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,'VariableNames',noms);

%Afegim les dades dels clients a la taula
for i=1:n
    Interarrival_time_c(i)=exprnd(lambda_clients);
    CM.Arrival_Time(i)=sum(Interarrival_time_c);
    CM.Service_Time(i)=exprnd(mu);
    CM.Priority(i)=1; %Prioritat 1
    CM.Num_client(i)=i; %Numero de client
end


%Afegim a la taula, a continuació les dades dels clients les tasques de manteniment. Ens interessen les que arribin abans de l'últim client.
tmN=0; %Temps de manteniment fins que arribi el client n.
m=n+1; 
while(tmN<CM.Arrival_Time(n)) %Mientras no ha llegado el último cliente llegaran tareas de mantenimiento
    Interarrival_time_m(m)=exprnd(lambda_manteniment);
    CM.Arrival_Time(m)=sum(Interarrival_time_m);
    CM.Service_Time(m)=exprnd(mu);
    CM.Priority(m)=2; %Prioritat 2
    CM.Num_manteniment(m)=m-n; 
    tmN=tmN+Interarrival_time_m(m); 
    m=m+1;
end

m=n+1; %Mirem la primera tasca de manteniment
i=1; %Mirem el primer client
t_final_anterior=0; 

%Mentre no s'hagi servit a tots els clients:
while (i<=n) 
%Si el client i, arriba més tard que el temps final del client i-1.
%CAS 1. 'Servidor lliure'. Tenim un interval de temps en que no sestà servint cap client i mirem si es poden fer tasques, si es pot fem tasques, fins que arribi el següent client. Quan arribi el servim.
if(CM.Arrival_Time(i)>t_final_anterior)
    t_arrival_client=CM.Arrival_Time(i); %Guardem el temps d'arribada del client
    t_arrival_mant=CM.Arrival_Time(m); %Guardem el temps d'arribada de la tasca
    ii=i; %ii: índex client i
    while(i<=ii) %Mentre no es serveixi al següent client es segueix al bucle      
        %Si el client arriba abans que arribi la tasca de manteniment. Servim al client.
        %O si l'arribada del client és més petita que el temps final de la tasca anterior servim al client (El client ha arribat mentre es feia la tasca anterior).
        if(t_arrival_client<t_arrival_mant || t_arrival_client <t_final_anterior) 
            if(t_final_anterior<CM.Arrival_Time(i)) %Si hi ha un temps lliure entre l'arribada del client i el temps de fi de l'anterior tasca (mant o client)
                CM.Time_Service_Begins(i)=CM.Arrival_Time(i); %El temps d'arribada es correspon amb el d'inici de servei
                CM.Idle_Time(i)=CM.Arrival_Time(i)-t_final_anterior; %Hi ha temps idle
            else
                CM.Time_Service_Begins(i)=t_final_anterior; %El temps d'inici de servei és el temps final de la tasca anterior
            end
            CM.Time_Service_Ends(i)=CM.Time_Service_Begins(i)+CM.Service_Time(i);
            CM.W(i)=CM.Time_Service_Ends(i)- CM.Arrival_Time(i);
            CM.Wq(i)=CM.Time_Service_Begins(i)-CM.Arrival_Time(i);
            t_final_anterior=CM.Time_Service_Ends(i); %Guardem el temps final de la tasca (client)
            i=i+1; %S'ha servit un client, sortim del bucle. I mirem el següent client
            t_arrival_client=CM.Arrival_Time(i);
     
        %Mentre no arribi el client servim a la tasca de manteniment
        else
             if(t_final_anterior<CM.Arrival_Time(m)) %Si hi ha un temps lliure entre l'arribada de la tasca de manteniment i el temps de fi de l'anterior tasca (mant o client)
                CM.Time_Service_Begins(m)=CM.Arrival_Time(m); %El temps d'arribada es correspon amb el d'inici de servei
                CM.Idle_Time(m)=CM.Arrival_Time(m)-t_final_anterior;%Hi ha tempps idle
            else
                CM.Time_Service_Begins(m)=t_final_anterior; %El temps d'inici de servei és el temps final de la tasca anterior
            end
            CM.Time_Service_Ends(m)=CM.Time_Service_Begins(m)+CM.Service_Time(m);
            CM.W(m)=CM.Time_Service_Ends(m)- CM.Arrival_Time(m);
            CM.Wq(m)=CM.Time_Service_Begins(m)-CM.Arrival_Time(m);
            t_final_anterior=CM.Time_Service_Ends(m); %Guardem el temps final de la tasca
            m=m+1; %Mirem la següent tasca. m=índex de tasca
            t_arrival_mant=CM.Arrival_Time(m);
        end
    end
else     %CAS 2: Que el cliente llegue mientras se servia al anterior cliente. Es serveix directament al client
        CM.Time_Service_Begins(i)=CM.Time_Service_Ends(i-1); %El temps d'inici de servei és el temps final del client anterior
        CM.Time_Service_Ends(i)=CM.Time_Service_Begins(i)+CM.Service_Time(i);
        CM.W(i)=CM.Time_Service_Ends(i)- CM.Arrival_Time(i);
        CM.Wq(i)=CM.Time_Service_Begins(i)-CM.Arrival_Time(i);
        t_final_anterior=CM.Time_Service_Ends(i);  %Guardem el temps final de la tasca
        i=i+1; %Mirem el següent client
end
end

%Eliminem de la taula, les tasques de manteniment que no s'han servit
toDelete = CM.Time_Service_Begins == 0;
CM(toDelete,:) = [];

%Ordenem les tasques per ordre d'inici de servei (fins ara teniem primer clients i després tasques de manteniment)
CM = sortrows(CM,'Time_Service_Begins','ascend');

%Calculem el número de cada tasca (ordre en que es fan les tasques).
for i=1:height(CM)
    CM.Num_tasca(i)=i;
end

%Ordenem les tasques per ordre d'arribada
CM = sortrows(CM,'Arrival_Time','ascend');

%Taula clients
k=find(CM.Priority==1);
C=CM(k,:);
C.Num_manteniment=[];

%Taula Manteniment
k=find(CM.Priority==2);
M=CM(k,:);
M.Num_client=[];
M.Wq=[];
M.Arrival_Time=[];

%% Mean Soujourn Time
W=sum(C.W)/n;
result(1)=W;

%% Teòric
lambda_clients=1/lambda_clients;
lambda_manteniment=1/lambda_manteniment;
mu=1/mu;
ro1=lambda_clients/mu;
ro2=lambda_manteniment/mu;
W=1/mu*(1+ro2)/(1-ro1);
result(2)=W;
disp(result);
