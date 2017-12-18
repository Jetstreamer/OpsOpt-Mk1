

echo off
disp ('--- OpsOpt Mk2 -----------------------')
delta_t = 10; % seconds


airport = AirportClass;
airport.setupSimpleAirport();

[r1,r2,r3] = airport.calcShortestRoutes(1,4);


f1 = FlightClass;
f1 = f1.setProperties(1,'AF657',14); % seq, num, speed
f1 = f1.setNodesAndTimes(1,4,300/delta_t,0,0); % n1, n2, t1, t2, tEarlyPushback
    
f2 = FlightClass;
f2 = f2.setProperties(2,'RY9121',12); % seq, num, speed
f2 = f2.setNodesAndTimes(4,1,300/delta_t,0,0); % n1, n2, t1, t2, tEarlyPushback

% f3 = FlightClass;
% f3 = f3.setProperties(3,'BA966',14); % seq, num, speed
% f3 = f3.setNodesAndTimes(3,2,300/delta_t,0,0); % n1, n2, t1, t2, tEarlyPushback

schedule = ScheduleClass;
schedule.addFlight(f1);
schedule.addFlight(f2);
%schedule.addFlight(f3);
%schedule.delFlight(3);



% routes from Liam
 
routing_plan = RoutingClass;
%routing_plan = routing_plan.();




% build initial plan

disp(airport.linkLength(6,1))
%schedule.getFlight(1).optimal_time = 
%schedule.getFlight(1).optimal_route = []

%disp(schedule.getFlight(1).number)
%schedule.getFlight(1).R3_matrix = zeros(2,2,2);
%max_delay = 3; % multiples of delta_t
%max_routes = 1; % how many alternative routes are examined in the optimal plan



n_decision_vars = 0;
% n_decision_vars = n_decision_vars + 
% n_decision_vars = n_decision_vars + 
% n_decision_vars = n_decision_vars + 
% n_decision_vars = n_decision_vars + 
% n_decision_vars = n_decision_vars + 


global lp;
lp=mxlpsolve('make_lp', 0, n_decision_vars);
mxlpsolve('set_verbose', lp, 3);



for rrt = 1:50
    
    
    schedule.updatePosition(1,2,rrt);
    
    
    
end


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







