% lpsolve example2 from the manual.
echo on
lpOrig=mxlpsolve('make_lp', 0, 4);
mxlpsolve('set_verbose', lpOrig, 3);
mxlpsolve('set_obj_fn', lpOrig, [1, 3, 6.24, 0.1]);
mxlpsolve('add_constraint', lpOrig, [0, 78.26, 0, 2.9], 2, 92.3);
mxlpsolve('add_constraint', lpOrig, [0.24, 0, 11.31, 0], 1, 14.8);
mxlpsolve('add_constraint', lpOrig, [12.68, 0, 0.08, 0.9], 2, 4);
mxlpsolve('set_lowbo', lpOrig, [28.6, 0, 0, 18]);
mxlpsolve('set_upbo', lpOrig, [Inf, Inf, Inf, 48.98]);
mxlpsolve('set_col_name', lpOrig, {'COLONE', 'COLTWO', 'COLTHREE', 'COLFOUR'});
mxlpsolve('set_row_name', lpOrig, {'THISROW', 'THATROW', 'LASTROW'});
mxlpsolve('write_lp', lpOrig, 'a.lpOrig');
mxlpsolve('get_mat', lpOrig)
mxlpsolve('solve', lpOrig)
mxlpsolve('get_objective', lpOrig)
mxlpsolve('get_variables', lpOrig)
mxlpsolve('get_constraints', lpOrig)
%mxlpsolve('delete_lpOrig', lpOrig);
echo off

n_flights = 2;
n_segment = 3;
n_route = 2;
n_delay = 2;
n_decision_vars = n_flights * n_delay * n_route * n_segment;

Xmat = zeroes(n_flights, n_segment, n_route, n_delay);
Xvector = [n_decision_vars];




n_decision_vars = n_flights * n_delay * n_route * n_segment;
dim_flight = n_delay * n_route * n_segment;
dim_delay = n_route * n_segment;
dim_route = n_segment;


lp = mxlpsolve('make_lp',0,n_decision_vars);
d_vars = mxlpsolve('get_variables', lp);

d_vars(10) = 1;

ara = 0;
flight = -1;
delay = -1;
route = -1;
segment = -1;

result = [1,1];
disp(result);

constraint = zeros(1,n_decision_vars);

for i_flight = 1:n_flights   
    %if ((flight ~= -1) && (i_flight ~= flight));continue; end % skip if not selected
    
    for i_delay = 1:n_delay
        %if ((delay ~= -1) && (i_delay ~= delay));continue; end % skip if not selected
        
        for i_route = 1:n_route
            %if ((route ~= -1) && (i_route ~= route));continue; end % skip if not selected
            
            for i_segment = 1:n_segment
                %if ((segment ~= -1) && (i_segment ~= segment));continue; end % skip if not selected
                
                % get active path for specific route
                if ((i_flight == flight) && (i_route == 1))
                    
                i = dim_flight * i_flight + dim_delay * i_delay + dim_route * i_route + i_segment;
                
                disp(i);
                result = [result ; d_vars(i) ];
                % ara = ara + 1;
                % disp (ara);
                
                
                end
                
            end
        end
    end
end

%disp (result);













