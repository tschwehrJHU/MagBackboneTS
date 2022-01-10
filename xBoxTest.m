clear all; 
clc;

handles.joy = vrjoystick(1); % initialize joystick

while(1)
joy_data = read(handles.joy);

lh = joy_data(1);
lv = joy_data(2);
bp = joy_data(3);
rh = joy_data(4);
rv = joy_data(5);
% t = get_axis(6); 


u = [lh lv bp rh rv]
end