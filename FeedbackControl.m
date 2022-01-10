function [u, data] = FeedbackControl(data,settings)
    % here the control algorithm (dipole model)
    % coil current order LTRD
    
    position_adjustment = 0; 
    
    % need to be tuned
    if (position_adjustment)
        kp = 0.05*0.05; 
        ki = 0.005*2;
        kd = 0.01*0.1;
    else
        kp = 0.05*0.1; 
        ki = 0.005*0.5;
        kd = 0.01*0.1;
    end 
     k_adjustment = 0.8*10^6;
    
    
    % error of position 
    data.err_xPos = data.desired_x - data.curr_x;
    data.err_yPos = data.desired_y - data.curr_y;
    %data.err_xPos = 0;
    %data.err_yPos = 0;
    
    % adding up the error 
    data.sum_err_x = data.sum_err_x + data.err_xPos; 
    data.sum_err_y = data.sum_err_y + data.err_yPos;
    
    % delta error
    data.error_diff_x = data.err_xPos - data.err_prev_x;
    data.error_diff_y = data.err_yPos - data.err_prev_y;
    
    % thresholding the integral current
    C_i = [data.sum_err_x data.sum_err_y]*data.dt*ki; %integral current 
    ci_threshold = 0.3; 
    if C_i(1) >= ci_threshold
        C_i(1) = ci_threshold;
    end 
    if C_i(2) >= ci_threshold
        C_i(2) = ci_threshold;
    end 
    
    F = settings.p_control*[data.err_xPos data.err_yPos]*kp ...
        + settings.i_control* C_i...
        + settings.d_control*[data.error_diff_x data.error_diff_y]/data.dt*kd;
    
    % define previous position 
    data.prevXpos = data.curr_x;
	data.prevYpos = data.curr_y;

    
    
    if(position_adjustment)
        % distance between the robot and each coil 
        d_north = data.curr_y + 60;
        d_south = -data.curr_y + 60;
        d_east = -data.curr_x + 60; 
        d_west = data.curr_x + 60; 
        
        south = (F(2)>0)*abs(F(2))*1/d_south^3*k_adjustment;
        north = (F(2)<=0)*abs(F(2))*1/d_north^3*k_adjustment; 
        east = (F(1)>0)*abs(F(1))*1/d_east^3*k_adjustment;
        west = (F(1)<=0)*abs(F(1))*1/d_west^3*k_adjustment;
    else
        south = (F(2)>0)*abs(F(2));
        north = (F(2)<=0)*abs(F(2)); 
        east = (F(1)>0)*abs(F(1));
        west = (F(1)<=0)*abs(F(1));
    end 
    
    u = [south west east north];
    
    % adjusting the currents based on the maximum current of power supply
    MAX_CURR = 1;
    curr_sum = norm(u);
    if curr_sum >MAX_CURR
        u = u/curr_sum*MAX_CURR;
    end 
    
%     for i=1:numel(u)
%          curr_sum = curr_sum + (u(i))^2;
% %        if (abs(u(i))> max_current)
% %            u(i) = max_current*sign(u(i));
% %        end
% %        if (abs(u(i))<threshold)
% %            u(i) = 0;
% %        end
%     end
    
end


%     data.err_theta = data.desired_theta - data.curr_theta;
    %T = data.error_thata * kp; %torque is currently not working
    
%     north = (F(2)>0)*abs(F(2));
%     east = (F(1)<=0)*abs(F(1));
%     west = (F(1)>0)*abs(F(1));
%     south = (F(2)<=0)*abs(F(2));


%     east = (F(1)<=0)*abs(F(1))+(T <=0)*abs(T);
%     west = (F(1)>0)*abs(F(1)) +(T > 0)*abs(T);
%     south = (F(2)>0)*abs(F(2)) +(T <=0)*abs(T);
%     north = (F(2)<=0)*abs(F(2))+(T > 0)*abs(T);


% find the current velocity (delta pos/dt) 
%     data.xVel = (data.curr_x - data.prevXpos)/data.dt;
%     data.yVel = (data.curr_y - data.prevYpos)/data.dt;