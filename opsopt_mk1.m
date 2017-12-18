
echo off
% f_max = 8; % 8 flight
% d_max = 5; % 5 times the time step (of 10 seconds).
% r_max = 3; % 3 route 
% s_max = 33; % 33 links
%
f_max = 2; % 8 [-] flights
d_max = 1; % 5 [-] number of maximum periods of delay assignable
r_max = 1; % 3 [-] route 
s_max = 12; % 33 [-] links
t_interval = 10; % [seconds]
t_max = 10; % [-] number of intervals
% n_max = 28; % number of nodes
% l_max = 10; % number of links
global n_decision_vars;
n_decision_vars = 2 * f_max * d_max * r_max * s_max;

% simplified airport - 2D array with [orig, dest, length, time to cross
% fast, time to cross slow]
total_links = 12; % bi-direction links appear twice
speed_1 = 16; % [m/s]
speed_2 = 8; % [m/s]
global apt_links;
apt_links = zeros(total_links,5);

link_length = 300;
apt_links( 1,:) = [1, 2, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
apt_links( 2,:) = [2, 1, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ]; 

link_length = 350;
apt_links( 3,:) = [2, 3, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
apt_links( 4,:) = [3, 2, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
                  
link_length = 200;           
apt_links( 5,:) = [3, 4, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
apt_links( 6,:) = [4, 3, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
                  
link_length = 500;           
apt_links( 7,:) = [4, 5, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
apt_links( 8,:) = [5, 4, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
                  
link_length = 100;           
apt_links( 9,:) = [5, 6, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
apt_links(10,:) = [6, 5, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
                  
link_length = 340;           
apt_links(11,:) = [6, 1, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];
apt_links(12,:) = [1, 6, link_length, round(link_length/speed_1/t_interval), round(link_length/speed_2/t_interval) ];

global apt_nodes;
apt_nodes = [1:1:6];

% simplified schedule - 2D array with [node start, node end, time start,
% time end, max time variation (early pushback for departing flights)
global schedule;
schedule = zeros(f_max,5);
schedule(1,:) = [1,4,10,0,0]; % RWY to apron, leaves at t=0 [sec]
%schedule(2,:) = [4,1,10,0,0]; % apron to RWY, leaves at t=0 [sec]

% simplified artificial routes as calculated by Liam part
global actual_routes;
actual_routes = zeros(f_max, r_max, t_max);
actual_routes(1,1, :) = [0,1,3,3,3,5,5,5,0,0];
%actual_routes(1,2, :) = [0,12,10,8,0,0,0,0,0,0];
actual_routes(2,1, :) = [0,6,6,4,4,4,2,2,0,0];
%actual_routes(2,2, :) = [0,8,10,10,10,10,12,12,0,0];
    
%xw_serialized = zeros(1, n_decision_vars);


global w_matrix;
w_matrix = zeros(f_max, d_max, r_max, s_max); % repetita, always f,d,r,s


global lp;
lp=mxlpsolve('make_lp', 0, n_decision_vars);
mxlpsolve('set_verbose', lp, 3);

add_ObjFunction()
add_NO_constraints()
%add_LO_constraints()
%add_RDC_constraints()
add_WT_constraints()


disp 'solve'

%uuu = ones(n_decision_vars);
%mxlpsolve('set_int', lp, uuu)
mxlpsolve('solve', lp)

disp 'get_objective'
mxlpsolve('get_objective', lp)
disp 'get_variables'
resulting_vars = mxlpsolve('get_variables', lp)
disp 'get_constraints'
mxlpsolve('get_constraints', lp)
disp 'delete_lp'
mxlpsolve('delete_lp', lp);

x_matrix = X_deserializer(resulting_vars.',x_matrix);

showFlights()
 



function showFlights()

global x_matrix

for f_index = 1:size(x_matrix,1) 
    showFlight(f_index)
end

end


function showFlight(f)

global x_matrix

if f > size(x_matrix,1)
    disp(['flight ', num2str(f), ' not available '])
    return
end    
    
for r_index = 1:size(x_matrix,3)

    disp(['flight ', num2str(f), ' route ', num2str(r_index), ' -------------------------- START'])

    for s_index = 1:size(x_matrix,4)
        for d_index = 1:size(x_matrix,2)

            if x_matrix(f,d_index,r_index,s_index) == 1
                disp(['flight ', num2str(f), ' route ', num2str(r_index), ' segment ', numstr(s_index), ' with delay ', num2str(d_index)])
            end
        end 
    end
    
    disp(['flight ', num2str(f), ' route ', num2str(r_index), ' ---------------------------- END'])
end


end




function add_ObjFunction()

global x_matrix
global w_matrix
global n_decision_vars
global lp

K_f = ones(size(x_matrix,1)); % 2 * ones(size(x_matrix,1)); to get [2;2;2;2...]
C_r = ones(size(x_matrix,3));
C_d = ones(size(x_matrix,2));

for f_index = 1:size(x_matrix,1)
    for d_index = 1:size(x_matrix,2)
        for r_index = 1:size(x_matrix,3)
            s_index =  max(f_index,r_index); % ?????
            x_matrix(f_index,d_index,r_index,s_index) = K_f(f_index) * (C_r(r_index) + C_d(d_index)) ;
        end
    end
end

xw_serialized = X_serializer(x_matrix,w_matrix);
disp (size (xw_serialized))
mxlpsolve('set_obj_fn', lp, xw_serialized);


end

% node occupancy
function add_NO_constraints()


t_min = 1;
t_max = 10;
global apt_links
global apt_nodes
global actual_routes
global x_matrix
global w_matrix
global n_decision_vars
global lp

for t = t_min:t_max
    for n = 1:size(apt_nodes,2)
     
        x_matrix(:,:,:,:) = 0; % reset values. do not reshape/resize
        flights_on_the_node = 0; %
        
        for s_index = 1:size(x_matrix,4)

            %disp(['t,n,s is ',num2str(t), ',', num2str(n) ,',', num2str(s_index)])
            
            node_found = false;
            if (apt_links(s_index,1) == n) % starting node
                %disp( ['found starting node ', num2str(n), ' in link ', num2str(s_index), ' (node ', num2str(links(s_index,1)), ' to ' , num2str(links(s_index,2)), ')' ])
                node_found = true;
%           elseif (links(s_index,2) == n) % ending node
%                disp( ['found ending node ', num2str(n), ' in link ', num2str(s_index), ' (node ', num2str(links(s_index,1)), ' to ' , num2str(links(s_index,2)), ')' ])
%                node_found = true;
            end
                        
            if (node_found)
                for f_index = 1:size(x_matrix,1)
                    for d_index = 1:size(x_matrix,2)
                        for r_index = 1:size(x_matrix,3)

                            %disp(['t,n is ',num2str(t), ',', num2str(n) ,' - f,d,r,s is ' , num2str(f_index), ',', num2str(d_index), ',',num2str(r_index), ',',num2str(s_index)])

                            if (actual_routes(f_index,r_index,t) == s_index)

                                disp(['at time ', num2str(t), ' flight ', num2str(f_index), ' in route ', num2str(r_index) ' occupies node ',num2str(n), ' in segment ',num2str(s_index)])
                                x_matrix(f_index,d_index,r_index,s_index) = true;
                                flights_on_the_node = flights_on_the_node +1;
                            end
                        end
                    end
                end
            end
        end

        
        if (flights_on_the_node == 1)
            %disp (['at time ', num2str(t), ' there is 1 flight on node ', num2str(n), ', no constraint needed'])
        elseif (flights_on_the_node > 1)
            disp (['at time ', num2str(t), ' there are ', num2str(flights_on_the_node), ' flights on node ', num2str(n), ', adding constraint on node occupancy'])

            
            x_matrix_serialized = zeros(1, n_decision_vars);
            x_matrix_serialized = X_serializer(x_matrix,w_matrix);
            mxlpsolve('add_constraint', lp, x_matrix_serialized, 1, 1); % le, ge, eq = 1,2,3            
            disp([x_matrix_serialized])
            
        end 
    end
end

end


function add_LO_constraints(lp_ptr, airport)


% get inspiration from NO constraint function


end

function add_RDC_constraints(lp)

    % route and delay choice
    for f_index = 1:f_max
        for s_index = 1:s_max
            x_matrix = zeros(f_max, d_max, r_max, s_max);

            for r_index = 1:r_max
                for d_index = 1:d_max
                    x_matrix(f_index,d_index,r_index,s_index) = 1; % flag activated - decision variable is included now
                end
            end

            x_matrix_serialized = zeros(1,n_decision_vars);
            x_matrix_serialized = X_serializer(x_matrix);
            mxlpsolve('add_constraint', lp, x_matrix_serialized, 3, 1); 
        end
    end

end

function add_WT_constraints()

for f_index = 1:size(x_matrix,1)
    for r_index = 1:size(x_matrix,3)
        for s_index = 1:size(x_matrix,4)
            
            
            
            %for d_index = 1:size(x_matrix,2)
            
                


            %end
        end
    end
end


end



function y = X_deserializer(x,z)

d5 = 1;
for d1 = 1:size(z,1)
    for d2 = 1:size(z,2)
        for d3 = 1:size(z,3)
            for d4 = 1:size(z,4)
    y(d1,d2,d3,d4) = x(d5);
    d5 = d5 + 1;
            end
        end
    end
end

% disp 'deserializer'
% disp (d5)
end

function y = X_serializer(x,w)

d5 = 1;
appo = [];

for d1 = 1:size(x,1)
    for d2 = 1:size(x,2)
        for d3 = 1:size(x,3)
            for d4 = 1:size(x,4)
    appo(d5) =  x(d1,d2,d3,d4);
    d5 = d5 + 1;
            end
        end
     end
end

for d1 = 1:size(w,1)
    for d2 = 1:size(w,2)
        for d3 = 1:size(w,3)
            for d4 = 1:size(w,4)
    appo(d5) =  w(d1,d2,d3,d4);
    d5 = d5 + 1;
            end
        end
    end
end

% disp 'serializer'
%disp (d5)
y = appo;
end


