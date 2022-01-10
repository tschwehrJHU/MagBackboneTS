clear; 
close all; 
clc;

% joy = vrjoystick(1); % initialize joystick
% 
% while(1)
% joy_data = read(joy);
% 
% lh = joy_data(1);
% lv = joy_data(2);
% bp = joy_data(3);
% rh = joy_data(4);
% rv = joy_data(5);
% 
% a = button(joy, 1);
% b = button(joy, 2);
% x = button(joy, 3); 
% y = button(joy, 4); 
% lb = button(joy, 5); 
% rb = button(joy, 6); 
% start = button(joy, 7); 
% select = button(joy, 8); 
% 
% u = [lh lv bp rh rv ]
% % buttons = [ a b x y lb rb start rt ]
% end

tic
startTime = toc; 
pulsingPeriod = 0.15; 
pulsingFrequency = 1/pulsingPeriod; 
pulseForwardRatio = 0.765; 
for i = 1:100
    currentTime = toc; 
    duration = startTime - currentTime; 
    remainingTime = mod(duration, pulsingPeriod); 
    
    lh = 0; 
    lv = 0; 
    rh = 0.5; 
    rv = 0; 
    
    rtlt = 0.9961; 
    
    if remainingTime < pulseForwardRatio*pulsingPeriod
        scale = 1;
        north = (max(0.0, -lv) + min(0.0, rv))*scale;
        south = (max(0.0, lv) + min(0.0, -rv))*scale;
        west = (max(0.0, -lh) + min(0.0, rh))*scale;
        east = (max(0.0, lh) + min(0.0, -rh))*scale;
    else
        scale = 1*((rtlt-1)/2);
        north = (max(0.0, lv) + min(0.0, -rv))*scale;
        south = (max(0.0, -lv) + min(0.0, rv))*scale;
        west = (max(0.0, lh) + min(0.0, -rh))*scale;
        east = (max(0.0, -lh) + min(0.0, rh))*scale;
    end
    pause(0.05)
    coil_currents(i,:) = [-north, -east, -west, -south];
end

figure
plot(coil_currents(:,1), 'r')
hold on 
plot(coil_currents(:,2), 'g')
plot(coil_currents(:,3), 'b')
plot(coil_currents(:,4), 'k')
legend('N', 'E', 'W', 'S')


%%


    