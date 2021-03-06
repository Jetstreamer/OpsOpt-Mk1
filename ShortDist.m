%%%% WARNING! Close and Save your Excel before running this code.


%This Code will 




function [Route1,Route2,Route3] = ShortDist(SuppDem)



%% - Input - %%
% input must be a column vector representing the supply/demand
% input is a vector full of zeros with 1 at starting node 
% and -1 at destination node. Vector has 36 columns.
xlswrite('ShDist.xlsm',SuppDem,'L2:L37') %write input in column



%% - Determine First Route - %%
TrueDist    = xlsread('ShDist.xlsm','E2:E61');
xlswrite('ShDist.xlsm',TrueDist,'C2:C61') %get rid of penalty distance

%% - link to Excel - %%

% Create object
ExcelApp = actxserver('Excel.Application'); % Show window.
ExcelApp.Visible = 1; % Open file 
openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,'\ShDist.xlsm'));
% Run solver using macro
ExcelApp.Run('SolverMacro');
openedWorkbook.Save;    %save before closing excel
ExcelApp.Quit;          %quit excel
ExcelApp.release;       %release object
%% - End of link - %%

% read shortest route after running solver
OnRoute     = xlsread('ShDist.xlsm','D2:D61'); %read distance with penalties
OnRoute1    = OnRoute; %define first route
TotalDist1   = xlsread('ShDist.xlsm','F2:F2'); % read total distance

%% - Define route 1 vector with time stamps - %%
FromTo = xlsread('ShDist.xlsm','A2:B61');
Periods = xlsread('ShDist.xlsm','G2:G61'); % grab aircraft periods
Periods = ceil(Periods); % round up
OnRoute = xlsread('ShDist.xlsm','D2:D61');
SuppDem = xlsread('ShDist.xlsm','L2:L37');
Route1 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);

%%% - End of Route1 - %%%


%% - Determine Second Route - %%
%FromToDist  = xlsread('ShDist.xlsm','A2:C61'); %determine distance from distance with penalty
% DoubleDist will double the distance of used routes
DoubleDist = TrueDist(:,1) + TrueDist(:,1).*OnRoute1(:,1);
% Write DoubleDist onto distance
xlswrite('ShDist.xlsm',DoubleDist,'C2:C61')
% xlsread and write cannot be used while excel is running


%% - Excel link - %%
% Open file located in the current folder.
ExcelApp = actxserver('Excel.Application'); % Show window.
openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,'\ShDist.xlsm'));
ExcelApp.Run('SolverMacro');    % run macro
openedWorkbook.Save;    %save before closing excel
ExcelApp.Quit;          %quit excel
ExcelApp.release;       %release object
%% - End of link - %%

% read shortest route after running solver
OnRoute     = xlsread('ShDist.xlsm','D2:D61'); %read distance with penalties
OnRoute2    = OnRoute; %define second route
TotalDist2   = xlsread('ShDist.xlsm','F2:F2'); % read total distance

%% - Define route 2 vector with time stamps - %%
Route2 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);

%%% - End of Route 2 - %%%


%% - Determine Third Route - %%
% DoubleDist will double the distance of used routes again
DoubleDist = TrueDist(:,1) + TrueDist(:,1).*OnRoute1(:,1)+ TrueDist(:,1).*OnRoute2;
% Write DoubleDist onto used distance column
xlswrite('ShDist.xlsm',DoubleDist,'C2:C61')


%% - Excel link - %%
% Open file located in the current folder.
ExcelApp = actxserver('Excel.Application'); % Show window.
openedWorkbook = ExcelApp.Workbooks.Open(fullfile(pwd,'\ShDist.xlsm'));
ExcelApp.Run('SolverMacro');    % run macro
openedWorkbook.Save;    % save before closing excel
ExcelApp.Quit;          % quit excel
ExcelApp.release;       % release object
%% - End of link - %%

% read shortest route after running solver
OnRoute     = xlsread('ShDist.xlsm','D2:D61'); % read distance with penalties
OnRoute3    = OnRoute; % define second route
TotalDist3  = xlsread('ShDist.xlsm','F2:F2'); % read total distance

%% - Define route 3 vector with time stamps
Route3 = RouteConvert(OnRoute,FromTo,Periods,SuppDem);


%% - End of Route 3 - %%

% this will make you laugh, but i couldnt find another soultion to stop
% excel running in the background
system('taskkill /F /IM EXCEL.EXE');
end % end function