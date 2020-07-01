close all
clear all
clc
format long;

%% Simulació Cua M/M/1 FIFO. Prioritat non-preemptive
%El servidor fa dos tasques: Serveix als clients i fa tasques de manteniment.
%Els clients tenen proritat, quan no hi ha clients es fan tasques de manteniment (sempre disponibles). 
%Quan arriba un client no s'interromp la tasca de manteniment que s'està executant.
%Els temps de serveis de les dues tasques (clients i manteniment) están distribuits exponencialment.

lambda_clients=6;%10 customers per hour = 10/60= 1/6 customers per minut 
mu=4; %15 services per hour = 15/60= 1/4 customers per minut 
n=1000; %1000 costumers;

%Clients + manteniment
zero=(zeros(1,n))';
noms={'Num_tasca', 'Num_client','Num_manteniment','Priority','Arrival_Time','Time_Service_Begins','Time_Service_Ends','W','Wq','Service_Time'};
CM=table(zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,'VariableNames',noms);

%Calculem els temps d'arribada i de servei dels clients
for i=1:n
    Interarrival_time_c(i)=exprnd(lambda_clients);
    CM.Arrival_Time(i)=sum(Interarrival_time_c);
    CM.Service_Time(i)=exprnd(mu);
    CM.Priority(i)=1; %Prioritat 1
    CM.Num_client(i)=i; %Número de client
end

tm1=0; %Tiempo mantenimiento antes que llegue el cliente 1
m=n+1; %Afegim les tasques de manteniment a la taula després dels clients.
%Mientras no ha llegado el primer cliente haremos tareas de mantenimiento
while(tm1<CM.Arrival_Time(1)) 
    CM.Service_Time(m)=exprnd(mu); 
    CM.Priority(m)=2; %Prioritat 2
    CM.Num_manteniment(m)=m-n; %Número de la tasca de manteniment
    CM.Time_Service_Begins(m)=tm1; 
    tm1=tm1+CM.Service_Time(m);
    CM.Time_Service_Ends(m)=tm1;
    CM.W(m)=CM.Time_Service_Ends(m)-CM.Time_Service_Begins(m);
    m=m+1;
end

%Servim al primer client
CM.Time_Service_Begins(1)=tm1;
CM.Time_Service_Ends(1)=CM.Time_Service_Begins(1)+CM.Service_Time(1);
CM.W(1)=CM.Time_Service_Ends(1)-CM.Arrival_Time(1);
CM.Wq(1)=CM.Time_Service_Begins(1)-CM.Arrival_Time(1);

%Iterem fins haver servit a tots els clients
for i=2:n
    %CAS 1: Que el client arribi mentres es servia a l'anterior client. El seu temps d'arribada és més petit que el temps de fi de l'anterior
    if(CM.Time_Service_Ends(i-1)>CM.Arrival_Time(i)) 
        CM.Time_Service_Begins(i)=CM.Time_Service_Ends(i-1); %Temps d'inici de servei serà el temps de fi de l'anterior
        CM.Time_Service_Ends(i)=CM.Time_Service_Begins(i)+CM.Service_Time(i);
        CM.W(i)=CM.Time_Service_Ends(i)- CM.Arrival_Time(i);
        CM.Wq(i)=CM.Time_Service_Begins(i)-CM.Arrival_Time(i); %Temps de cua serà la diferència entre temps arribada i temps inici de servei
    else
    %CAS2: Que quan el client arribi l'anterior client ja hagi marxat. Per tant mentre no es serveixen clients es serviran tasques de manteniment i després al client.
        tmf=CM.Time_Service_Ends(i-1); %Temps final client anterior
        while(tmf<CM.Arrival_Time(i)) %Mentres no ha arribat el client i farem tasques de mantenimient.
            CM.Service_Time(m)=exprnd(mu); %Calculem el temps de servei de manteniment.
            CM.Priority(m)=2; %Prioritat 2.
            CM.Num_manteniment(m)=m-n; %Numero tasca manteniment
            CM.Time_Service_Begins(m)=tmf; %La tasca comença tant bon punt l'anterior tasca acaba
            tmf=tmf+CM.Service_Time(m); %Guardem el temps final de la tasca de manteniment. tmf.
            CM.Time_Service_Ends(m)=tmf;
            CM.W(m)=CM.Time_Service_Ends(m)-CM.Time_Service_Begins(m);
            m=m+1;
        end
        %Servim al client
        CM.Time_Service_Begins(i)=tmf; %Es començarà a servir quan l'última tasca hagi acabat
        CM.Time_Service_Ends(i)=CM.Time_Service_Begins(i)+CM.Service_Time(i);
        CM.W(i)=CM.Time_Service_Ends(i)-CM.Arrival_Time(i);
        CM.Wq(i)=CM.Time_Service_Begins(i)-CM.Arrival_Time(i);
    end
end

%Ara tenim la taula primer tots els clients i després totes les tasques de manteniment. L'ordenem segons els temps d'inici de servei
CM = sortrows(CM,'Time_Service_Begins','ascend');

%Numerem les tasques.
for i=1:height(CM);
    CM.Num_tasca(i)=i;
end

%Fem una taula només de clients. C
k=find(CM.Priority==1);
C=CM(k,:);
C.Num_manteniment=[];

%Fem una taula només de Manteniment. M
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
mu=1/mu;
ro=lambda_clients/mu;
W=(2-ro)/mu/(1-ro);
result(2)=W;
disp(result);

