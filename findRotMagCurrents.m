function [coilCurrentComp, newMagVec ] = findRotMagCurrents (needleVec, magVec, theta)
%findRotMagCurrents takes in the current orientation of the steerable
%hammer needle and the desired rotation amount and computes the necessary
%currents for all six coils 
%
% Inputs
% needleVec       - 3x1 vector with x, y, and z components of needle
%                   orientation
% magVec          - 3x1 vector with x, y, and z components of magnet
%                   orientation
% theta           - amount of rotation in degrees
%
% Outputs       
% coilCurrentComp - 6x1 vector with necessary coil current multipliers
%                   between -1 and 1 (N,E,W,S,T,B)

% Convert desired theta to radians 
theta = theta*(pi/180); 

% Define twist skew symmetric matrix
wHat = [0, -needleVec(3), needleVec(2); 
        needleVec(3), 0, -needleVec(1);
        -needleVec(2), needleVec(1), 0];

% Take matrix exponential
expZeta = expm(wHat*theta); 

% Multiply magnet vector by transformation 
newMagVec = expZeta*magVec; 

% Create output
north = newMagVec(2); 
south = -newMagVec(2);
east = newMagVec(1); 
west = -newMagVec(1); 
top = newMagVec(3); 
bottom = -newMagVec(3); 

coilCurrentComp = [north, east , west, south, top, bottom];

end

