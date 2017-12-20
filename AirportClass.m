
classdef AirportClass < handle
    properties %(Access = private)
        nodes = [];
        links = [];
        excel_filename char;     % parameters for shortest path tool
        excel_number_nodes uint64; % parameters for shortest path tool
        excel_number_links uint64; % parameters for shortest path tool
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
            
            obj.excel_filename = '\ShDistSimple.xlsm';
            obj.excel_number_nodes = 7;
            obj.excel_number_links = 13; 
        
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
        
        function obj = setupRolingAirport(obj)
            
            obj.excel_filename = '\ShDistRol.xlsm';
            obj.excel_number_nodes = 29;
            obj.excel_number_links = 41; 
        
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
        
        
        
        function [Route1,Route2,Route3] = calcShortestRoutes(obj,n1,n2,speed)
            
            
            system('taskkill /F /IM EXCEL.EXE'); % DEBUG ONLY
            
            
            disp(['calcShortestRoutes from ', num2str(n1), ' to ', num2str(n2), ' ...']);
            %SuppDem = zeros(size(obj.nodes));
            SuppDem = zeros(obj.excel_number_nodes-1,1);
            SuppDem(n1) = +1;
            SuppDem(n2) = -1;
            %SuppDem = SuppDem.';
            %disp (SuppDem);
            
        %function [Route1,Route2,Route3] = calcShortestRoutes(SuppDem)
        %function [Route1,Route2,Route3] = ShortDist(SuppDem)


            %% - Input - %%
            % input must be a column vector representing the supply/demand
            % input is a vector full of zeros with 1 at starting node 
            % and -1 at destination node. Vector has 36 columns.
            xlswrite(obj.excel_filename, SuppDem, strcat( 'L2:L', num2str(obj.excel_number_nodes))) %write input in column
            
            %% - Determine First Route - %%
            TrueDist    = xlsread(obj.excel_filename,strcat( 'E2:E', num2str(obj.excel_number_links)));
            xlswrite(obj.excel_filename,TrueDist, strcat( 'C2:C', num2str(obj.excel_number_links))) %get rid of penalty distance

            %% - link to Excel - %%

            % Create object
            ExcelApp = actxserver('Excel.Application'); % Show window.
            ExcelApp.Visible = 1; % Open file 
            openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd, strcat('\', obj.excel_filename)));
            % Run solver using macro
            ExcelApp.Run('SolverMacro');
            openedWorkbook.Save;    %save before closing excel
            ExcelApp.Quit;          %quit excel
            ExcelApp.release;       %release object
            %% - End of link - %%

            % read shortest route after running solver
            OnRoute     = xlsread(obj.excel_filename, strcat('D2:D', num2str(obj.excel_number_links))); %read distance with penalties
            OnRoute1    = OnRoute; %define first route
            TotalDist1   = xlsread(obj.excel_filename,'F2:F2'); % read total distance

            %% - Define route 1 vector with time stamps - %%
            FromTo = xlsread(obj.excel_filename,strcat('A2:B', num2str(obj.excel_number_links)));
            Periods = xlsread(obj.excel_filename, strcat( 'E2:E', num2str(obj.excel_number_links))); % grab aircraft periods
            Periods = Periods/(speed*10);
            Periods = ceil(Periods); % round up
            OnRoute = xlsread(obj.excel_filename,strcat('D2:D', num2str(obj.excel_number_links)));
            SuppDem = xlsread(obj.excel_filename,strcat( 'L2:L', num2str(obj.excel_number_nodes)));
            Route1 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);

            %%% - End of Route1 - %%%


            %% - Determine Second Route - %%
            %FromToDist  = xlsread(obj.excel_filename,strcat('A2:C', num2str(obj.excel_number_links))); %determine distance from distance with penalty
            % DoubleDist will double the distance of used routes
            DoubleDist = TrueDist(:,1) + TrueDist(:,1).*OnRoute1(:,1);
            % Write DoubleDist onto distance
            xlswrite(obj.excel_filename,DoubleDist,strcat('C2:C', num2str(obj.excel_number_links)))
            % xlsread and write cannot be used while excel is running


            %% - Excel link - %%
            % Open file located in the current folder.
            ExcelApp = actxserver('Excel.Application'); % Show window.
            openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,strcat('\', obj.excel_filename)));
            ExcelApp.Run('SolverMacro');    % run macro
            openedWorkbook.Save;    %save before closing excel
            ExcelApp.Quit;          %quit excel
            ExcelApp.release;       %release object
            %% - End of link - %%

            % read shortest route after running solver
            OnRoute     = xlsread(obj.excel_filename,strcat('D2:D', num2str(obj.excel_number_links))); %read distance with penalties
            OnRoute2    = OnRoute; %define second route
            TotalDist2   = xlsread(obj.excel_filename,'F2:F2'); % read total distance

            %% - Define route 2 vector with time stamps - %%
            Route2 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);
            %%% - End of Route 2 - %%%


            %% - Determine Third Route - %%
            % DoubleDist will double the distance of used routes again
            DoubleDist = TrueDist(:,1) + TrueDist(:,1).*OnRoute1(:,1)+ TrueDist(:,1).*OnRoute2;
            % Write DoubleDist onto used distance column
            xlswrite(obj.excel_filename,DoubleDist,strcat('C2:C', num2str(obj.excel_number_links)))


            %% - Excel link - %%
            % Open file located in the current folder.
            ExcelApp = actxserver('Excel.Application'); % Show window.
            openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,strcat('\', obj.excel_filename)));
            ExcelApp.Run('SolverMacro');    % run macro
            openedWorkbook.Save;    % save before closing excel
            ExcelApp.Quit;          % quit excel
            ExcelApp.release;       % release object
            %% - End of link - %%

            % read shortest route after running solver
            OnRoute     = xlsread(obj.excel_filename,strcat('D2:D', num2str(obj.excel_number_links))); % read distance with penalties
            OnRoute3    = OnRoute; % define second route
            TotalDist3  = xlsread(obj.excel_filename,'F2:F2'); % read total distance

            %% - Define route 3 vector with time stamps
            Route3 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);


            %% - End of Route 3 - %%

            % this will make you laugh, but i couldnt find another soultion to stop
            % excel running in the background
            system('taskkill /F /IM EXCEL.EXE');
            
            disp(['calcShortestRoutes from ', num2str(n1), ' to ', num2str(n2), ' (end)']);
            
        end % end function    
            
            
        end
        
        
        
        
        
    end
    


