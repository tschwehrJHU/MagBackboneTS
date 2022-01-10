clc
clear all
close all

handles.closedWindow = 0;
% -------------robot info ----------------------------
% (555,359) to (553,430) 71.0282 pixels ---->  9.78 mm 
% robot position: x is horizontal, y is vertical 
scalar = 9.78/71.0282; % 0.1377 mm/pixel
handles.joy = vrjoystick(1); % initialize joystick
handles.video = videoinput('gentl', 1, 'BGR8'); % intialize video
src = getselectedsource(handles.video);
src.AutoExposureLightingMode = 'Backlight';
src.BalanceWhiteAuto = 'Once';
%%Setup preview window
fig = figure('NumberTitle', 'off', 'MenuBar', 'none');
fig.Name = 'My Camera';
ax = axes(fig);
current_frame = getsnapshot(handles.video);
im = image(ax, zeros(size(current_frame), 'uint8'));
axis(ax, 'image');
axes(ax); hold on
handles.graphics.hMarker = ...
    scatter(-10, -10, 'filled', 'dy','Parent', ax);
handles.graphics.gMarker = ...
    scatter(-10, -10, 'p', 'dg','Parent', ax);

%%Start preview
preview(handles.video, im)
setappdata(fig, 'cam', handles.video);
% fig.CloseRequestFcn = @closePreviewWindow_Callback;

% set threshold for determine if the robot is at desired location 
threshold = 2; 
vel_threshold = 0.1; 

handles.arduino = serialport('COM3', 115200);%initialize arduino communication
% initialize control related parameters

% program settings
settings.saveon = 1;
settings.closedloop_control_on = 0;
settings.image_processing_on = 0;

settings.p_control = 1;
settings.i_control = 1;
settings.d_control = 1;

%locate the petri dish and make the center as 0
% [current_frame] = AcquireImage(handles.video);
[handles.data.petri_center,handles.data.petri_radius] = findPetri(current_frame);

% create the circle mask
ci = [handles.data.petri_center(1), handles.data.petri_center(2), handles.data.petri_radius];     % center and radius of circle ([c_row, c_col, r])
imageSize = size(current_frame);
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
handles.data.mask = uint8((xx.^2 + yy.^2)<ci(3)^2);

% initialize all the parameters 
handles.data.isLocWorking = 1;
handles.data.last_t = -0.2;  % chnage this to make delta_t consistent 
if (settings.image_processing_on)
    [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking] = LocalizationTopView(current_frame,handles.data.mask);
    % convert the image coordinate to the world coordinates
    handles.data.curr_x = scalar*(handles.data.image.curr_x - handles.data.petri_center(1));
    handles.data.curr_y = scalar*(handles.data.image.curr_y - handles.data.petri_center(2));
else
    handles.data.curr_x = 0; 
    handles.data.curr_y = 0;
    handles.data.image.curr_x = 0; 
    handles.data.image.curr_y = 0;
    handles.data.curr_theta = 0;
end

handles.data.xVel = 0;
handles.data.yVel = 0;
handles.data.thetaVel = 0;
handles.data.xAcc = 0;
handles.data.yAcc = 0;
handles.data.thetaAcc = 0;
handles.data.goalReached = 0;

% change target x and y for desired position 
handles.data.desired_x = 0;
handles.data.desired_y = 0;
handles.data.desired_theta = 0; 

% add previous position, velocity for calculating velocity and acceleration
% handles.data.prevXpos = handles.data.curr_x;
% handles.data.prevYpos = handles.data.curr_y;
% handles.data.prevXvel = handles.data.xVel;
% handles.data.prevYvel = handles.data.yVel;
handles.data.prevXpos = 0;
handles.data.prevYpos = 0;
handles.data.err_prev_x = 0;
handles.data.err_prev_y = 0;
handles.data.sum_err_x = 0; 
handles.data.sum_err_y = 0; 
handles.data.dt = 0.14;


% figure(1)
% hold on
experimentdata = zeros(1,12); % should be initialized with correct number of elements

all_s = {};

FS = stoploop({'Stop'});
%hFig = figure(2);
%imshow(current_frame);
hold on
% plot(handles.data.petri_center(1),handles.data.petri_center(2),'bo')
%roi = images.roi.Circle(gca,'Center',handles.data.petri_center,'Radius',handles.data.petri_radius);
handles.data.actual_desired_x = handles.data.desired_x / scalar + handles.data.petri_center(1);
handles.data.actual_desired_y = handles.data.desired_y / scalar + handles.data.petri_center(2);


ctr = 2;           
tic
hammer_bool = false; 
num = 1; 
cVec = zeros(1000, 1); 

%handles.closedWindow == 0
figure(5); 
hold on 
hammer_start_time = 0; 
while (~FS.Stop()&&~handles.data.goalReached)
   t_sim = toc;
   t_before = toc; 
%   [current_frame] = AcquireImage(handles.video);
%    current_frame = handles.hImage;
    current_frame = getimage(im);
   t_acquire = toc;
   if (settings.image_processing_on)
       [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking] = LocalizationTopView(current_frame,handles.data.mask);
   end
   t_processing  = toc;
   % convert the image coordinate to the world coordinates
   handles.data.curr_x = scalar*(handles.data.image.curr_x - handles.data.petri_center(1));
   handles.data.curr_y = scalar*(handles.data.image.curr_y - handles.data.petri_center(2));


   % find the current velocity
   handles.data.xVel = (handles.data.curr_x - handles.data.prevXpos)/(t_processing - handles.data.last_t);
   handles.data.yVel = (handles.data.curr_y - handles.data.prevYpos)/(t_processing - handles.data.last_t);

  
   if (settings.closedloop_control_on && handles.data.isLocWorking)
              
       if(~handles.data.goalReached)
           [u, handles.data] = FeedbackControl(handles.data,settings);
       end 
       
       if((abs(handles.data.desired_x - handles.data.curr_x)<=threshold) && (abs(handles.data.desired_y - handles.data.curr_y)<= threshold)...
               && (abs(handles.data.xVel)<=vel_threshold) && (abs(handles.data.yVel)<=vel_threshold))
           handles.data.goalReached = 1;
           disp('goal reached')
           FS.Stop();
       end 
     
       
        % store previous position, velocity 
        handles.data.prevXpos = handles.data.curr_x;
        handles.data.prevYpos = handles.data.curr_y;
        handles.data.prevXvel = handles.data.xVel;
        handles.data.prevYvel = handles.data.yVel;
        
   else % joystick controller on
       [u] = JoystickActuation(handles.joy)
       if (hammer_bool == false && abs(u(5)) > 0.5) % starting to hammer
           hammer_start_time = toc; 
           hammer_bool = true; 
       elseif (abs(u(5)) < 0.5)
           hammer_bool = false; 
       end 
   end
   curX = handles.data.curr_x;
   curY = handles.data.curr_y;
   
   current_time = toc
   coil_currents = MapInputtoCoilCurrents(u, settings, hammer_start_time, hammer_bool); 
   ArduinoCommunication(coil_currents, handles.arduino);
   figure(5)
   plot(current_time, coil_currents(1), 'r*')
   plot(current_time,coil_currents(2), 'g*')
   plot(current_time,coil_currents(3), 'b*')
   plot(current_time,coil_currents(4), 'k*')
   legend('N', 'E', 'W', 'S')
%    cVec(num) = coil_currents(1);
%    num = num+1;
   
   % frame visualization + any indicators can be added on
   %imshow (current_frame);
   hold on
   handles.graphics.gMarker.XData = handles.data.actual_desired_x;
   handles.graphics.gMarker.YData = handles.data.actual_desired_y;
   
%    plot(handles.data.desired_x,handles.data.desired_y,'r*')
   
   if(~handles.data.isLocWorking)
       disp("Localization not working")
%        FS.Stop();
   else
        c = [handles.data.image.curr_x, handles.data.image.curr_y];
%         plot(c(:,1),c(:,2),'r*')
        handles.graphics.hMarker.XData = handles.data.image.curr_x;
        handles.graphics.hMarker.YData = handles.data.image.curr_y;
   end 
   handles.data.prev_t = handles.data.last_t;
   % for data saving
   handles.data.last_t = toc;
    if(settings.closedloop_control_on)
       % time, north, east, west, south
       experimentdata = [experimentdata; handles.data.last_t coil_currents(1) coil_currents(2) coil_currents(3)...
           coil_currents(4) handles.data.curr_x handles.data.curr_y handles.data.err_xPos handles.data.err_yPos...
           handles.data.dt handles.data.error_diff_x handles.data.error_diff_y];
     
       handles.data.err_prev_x = handles.data.err_xPos;
       handles.data.err_prev_y = handles.data.err_yPos;
       handles.data.dt = handles.data.last_t - handles.data.prev_t;
   end
 %handles.data.err_x handles.data.err_y
%    if (isempty(all_frames))
%        all_frames = current_frame;
%    else
%        all_frames(:, :,:, end+1) = current_frame;
%    end   

   
end
if(settings.closedloop_control_on)
    % send 0 0 0 0 to arduino before closing everything 
    coil_currents = [0, 0, 0, 0];
    for i = 1:5 % loop five times to make sure all the coil currents are zero
        ArduinoCommunication(coil_currents, handles.arduino);
        experimentdata = [experimentdata; handles.data.last_t coil_currents(1) coil_currents(2) coil_currents(3)...
               coil_currents(4) handles.data.curr_x handles.data.curr_y handles.data.err_xPos handles.data.err_yPos ...
               handles.data.dt handles.data.error_diff_x handles.data.error_diff_y];
    end 
end 
if (settings.saveon)
    save('actuation_signals.mat', 'experimentdata') %this is coil signals and other necessary data
%     save('image_frames.mat', 'all_frames') % this is image frames 2D
end



%clear up variables
stoppreview(handles.video)
clear handles.video
clear handles.arduino
close all
% handles.closedWindow = 1;

% 
% %%Local functions
% function closePreviewWindow_Callback(obj, ~)
% handles.video = getappdata(obj, 'cam');
% closePreview(handles.video)
% delete(obj)
% %clear up variables
% stoppreview(handles.video)
% delete(handles.video)
% clear handles.video
% clear handles.arduino
% close all
% handles.closedWindow = 1;
% end


 %    % find the current acceleration 
%    handles.data.xAcc = (handles.data.xVel - handles.data.prevXvel)/(t_processing - handles.data.last_t);
%    handles.data.yAcc = (handles.data.yVel - handles.data.prevYvel)/(t_processing - handles.data.last_t);
%    


