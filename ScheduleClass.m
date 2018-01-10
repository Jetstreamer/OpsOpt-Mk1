
classdef ScheduleClass < handle
    properties %(Access = private)
        flights = [];
        airport = AirportClass;
        delta_t = 10 % time period
    end
    
    methods
        function obj = addFlight(obj,x)
           obj.flights = [obj.flights x]; 
        end
            
        function obj = delFlight(obj,f)
            for index = 1:size(obj.flights,2)
                if(obj.flights(index).sequential == f)
                    obj.flights(index) = [];
                    break
                end
            end
        end 
        
        function flight = getFlight(obj,f)
            for index = 1:size(obj.flights,2)
                if(obj.flights(index).sequential == f)
                    flight = obj.flights(index);
                    break
                end
            end
        end
        
        function obj = updatePosition(obj,f,n,t)
            for index = 1:size(obj.flights,2)
                if(obj.flights(index).sequential == f)
                    obj.flights(index).node_origin = n;
                    obj.flights(index).time_origin = t;
                    break
                end
            end
        end
        
        function setupRolingSchedule(obj)
            
            f1 = FlightClass; % I know, not the most efficient, but it's more clear later on.
            f2 = FlightClass;
            f3 = FlightClass;
            f4 = FlightClass;
            f5 = FlightClass;
            f6 = FlightClass;
            f7 = FlightClass;
            f8 = FlightClass;
            
            f1.setProperties( 1, 'Aircraft1',  8 ); % seq, num, speed
            f2.setProperties( 2, 'Aircraft2', 16 ); % seq, num, speed
            f3.setProperties( 3, 'Aircraft3', 16 ); % seq, num, speed
            f4.setProperties( 4, 'Aircraft4',  8 ); % seq, num, speed
            f5.setProperties( 5, 'Aircraft5', 16 ); % seq, num, speed
            f6.setProperties( 6, 'Aircraft6',  8 ); % seq, num, speed
            f7.setProperties( 7, 'Aircraft7',  8 ); % seq, num, speed
            f8.setProperties( 8, 'Aircraft8',  8 ); % seq, num, speed
            
            f1.setNodesAndTimes( 26, 15,  7, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f2.setNodesAndTimes( 24, 15,  6, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f3.setNodesAndTimes( 25,  6, 10, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f4.setNodesAndTimes( 25,  6,  8, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f5.setNodesAndTimes( 25,  6, 16, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f6.setNodesAndTimes( 24,  6, 14, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f7.setNodesAndTimes( 28, 26,  0, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f8.setNodesAndTimes( 28, 26,  3, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            
            %airport = AirportClass;
            obj.airport.setupRolingAirport();
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f1.node_origin, f1.node_dest, f1.max_taxi_speed);
            f1.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f2.node_origin, f2.node_dest, f2.max_taxi_speed);
            f2.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f3.node_origin, f3.node_dest, f3.max_taxi_speed);
            f3.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f4.node_origin, f4.node_dest, f4.max_taxi_speed);
            f4.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f5.node_origin, f5.node_dest, f5.max_taxi_speed);
            f5.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f6.node_origin, f6.node_dest, f6.max_taxi_speed);
            f6.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f7.node_origin, f7.node_dest, f7.max_taxi_speed);
            f7.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f8.node_origin, f8.node_dest, f8.max_taxi_speed);
            f8.loadBasicRoutes(r1,r2,r3);
            
            obj.addFlight(f1);
            obj.addFlight(f2);
            obj.addFlight(f3);
            obj.addFlight(f4);
            obj.addFlight(f5);
            obj.addFlight(f6);
            obj.addFlight(f7);
            obj.addFlight(f8);
            disp('setupRolingSchedule completed');
        end
        
        function setupSimpleAirportSchedule(obj)    
            
            %airport = AirportClass;
            obj.airport.setupSimpleAirport();
            f = FlightClass;
            
            f.setProperties(1,'AF657',16); % seq, num, speed
            f.setNodesAndTimes(1,4,1,0,0); % n   1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            f = FlightClass;
            f.setProperties(2,'RY9121',12); % seq, num, speed
            f.setNodesAndTimes(4,1,1,0,0); % n1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            f = FlightClass;
            f.setProperties(3,'BA966',14); % seq, num, speed
            f.setNodesAndTimes(2,5,1,0,0); % n1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            disp('setupSimpleAirportSchedule completed');
        end
        
        function setupOneFlightSchedule(obj)    
            
            obj.airport.setupSimpleAirport();
            f = FlightClass;
            
            f.setProperties(1,'AF657',16); % seq, num, speed
            f.setNodesAndTimes(1,4,1,0,0); % n   1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = obj.airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            disp('setupOneFlightSchedule completed');            
        end
        
        function y = lp_getCostFunction(obj)
            ret = []; % vector
            for f = 1:size(obj.flights,2)
                    flightCost =  obj.flights(f).lp_calcRoutesCosts();
                    ret = [ret,flightCost]; % add flight to the long vector
            end
            y = ret;
        end
        
        function y = lp_calcNumVars(obj)
            num_vars = 0;
            for f = 1:size(obj.flights,2)
                    num_vars = num_vars + obj.flights(f).lp_calcNumVars();
            end
            y = num_vars;
        end
        
        function lp_setConstraintNO(obj,lp_handle)
            
            num_vars = obj.lp_calcNumVars();
            lp_vars = zeros(1,num_vars);
            disp(['lp_getConstraintNO(), num_vars ', num2str(num_vars)]);
            
            for i = 1:length(obj.airport.nodes)
                node = obj.airport.nodes(i);
                disp(['lp_getConstraintNO(), adding constraints on node n.', num2str(i)]);
                
                
                for t = 1:1000 % roomy index
                    time_interval = t * obj.delta_t;
                    
                    if time_interval > 120 % cutoff on specific time
                        break
                    end
                    
                    disp(['lp_getConstraintNO(), adding constraints on node n.', num2str(i), ', time interval ', num2str(time_interval)]);
                    
                    %mxlpsolve('add_constraint', lp_handle, lp_vars, 1, 1); % le, ge, eq = 1,2,3            
                end
            end
        end
            
        function y = lp_setConstraintLO(obj,lp_handle)
            
            num_vars = obj.lp_calcNumVars();
            disp(['lp_setConstraintLO(), num_vars ', num2str(num_vars)]);
            cnt1 = 0;
            
            for i = 1:length(obj.airport.links)
                n1 = obj.airport.links(i,1);
                n2 = obj.airport.links(i,2);
                disp(['lp_setConstraintLO(), link n.', num2str(i), ' (nodes ', num2str(n1), '-', num2str(n2), ')']);
  
                for t = 0:1000 % roomy index
                    time_interval = t * obj.delta_t;
                    
                    if time_interval > 120 % cutoff on specific time
                        break
                    end
                    
                    disp(['lp_setConstraintLO(), link n.', num2str(i), ' (nodes ', num2str(n1), '-', num2str(n2), '), time ', num2str(time_interval)]);
                    lp_vars = [];
                    
                    for f = 1:size(obj.flights,2)
                        disp(['lp_setConstraintLO(), link n.', num2str(i), ' (nodes ', num2str(n1), '-', num2str(n2), '), time ', num2str(time_interval), ', flight ', num2str(f)]);
                        
                        %obj.flights(f).routes_with_variations
                        
                        occupancy = obj.flights(f).lp_markLinkOccupancy(n1,n2,time_interval);
                        
                        lp_vars = [lp_vars,occupancy]; % add flight to the long vector
                        
                    end
                    
                    num_possible_conflicts = sum(lp_vars);
                    %disp(['lp_setConstraintLO(), link n.', num2str(i), ' (nodes ', num2str(n1), '-', num2str(n2), '), time ', num2str(time_interval)]);
                    
                    if (num_possible_conflicts > 1)

                       disp(['lp_setConstraintLO(), link n.', num2str(i), ' (nodes ', num2str(n1), '-', num2str(n2), ...
                           '), time ', num2str(time_interval), ', occupancy ', num2str(num_possible_conflicts)]);
                       mxlpsolve('add_constraint', lp_handle, lp_vars, 1, 1); % le, ge, eq = 1,2,3             
                       cnt1 = cnt1 + 1;
                    else
                           disp(['lp_setConstraintLO(), link n.', num2str(i), ' (nodes ', num2str(n1), '-', num2str(n2), ...
                               '), time ', num2str(time_interval), ', occupancy ', num2str(num_possible_conflicts)]);
                    end
                    
                end % roomy t
               
            end % for links
            
            y = cnt1;
            
        end % function
        
        
        function y = lp_setConstraintWT(obj,lp_handle)

            num_vars = obj.lp_calcNumVars();
            disp(['lp_setConstraintWT(), num_vars ', num2str(num_vars)]);
            index_current_flight = 1;
            cnt1 = 0;

            for f = 1:size(obj.flights,2)
                disp(['lp_setConstraintWT(), flight ', num2str(f)]);
                len_delay_block = sum(obj.flights(f).len_routes); % calculate length to be jumped across different delays.

                for r = 1:obj.flights(f).num_routes
                    disp(['lp_setConstraintWT(), flight ', num2str(f), ', route ', num2str(r)]);

                    index_current_route = index_current_flight; % start from beginning of current 'flight' block
                    index_current_route = index_current_route + sum(obj.flights(f).len_routes(1:(r-1)));
                    num_segments = obj.flights(f).len_routes(r);

                    for s = 2:num_segments

                        lp_vars = zeros(1,num_vars);
                        index = index_current_route + (s-1); % offset to specific segment (on 'zero-delay' route)

                        for d = 1:obj.flights(f).max_delay_periods
                            lp_vars(index)    = +(2^(d-1));
                            lp_vars(index -1) = -(2^(d-1));
                            % find a way to include the 'w'
                            index = index + len_delay_block; % advance by EXACTLY one 'delay' block
                        end

                        % add constraint
                        disp(['lp_setConstraintWT(), flight ', num2str(f), ', route ', num2str(r), ', segment ', num2str(s)]);
                        mxlpsolve('add_constraint', lp_handle, lp_vars, 3, 0); % le, ge, eq = 1,2,3
                        cnt1 = cnt1 + 1;

                    end
                end

                len_flight_block = obj.flights(f).lp_calcNumVars();
                index_current_flight = index_current_flight + len_flight_block; % advance to beginning of next flight
                
            end % for on flights

            y = cnt1;
        end % function
    end
    
    end


    
    
    
    
    