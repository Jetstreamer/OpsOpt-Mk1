
classdef AirportClass < handle
    properties %(Access = private)
        nodes = [];
        links = [];
    end
    methods
        
        % keep aligned with the equivalent data in ShDistSimple.xlsm
        function obj = setupSimpleAirport(obj)
            obj.nodes = [1:1:6];
            obj.links = zeros(6,5); % [node orig, node dest, len, fwd ok, backward ok]
            obj.links(1,:) = [1,2,150,1,1];
            obj.links(2,:) = [2,3,250,1,1];
            obj.links(3,:) = [3,4,450,1,1];
            obj.links(4,:) = [4,5,250,1,1];
            obj.links(5,:) = [5,6,650,1,1];
            obj.links(6,:) = [6,1,750,1,1];
        end
        
        function obj = setupLessSimpleAirport(obj)
            obj.nodes = [1:1:6];
            obj.links = zeros(8,5); % [node orig, node dest, len, fwd ok, backward ok]
            obj.links(1,:) = [1,2,150,1,1];
            obj.links(2,:) = [2,3,250,1,1];
            obj.links(3,:) = [3,4,450,1,1];
            obj.links(4,:) = [4,5,250,1,1];
            obj.links(5,:) = [5,6,650,1,1];
            obj.links(6,:) = [6,1,750,1,1];
            obj.links(7,:) = [2,6,150,1,1]; % added two cross branches
            obj.links(8,:) = [3,5,350,1,1]; % added two cross branches
        end
        
        
        
        function obj = setupComplexAirport(obj)
            % empty!
        end
        
        function y = linkLength(obj,n1,n2)
            for i = 1:size(obj.links)
                if((obj.links(i,1) == n1) && (obj.links(i,2) == n2) && (obj.links(i,4) == 1))
                    y = (obj.links(i,3));
                    break;
                elseif((obj.links(i,1) == n2) && (obj.links(i,2) == n1) && (obj.links(i,5) == 1))
                    y = (obj.links(i,3));
                    break;
                else
                    y = 0; % overwrite
                end
            end
        end
        
        
        function [Route1,Route2,Route3] = calcShortestRoutes(obj,n1,n2)
            
            %SuppDem = zeros(size(obj.nodes));
            SuppDem = zeros(6,1);
            SuppDem(n1) = +1;
            SuppDem(n2) = -1;
            %SuppDem = SuppDem.';
            disp (SuppDem);
            
        %function [Route1,Route2,Route3] = calcShortestRoutes(SuppDem)
        %function [Route1,Route2,Route3] = ShortDist(SuppDem)


            %% - Input - %%
            % input must be a column vector representing the supply/demand
            % input is a vector full of zeros with 1 at starting node 
            % and -1 at destination node. Vector has 36 columns.
            xlswrite('ShDistSimple.xlsm',SuppDem,'L2:L37') %write input in column



            %% - Determine First Route - %%
            TrueDist    = xlsread('ShDistSimple.xlsm','E2:E13');
            xlswrite('ShDistSimple.xlsm',TrueDist,'C2:C13') %get rid of penalty distance

            %% - link to Excel - %%

            % Create object
            ExcelApp = actxserver('Excel.Application'); % Show window.
            ExcelApp.Visible = 1; % Open file 
            openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,'\ShDistSimple.xlsm'));
            % Run solver using macro
            ExcelApp.Run('SolverMacro');
            openedWorkbook.Save;    %save before closing excel
            ExcelApp.Quit;          %quit excel
            ExcelApp.release;       %release object
            %% - End of link - %%

            % read shortest route after running solver
            OnRoute     = xlsread('ShDistSimple.xlsm','D2:D13'); %read distance with penalties
            OnRoute1    = OnRoute; %define first route
            TotalDist1   = xlsread('ShDistSimple.xlsm','F2:F2'); % read total distance

            %% - Define route 1 vector with time stamps - %%
            FromTo = xlsread('ShDistSimple.xlsm','A2:B13');
            Periods = xlsread('ShDistSimple.xlsm','G2:G13'); % grab aircraft periods
            Periods = ceil(Periods); % round up
            OnRoute = xlsread('ShDistSimple.xlsm','D2:D13');
            SuppDem = xlsread('ShDistSimple.xlsm','L2:L37');
            Route1 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);

            %%% - End of Route1 - %%%


            %% - Determine Second Route - %%
            %FromToDist  = xlsread('ShDistSimple.xlsm','A2:C13'); %determine distance from distance with penalty
            % DoubleDist will double the distance of used routes
            DoubleDist = TrueDist(:,1) + TrueDist(:,1).*OnRoute1(:,1);
            % Write DoubleDist onto distance
            xlswrite('ShDistSimple.xlsm',DoubleDist,'C2:C13')
            % xlsread and write cannot be used while excel is running


            %% - Excel link - %%
            % Open file located in the current folder.
            ExcelApp = actxserver('Excel.Application'); % Show window.
            openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,'\ShDistSimple.xlsm'));
            ExcelApp.Run('SolverMacro');    % run macro
            openedWorkbook.Save;    %save before closing excel
            ExcelApp.Quit;          %quit excel
            ExcelApp.release;       %release object
            %% - End of link - %%

            % read shortest route after running solver
            OnRoute     = xlsread('ShDistSimple.xlsm','D2:D13'); %read distance with penalties
            OnRoute2    = OnRoute; %define second route
            TotalDist2   = xlsread('ShDistSimple.xlsm','F2:F2'); % read total distance

            %% - Define route 2 vector with time stamps - %%
            Route2 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);
            %%% - End of Route 2 - %%%


            %% - Determine Third Route - %%
            % DoubleDist will double the distance of used routes again
            DoubleDist = TrueDist(:,1) + TrueDist(:,1).*OnRoute1(:,1)+ TrueDist(:,1).*OnRoute2;
            % Write DoubleDist onto used distance column
            xlswrite('ShDistSimple.xlsm',DoubleDist,'C2:C13')


            %% - Excel link - %%
            % Open file located in the current folder.
            ExcelApp = actxserver('Excel.Application'); % Show window.
            openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,'\ShDistSimple.xlsm'));
            ExcelApp.Run('SolverMacro');    % run macro
            openedWorkbook.Save;    % save before closing excel
            ExcelApp.Quit;          % quit excel
            ExcelApp.release;       % release object
            %% - End of link - %%

            % read shortest route after running solver
            OnRoute     = xlsread('ShDistSimple.xlsm','D2:D13'); % read distance with penalties
            OnRoute3    = OnRoute; % define second route
            TotalDist3  = xlsread('ShDistSimple.xlsm','F2:F2'); % read total distance

            %% - Define route 3 vector with time stamps
            Route3 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);


            %% - End of Route 3 - %%

            % this will make you laugh, but i couldnt find another soultion to stop
            % excel running in the background
            system('taskkill /F /IM EXCEL.EXE');
        end % end function    
            
            
        end
        
        
        
        
        
    end
    


