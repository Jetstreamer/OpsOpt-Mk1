


function [CdMatrix] = CdGet(t,StartOrEndTime,Route)

Kr = 1; % Kr is a scaling constant

%% - Input is start time - %%
%%
if StartOrEndTime == 1

    TimeStart = 10*t;
    
%% - Get Tend, Cd  for route - %%
%%
    
    TimeEnd = TimeStart+10*length(Route);
    Cd = Kr*(TimeStart - TimeEnd);
    CdMatrix = [TimeStart, TimeEnd, Cd];

    
elseif StartOrEndTime == -1

    TimeEnd = 10*t;
    
%% - Get Tstart, Cd  for route - %%
%%

    TimeStart = TimeEnd - 10*length(Route);
    Cd = Kr*(TimeStart - TimeEnd);
    CdMatrix = [TimeStart, TimeEnd, Cd];


end
end
