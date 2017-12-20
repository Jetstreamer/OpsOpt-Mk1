
classdef ScheduleClass < handle
    properties %(Access = private)
        flights = [];
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
            f8.setProperties( 8, 'Aircraft8',  4 ); % seq, num, speed
            
            f1.setNodesAndTimes( 26, 15,  7, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f2.setNodesAndTimes( 24, 15,  6, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f3.setNodesAndTimes( 25,  6, 10, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f4.setNodesAndTimes( 25,  6,  8, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f5.setNodesAndTimes( 25,  6, 16, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f6.setNodesAndTimes( 24,  6, 14, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f7.setNodesAndTimes( 28, 26,  0, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            f8.setNodesAndTimes( 28, 26,  3, 0, 0 ); % n1, n2, t1, t2, tEarlyPushback
            
            airport = AirportClass;
            airport.setupRolingAirport();
            [r1,r2,r3] = airport.calcShortestRoutes(f1.node_origin, f1.node_dest, f1.max_taxi_speed);
            f1.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f2.node_origin, f2.node_dest, f2.max_taxi_speed);
            f2.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f3.node_origin, f3.node_dest, f3.max_taxi_speed);
            f3.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f4.node_origin, f4.node_dest, f4.max_taxi_speed);
            f4.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f5.node_origin, f5.node_dest, f5.max_taxi_speed);
            f5.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f6.node_origin, f6.node_dest, f6.max_taxi_speed);
            f6.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f7.node_origin, f7.node_dest, f7.max_taxi_speed);
            f7.loadBasicRoutes(r1,r2,r3);
            [r1,r2,r3] = airport.calcShortestRoutes(f8.node_origin, f8.node_dest, f8.max_taxi_speed);
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
            
            airport = AirportClass;
            airport.setupSimpleAirport();
            f = FlightClass;
            
            f.setProperties(1,'AF657',16); % seq, num, speed
            f.setNodesAndTimes(1,4,1,0,0); % n   1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            f = FlightClass;
            f.setProperties(2,'RY9121',12); % seq, num, speed
            f.setNodesAndTimes(4,1,1,0,0); % n1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            f = FlightClass;
            f.setProperties(3,'BA966',14); % seq, num, speed
            f.setNodesAndTimes(2,5,1,0,0); % n1, n2, t1, t2, tEarlyPushback
            [r1,r2,r3] = airport.calcShortestRoutes(f.node_origin, f.node_dest, f.max_taxi_speed);
            f.loadBasicRoutes(r1,r2,r3);
            obj.addFlight(f);

            disp('setupSimpleAirportSchedule completed');
        end
        
        %function y = serialize
        
    end
end
