
classdef FlightClass < handle
    properties %(Access = private)
        sequential uint64 % number 
        number string % string
        max_taxi_speed double % [m/s]
        node_origin uint64
        node_dest uint64
        time_origin uint64
        time_dest uint64
        time_early_pushback uint64
        
        optimal_time uint64
        optimal_route 
        R3_matrix % used for the MILP data
    end
    
    methods
        %function obj = FlightClass()
            
            
        %end
        
        function obj = setProperties(obj,seq,num,speed)
            obj.sequential = seq;
            obj.number = num;
            obj.max_taxi_speed = speed;
        end
        
        function obj = setNodesAndTimes(obj,n1,n2,t1,t2,tEarly)
            obj.node_origin =n1;
            obj.node_dest  = n2;
            obj.time_origin  = t1;
            obj.time_dest  = t2;
            obj.time_early_pushback  = tEarly;
        end
        
        function obj = updatePosition(obj,n,t)
            obj.node_origin = n;
            obj.time_origin = t;
        end
        
        function y = getNum(obj)
            y = obj.number;
        end

    
    end
end



