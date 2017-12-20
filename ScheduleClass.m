
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
        
        
        
    end
end
