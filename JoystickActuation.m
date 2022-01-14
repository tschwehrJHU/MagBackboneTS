function [u] = JoystickActuation(joy)

    joy_data = read(joy);
 
    lh = joy_data(1);
    lv = joy_data(2);
    rtlt = joy_data(3);
    rh = joy_data(4);
    rv = joy_data(5);
    
    lb = button(joy, 5);
    rb = button(joy, 6);
    
    u = [lh lv rh rv rtlt rb lb];
%     u = [lh lv rh rv];
end
