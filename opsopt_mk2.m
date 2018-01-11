
clc;
echo off
disp ('--- OpsOpt Mk2 -----------------------')
delta_t = 10; % seconds

% clc;
% lp=mxlpsolve('make_lp',0,4);
% mxlpsolve('add_constraint',lp,[3, 2, 2, 1],3,4.4);
% mxlpsolve('add_constraint',lp,[0, 4, 3, 1],2,3);
% wololo = [2, 3, -2, 3];
% mxlpsolve('set_obj_fn',lp,wololo);
% result=mxlpsolve('solve',lp)
% obj=mxlpsolve('get_objective', lp)
% x=mxlpsolve('get_variables', lp)
% mxlpsolve('delete_lp', lp);


schedule = ScheduleClass;
%schedule.setupOneFlightSchedule(); % pick one schedule (it includes the airport)
schedule.setupSimpleAirportSchedule();
%schedule.setupRolingSchedule();

lp_vars = schedule.lp_getCostFunction();
n_lp_vars = size(lp_vars,2);
disp(['n_lp_vars ', num2str(n_lp_vars)]);

global lp;
lp=mxlpsolve('make_lp', 0, n_lp_vars);

disp 'set_obj_fn'
mxlpsolve('set_obj_fn', lp, lp_vars); % put back to +lp_vars later on !!!!
[row_vec, loolo] = mxlpsolve('get_obj_fn', lp);


%c0 = schedule.lp_setConstraintNO(lp);
c1 = schedule.lp_setConstraintLO(lp);
c2 = schedule.lp_setConstraintWT(lp);
c3 = schedule.lp_setConstraintRADC(lp);

lp_n_rows = mxlpsolve('get_Nrows', lp);

disp 'set_binary'
ret = mxlpsolve('set_binary', lp, ones(1,n_lp_vars)); % all binary variables

disp 'solve'
ret = mxlpsolve('solve', lp);

if(ret == 0)
    disp 'get_objective';
    x1 = mxlpsolve('get_objective', lp);

    disp 'get_variables';
    resulting_vars = mxlpsolve('get_variables', lp);
    schedule.lp_decodeResults(resulting_vars);

    disp 'get_constraints';
    x2 = mxlpsolve('get_constraints', lp);

else
   disp(['--- ERROR --- solve failed, returns ' , num2str(ret)]); 
end

disp 'delete_lp';
mxlpsolve('delete_lp', lp);








