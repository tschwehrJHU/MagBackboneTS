clear; 
close all; 
clc;

joy = vrjoystick(1); % initialize joystick
% 
while(1)
joy_data = read(joy);
% 
lh = joy_data(1);
lv = joy_data(2);
rtlt = joy_data(3);
rh = joy_data(4);
rv = joy_data(5);
% 
a = button(joy, 1);
b = button(joy, 2);
x = button(joy, 3); 
y = button(joy, 4); 
lb = button(joy, 5); 
rb = button(joy, 6); 
start = button(joy, 7); 
select = button(joy, 8); 
l3 = button(joy, 9); 
r3 = button(joy, 10); 
t3 = button(joy, 15); 
t4 = button(joy, 16); 
t5 = button(joy, 13); 
t6 = button(joy, 14);
% 
% u = [lh lv bp rh rv ]
buttons = [ a b x y lb rb start rtlt ]
% buttons = [ l3 r3 t3 t4 t5 t6]
end

%%
tic
startTime = toc; 
pulsingPeriod = 0.5; 
pulsingFrequency = 1/pulsingPeriod; 
pulseForwardRatio = 0.765; 
% pulseForwardRatio = 0;
for i = 1:100
    currentTime = toc; 
    duration = startTime - currentTime; 
    remainingTime = mod(duration, pulsingPeriod); 
    
    lh = 0; 
    lv = -1; 
    rh = 0; 
    rv = 0; 
    
    rtlt = 1; 
    
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
% ylim([-0.1, 1])


%% Rotating magnetic field about an axis 
close all
% Starting with 2d case, rotate around y axis in xz plane

degChange = 5; % deg
curr_theta = 0; % deg
rotScale = 0.5; 

figure(1)
hold on 
xlim([-2, 2])
ylim([-2, 2])
figure(2)
hold on
for i = 1:360/degChange
    xComp = cosd(curr_theta);
    zComp = sind(curr_theta);
    curr_theta = curr_theta + degChange;
    figure(1)
    quiver(0, 0, xComp, zComp)
    xlabel('x')
    ylabel('z')
%     pause(0.25)
    xlim([-2, 2])
    ylim([-2, 2])
    north = 0; 
    south = 0; 
    top = rotScale*zComp;
    bottom = -rotScale*zComp; 
    east = rotScale*xComp; 
    west = -rotScale*xComp; 
    
%     figure(2)
%     plot(xComp, 'r*')
%     plot(zComp, 'b*')
%     
    xzCurrents(i,:) = [top, bottom, east, west];
end
    
figure
plot(xzCurrents(:,1), 'r')
hold on 
plot(xzCurrents(:,2), 'g')
plot(xzCurrents(:,3), 'b')
plot(xzCurrents(:,4), 'k')
legend('T', 'B', 'E', 'W')
    
%%

needleVec = [pi/2; pi/2; pi/2]; 
magVec = [-pi/2; pi/2; 0]; 
desiredTheta = 5*(pi/180); 

% Define twist skew symmetric matrix
wHat = [0, -needleVec(3), needleVec(2); 
        needleVec(3), 0, -needleVec(1);
        -needleVec(2), needleVec(1), 0];

% Take matrix exponential
expZeta = expm(wHat*desiredTheta); 

newVec = expZeta*magVec;

figure
quiver3(0, 0, 0, needleVec(1), needleVec(2), needleVec(3), 'r')
hold on
quiver3(0, 0, 0, magVec(1), magVec(2), magVec(3), 'b')
quiver3(0, 0, 0, newVec(1), newVec(2), newVec(3), 'g')
axis equal

[currentCoilComp, newMagVec] = findRotMagCurrents(needleVec, magVec, 5);

% (N,E,W,S,T,B)
figure
quiver3(0, 0, 0, needleVec(1), needleVec(2), needleVec(3), 'r')
hold on
quiver3(0, 0, 0, magVec(1), magVec(2), magVec(3), 'b')
quiver3(0, 0, 0, newMagVec(1), newMagVec(2), newMagVec(3), 'b')
quiver3(0, 0, 0, currentCoilComp(2), currentCoilComp(1), currentCoilComp(5), 'k')
quiver3(0, 0, 0, currentCoilComp(3), currentCoilComp(4), currentCoilComp(6), 'g')




    