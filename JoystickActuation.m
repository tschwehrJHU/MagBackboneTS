function [u] = JoystickActuation(joy)

    joy_data = read(joy);
 
    lh = joy_data(1);
    lv = joy_data(2);
    bp = joy_data(3);
    rh = joy_data(4);
    rv = joy_data(5);
    
    u = [lh lv rh rv bp];
%     u = [lh lv rh rv];
end
