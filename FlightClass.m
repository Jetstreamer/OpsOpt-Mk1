
classdef FlightClass < handle
    properties %(Access = private)
        sequential uint64 % number 
        number string % string
        max_taxi_speed double % [m/s]
        max_delay_periods % [-] number of periods of max delay
        node_origin uint64
        node_dest uint64
        time_origin uint64
        time_dest uint64
        time_early_pushback uint64
        delta_t = 10 % time period
        num_routes = 3;        % EXTEND USAGE
        %max_delay_periods = 3; % EXTEND USAGE
        
        routes_from_excel
        routes_with_variations % all routes/delays variations with time.
        num_decision_variables % the total size of 'routes_with_variations'
        lp_serialized_data % ready for LPsolver
        kf = 1 % LP cost parameters
        kr = 1 % LP cost parameters
        kd = 1 % LP cost parameters
    end
    
    
    methods
        %function obj = FlightClass() % constructor
            
            
        %end
        
        function y = lp_calcRoutesCosts(obj)
            
            [num_delays,num_routes] = size(obj.routes_with_variations); % read number of routes in memory
            %ret = zeros(num_delays,num_routes);
            ret = [];
            index = 0;
            
            for d = 1:num_delays
                for r = 1:num_routes
                   [n_periods,dummy] = (size(obj.routes_from_excel{r})); % back to original data (is the same...)
                   total_cost = obj.kf * ( obj.kr*( n_periods ) + (obj.kd*(d-1))); % d=1 means no delay
                   index = index + n_periods; % advance
                   ret(index) = total_cost; % save cost in last segment of each delay/route combination
                end
            end
            
            y = ret;
        end
        
        function y = lp_calcNumVars(obj)
            ret = 0;
            [num_delays,num_routes] = size(obj.routes_with_variations); % read number of routes in memory
            
            for d = 1:num_delays
                for r = 1:num_routes
                    [n_periods,dummy] = (size(obj.routes_from_excel{r})); % back to original data (is the same...)
                    ret = ret + n_periods;
                end
            end
            
            %ret = num_delays * num_routes * n_periods;
            %disp(['lp_calcNumVars ', num2str(ret )]);
            y = ret;
        end
        
        function y = lp_markLinkOccupancy(obj,n1,n2,time_interval)
            
            ret = zeros(1,obj.lp_calcNumVars());
            index = 0;
            
            for d = 1:obj.max_delay_periods % the '3' allowed delay bands
                for r = 1:obj.num_routes % the '3' routes                
                    
                    appo = obj.routes_with_variations{r,d};
                    
                    for rrr = 1:size(appo,1) % cycles rows with links+times
                            
                        index = index + 1;
                        isLink = strfind (appo{rrr,1}, '-'); % reads link string, finds '-' separator
                            
                        if(appo{rrr,2} == time_interval) % match time
                            if(isLink ~= 0) % link, not node
                                
                                eee = textscan (appo{rrr,1} , '%d - %d'); 
                                m1 = eee{1,1};
                                m2 = eee{1,2};
                                
                                if(((n1 == m1) && (n2 == m2)) || ((n2 == m1) && (n1 == m2)))
                                    
                                    % in this flight, for each delay and route
                                    % scroll through segment list and if nodes match and times match
                                    % set variable to 1
                                    ret(index) = 1;
                                end
                            
                            end
                            
                        end

                        
%                         
                    end
                
%                     
%                     if time_sequence{s,1} = obj.routes_from_excel{r}(s);
%                         time_sequence{s,2} = starting_time + (s-1)*obj.delta_t; % populates the default times in each segment
%                     end
                end
            end
            
            
            % match link, put to 1  
            %disp(['index is ', num2str(index)]);
            
            y = ret;
        end
            
        function obj = setProperties(obj,seq,num,speed)
            %disp(['setProperties, flight ',num2str(seq)]);
            obj.sequential = seq;
            obj.number = num;
            obj.max_taxi_speed = speed;
            obj.max_delay_periods = 3; % fixed to 3 for now, maybe sensitivity analysis later on
        end
        
        function obj = setNodesAndTimes(obj,n1,n2,t1,t2,tEarly)
            disp(['setNodesAndTimes, flight ',num2str(obj.sequential), ', t1 ', num2str(t1)]);
            obj.node_origin =n1;
            obj.node_dest  = n2;
            obj.time_origin  = t1;
            obj.time_dest  = t2;
            obj.time_early_pushback  = tEarly;
        end
        
        function obj = updatePosition(obj,n,t)
            disp(['updatePosition, flight ',num2str(obj.sequential)]);
            obj.node_origin = n;            
            obj.time_origin = t;
        end
        
        function y = getNum(obj)
            y = obj.number;
        end
        
        function loadBasicRoutes(obj,r1,r2,r3)
            disp(['loadBasicRoutes, flight ',num2str(obj.sequential)]);
            obj.routes_from_excel{1} = r1;
            obj.routes_from_excel{2} = r2;
            obj.routes_from_excel{3} = r3;
            obj.createRoutesVariations();
        end
        
        function createRoutesVariations(obj)
            disp(['createRoutesVariations, flight ',num2str(obj.sequential)]);
            
            [dummy,num_routes] = size(obj.routes_from_excel); % read number of routes in memory
            obj.routes_with_variations = cell(num_routes, obj.max_delay_periods); % initialize 3x3 cell for routes/delays
            obj.num_decision_variables = 0;
            
            for r = 1:num_routes % the '3' routes
                
                [n_periods,dummy] = (size(obj.routes_from_excel{r})); % [13,1]
                
                for d = 1:obj.max_delay_periods % the '3' allowed delay bands
                    
                    time_sequence = cell(n_periods,2); % creates the time-evolving movement of the aircraft
                    starting_time = (d-1)*obj.delta_t; % determines the starting time
                    
                    for s = 1:n_periods
                        time_sequence{s,1} = obj.routes_from_excel{r}(s);
                        time_sequence{s,2} = starting_time + (s-1)*obj.delta_t; % populates the default times in each segment
                    end
                    
                    obj.routes_with_variations{r,d} = time_sequence; % stores the segment/time sequence in memory
                    obj.num_decision_variables = obj.num_decision_variables + n_periods; % every sequence will translate in decision variables
                end
                
            end
            
            disp(['flight ', num2str(obj.sequential), ' has ', num2str(obj.num_decision_variables), ' decision variables']);
        % fill routes_with_time     using time and routes arrays
        end
        

    
    end
end



