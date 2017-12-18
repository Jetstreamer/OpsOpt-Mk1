

%% - input into cdmatrix file - %%% 
%%
%{
StartNode = input('Aircraft Starting Node = ')
EndNode = input('Aircraft End Node = ')
t = input('Time of above = ')
%}

StartNode = 25;
EndNode = 28;
time = 50; %input starting time as a multiple of 10 seconds Ex: start = 50 means starting time = 500 seconds or 8min 20sec
StartOrEndTime = 1; % 1 for start time, -1 for end time


%% - Create Time Vector for 8 minutes - %%
%%
%{
a = seconds(0:10:500);
[h,m,s] = hms(a);
Tv = [m;s].'; % time vector
Tv = [string(Tv(:,1)) + ':' + string(Tv(:,2))]
%write time vector into excel files
xlswrite('CdStart.xlsm',Tv,'A3:A'+string(1 + length(Tv)))
xlswrite('CdEnd.xlsm',Tv,'A3:A'+string(1 + length(Tv)))
%}

%% - create SuppDem Vector and find route- %%
%%
SuppDem = zeros(36,1);
SuppDem(StartNode) = 1; %from startnode input
SuppDem(EndNode) = -1; % form endnode input
[Route1,Route2,Route3] = ShortDist(SuppDem)

%% - Write in Excel Sheets
%%
ABC = 'B':'Z'; %start at second column
RouteNum = ["Route1","","","","Route2","","","","Route3","",""];
TTC = ["Tstart","Tend","Cd","","Tstart","Tend","Cd","","Tstart","Tend","Cd"];
Naming = [RouteNum;TTC];  % write the headers of arrays

ExcInpName = string(ABC(1)) + string(1) + ':' + string(ABC(11))+ string(2); %starting position of headers
Sheet = 'From '+string(StartNode)+' to '+ string(EndNode); % name of sheet to be written on

xlswrite('CdStart.xlsm', Naming ,Sheet, ExcInpName )
xlswrite('CdEnd.xlsm', Naming ,Sheet, ExcInpName )

for i = 0:1:10
    %%%%%%%%%%%%%%%%%%%%%%%
    %% - Route 1 start - %%
    %% %%%%%%%%%%%%%%%%%%%%
    t = time + i;
    if StartOrEndTime == 1; % grab start of route as time input 
    
        [CdMatrix1] = CdGet(t,StartOrEndTime,Route1);
        ExcInp = string(ABC(1)) + string(i+3) + ':' + string(ABC(3))+ string(i+3); % write on correct cells
        xlswrite('CdStart.xlsm', CdMatrix1,Sheet, ExcInp )

        %% - Route 2 start - %%
        %%
        [CdMatrix2] = CdGet(t,StartOrEndTime,Route2);
        ExcInp = string(ABC(5)) + string(i+3) + ':' + string(ABC(7))+ string(i+3);
        xlswrite('CdStart.xlsm', CdMatrix2,Sheet, ExcInp )


        %% - Route 3 start - %%
        %%    
        [CdMatrix3] = CdGet(t,StartOrEndTime,Route3);
        ExcInp = string(ABC(9)) + string(i+3) + ':' + string(ABC(11))+ string(i+3);
        xlswrite('CdStart.xlsm', CdMatrix3,Sheet, ExcInp)
    
    
    %%%%%%%%%%%%%%%%%%%%%
    %% - Route 1 End - %%
    %% %%%%%%%%%%%%%%%%%%
    elseif StartOrEndTime == -1; % grab end of route as time input 

        [CdMatrix1] = CdGet(t,StartOrEndTime,Route1);
        ExcInp = string(ABC(1)) + string(i+3) + ':' + string(ABC(3))+ string(i+3);
        xlswrite('CdEnd.xlsm', CdMatrix1,Sheet, ExcInp )


        %% - Route 2 End - %%
        %%
        [CdMatrix2] = CdGet(t,StartOrEndTime,Route2);
        ExcInp = string(ABC(5)) + string(i+3) + ':' + string(ABC(7))+ string(i+3);
        xlswrite('CdEnd.xlsm', CdMatrix2,Sheet, ExcInp )

        %% - Route 3 End - %%
        %%
        [CdMatrix3] = CdGet(t,StartOrEndTime,Route3);
        ExcInp = string(ABC(9)) + string(i+3) + ':' + string(ABC(11))+ string(i+3);
        xlswrite('CdEnd.xlsm', CdMatrix3,Sheet, ExcInp )

        
        
    end
    i = i+1;  % repeat for i
    disp('step ' + string(i-1))
end