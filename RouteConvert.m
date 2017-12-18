%example inputs for running code

%FromTo = xlsread('ShDist.xlsm','A2:B61');
%Periods = xlsread('ShDist.xlsm','G2:G61'); % grab aircraft periods
%Periods = ceil(Periods); % round up
%OnRoute = xlsread('ShDist.xlsm','D2:D61');
%SuppDem = xlsread('ShDist.xlsm','L2:L37');

function [ExcelRoute]= RouteConvert(OnRoute,FromTo,Periods,SuppDem)


%% - Get start and end node - %%
for i = 1:length(SuppDem)
    if SuppDem(i) == 0 % ignore zeros
        i = i+1;
    elseif SuppDem(i) == 1
        StartNode = i; % grab 1 as incomming aircraft node
        i = i+1;
    elseif SuppDem(i) == -1
        EndNode = i; % grab -1 as last node 
        i=i+1;
    end
end

%% - Rearrange vector so that route makes sense - %%

Occupy = StartNode;
FromToRoute = FromTo.*OnRoute; % grab only relevant data (this will give 0 on routes not taken)
RouteLink = []; % description of route from node to node

while Occupy ~= EndNode %run until destination is reached
    for i = 1:length(FromToRoute) %check aircraft position
        if FromToRoute(i,1) == Occupy % check aircraft position
            RouteLink = [RouteLink;FromToRoute(i,:)]; %append route
            Occupy = FromToRoute(i,2); % step the aircraft
            break
        else
            i = i+1;
        end
    end
end


%% - Multiply links for occupation time - %%
RoutePeriod = []; % description of node to node with time steps
for i = 1:length(RouteLink) % Check through Route vector
    for j = 1:length(FromToRoute) % Check match with FromToRoute vector
        if RouteLink(i,:) == FromToRoute(j,:) % check match
            for k = 1:Periods(j,1)    %Grab number of time steps
                RoutePeriod = [RoutePeriod;FromToRoute(j,:)]; % insert time steps
                k = k+1;
            end
            i = i+1;
            break
        else % no match, check next
            j = j+1;
        end
    end
    i=i+1; % continue checking routelink
end



%% - Add start and end to vector - %% 
RouteVec = [StartNode,StartNode;RoutePeriod;EndNode,EndNode]; % Define Route vector

%% - Convert to Excel Format - %%
ExcelRoute = string([]);
for i = 1:(length(RoutePeriod))
    ExcelRoute(i,1) = string(RoutePeriod(i,1)) + ' - ' + string(RoutePeriod(i,2));
end
ExcelRoute(1,1) = string(RouteVec(1,1));
ExcelRoute = string([ExcelRoute;RouteVec(end,1)]);
end