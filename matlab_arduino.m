clear all 
close all 
clc 


% Open a serial object
joy = vrjoystick(1); % initialize joystick 
s = serialport('COM5', 115200);
vid = videoinput('gentl', 1, 'BGR8'); % intialize video

FS = stoploop({'Stop'});

hFig = figure(2);
% create a figure 
% DlgH = figure;
% set(gcf,'Position',[100 100 1000 800])
% H = uicontrol('Style', 'PushButton', ...
%                     'String', 'Break', ...
%                     'Callback', 'delete(gcbf)');
                
                
% bg = uibuttongroup('Visible','off',...
%               'Position',[0 0 200 200],...
%               'SelectionChangedFcn',@bselection);
%               
% % Create three radio buttons in the button group.
% r1 = uicontrol(bg,'Style',...
%                   'radiobutton',...
%                   'String','save on',...
%                   'Position',[10 600 100 30],...
%                   'HandleVisibility','off');
%               
% r2 = uicontrol(bg,'Style','radiobutton',...
%                   'String','save off',...
%                   'Position',[10 650 100 30],...
%                   'HandleVisibility','off');
%               
% % Make the uibuttongroup visible after creating child objects. 
% bg.Visible = 'on';


                
% while (ishandle(H))
tic
while (~FS.Stop())
    t_sim = toc;
    frame = getsnapshot(vid);
    imshow(frame);
    hold off
    [axes, buttons, povs] = read(joy);
    lh = axes(1);
    lv = axes(2);
    rh = axes(4);
    rv = axes(5);
    
    
    scale = 1;
    south_c = (max(0.0, -lv) + min(0.0, rv))*scale;
    north_c = (max(0.0, lv) + min(0.0, -rv))*scale;
    east_c = (max(0.0, -lh) + min(0.0, rh))*scale;
    west_c = (max(0.0, lh) + min(0.0, -rh))*scale;

    data_float = [-north_c, -east_c, -west_c, -south_c];
    write(s,data_float,"single")
    
   
end

close all
clear s














% 
% packData(int8([-127 127]),'int8',2);
% 
% 
% while
% 
%    
% 
%     # transform the stick inputs
%     lh = tf(j.get_axis(0))
%     lv = tf(j.get_axis(1))
%     rh = tf(j.get_axis(3))
%     rv = tf(j.get_axis(4))
% 
%     # transform between sticks and the coils
%     scale=1
%     south_c = (max(0.0, -lv) + min(0.0, rv))*scale
%     north_c = (max(0.0, lv) + min(0.0, -rv))*scale
%     east_c = (max(0.0, -lh) + min(0.0, rh))*scale
%     west_c = (max(0.0, lh) + min(0.0, -rh))*scale
%     s.write(struct.pack("ffff", -north_c, -east_c, -west_c, -south_c))
%     print(("north: {: .4f} south: {: .4f}"
%           + " east: {: .4f} west: {: .4f}").format(north_c, south_c,
%                                                   east_c, west_c),
%           end="\r")
% 
%     time.sleep(.05)




