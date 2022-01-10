clear all 
close all 
clc 


% Open a serial object
joy = vrjoystick(1); % initialize joystick 
s = serialport('COM7', 115200);


% create a figure 
DlgH = figure;
set(gcf,'Position',[100 100 1000 800])
H = uicontrol('Style', 'PushButton', ...
                    'String', 'Break', ...
                    'Callback', 'delete(gcbf)');
                
                      
while (ishandle(H))
    [axes, buttons, povs] = read(joy);
    lh = axes(1);
    lv = axes(2);
    rh = axes(4);
    rv = axes(5);
    
    
    scale = 1;
%     south_c = (max(0.0, -lv) + min(0.0, rv))*scale;
%     north_c = (max(0.0, lv) + min(0.0, -rv))*scale;
%     east_c = (max(0.0, -lh) + min(0.0, rh))*scale;
%     west_c = (max(0.0, lh) + min(0.0, -rh))*scale;
    south_c = (lv>0)*abs(lv);
    north_c = (lv<=0)*abs(lv); 
    east_c = (lh>0)*abs(lh);
    west_c = (lh<=0)*abs(lh);

%     data_float = [-south_c, -west_c, -east_c, -north_c];
    data_float = [ -1, -1, -0.0, -0.0];
    write(s,data_float,"single")
    
    pause(0.05);
end

clear s






