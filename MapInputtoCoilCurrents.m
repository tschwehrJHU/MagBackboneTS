function [coil_currents] = MapInputtoCoilCurrents(u, settings, hammer_start_time, hammer_bool)


if (settings.closedloop_control_on)
    south = u(1);
    west = u(2);
    east = u(3);
    north = u(4); 
    
    coil_currents = [-south, -west, -east, -north 0];
    
else % Joystick control on
    lh = u(1);
    lv = u(2);
    rh = u(3);
    rv = u(4); 
    bp = u(5);
    
    pulsing_period = 0.15; %seconds
    pulsing_frequency = 1/pulsing_period;
    pulse_forward_ratio = 0.765; %should be something between 0 and 1
        
    if (hammer_bool)% Joystick control with hammer
        
        current_time = toc; 
        duration = hammer_start_time - current_time; 
        remaining_time = mod(duration, pulsing_period); 
        if remaining_time < pulse_forward_ratio*pulsing_period % forward hammering case
            scale = 1;
            north_c = (max(0.0, -lv) + min(0.0, rv))*scale;
            south_c = (max(0.0, lv) + min(0.0, -rv))*scale;
            west_c = (max(0.0, -lh) + min(0.0, rh))*scale;
            east_c = (max(0.0, lh) + min(0.0, -rh))*scale;
            
            coil_currents = [-north_c, -east_c, -west_c, -south_c];
        else
            scale = 1*((bp-1)/2);
            north_c = (max(0.0, lv) + min(0.0, -rv))*scale;
            south_c = (max(0.0, -lv) + min(0.0, rv))*scale;
            west_c = (max(0.0, lh) + min(0.0, -rh))*scale;
            east_c = (max(0.0, -lh) + min(0.0, rh))*scale;
        
           coil_currents = [-north_c, -east_c, -west_c, -south_c];
        end
        
    else
    % change this scale to modify the coil power
    scale = 1;
    south_c = (max(0.0, -lv) + min(0.0, rv))*scale;
    north_c = (max(0.0, lv) + min(0.0, -rv))*scale;
    east_c = (max(0.0, -lh) + min(0.0, rh))*scale;
    west_c = (max(0.0, lh) + min(0.0, -rh))*scale;
%     top_c = max(0.0, bp)*scale;
%     bottom_c = min(0.0, bp)*scale;
%     coil_currents = [-north_c, -east_c, -west_c, -south_c, -top_c, -bottom_c];
    coil_currents = [-north_c, -east_c, -west_c, -south_c];
    
    end
end

% use u to calculate coil_currents as 4x1 since we have 4 coils and
% return coil_currents

end
