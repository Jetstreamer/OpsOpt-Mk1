

echo off
disp ('--- OpsOpt Mk2 -----------------------')
delta_t = 10; % seconds

%airport = AirportClass;
%airport.setupSimpleAirport();
schedule = ScheduleClass;

%schedule.setupSimpleAirportSchedule();
%schedule.setupRolingSchedule();




global lp;
lp=mxlpsolve('make_lp', 0, n_decision_vars);
mxlpsolve('set_verbose', lp, 3);


% 
% for rrt = 1:50
%     
%     
%     schedule.updatePosition(1,2,rrt);
%     
%     
%     
% end


% 
% 
% global lp;
% lp=mxlpsolve('make_lp', 0, n_decision_vars);
% mxlpsolve('set_verbose', lp, 3);
% 
% 
% 
% disp 'solve'
% mxlpsolve('solve', lp)
% 
% disp 'get_objective'
% mxlpsolve('get_objective', lp)
% 
% disp 'get_variables'
% resulting_vars = mxlpsolve('get_variables', lp)
% 
% disp 'get_constraints'
% mxlpsolve('get_constraints', lp)
% 
% disp 'delete_lp'
% mxlpsolve('delete_lp', lp);
% 








