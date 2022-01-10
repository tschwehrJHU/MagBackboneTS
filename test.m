close all
clear all
clc


% DlgH = figure;
% H = uicontrol('Style', 'PushButton', ...
%                     'String', 'Break', ...
%                     'Callback', 'delete(gcbf)');
v = videoinput('gentl', 1, 'BGR8');

image = getsnapshot(v);

hThresholds = [0.24, 0.44];
sThresholds = [0.8, 1.0];
vThresholds = [20, 125];

hsv = rgb2hsv(double(image));
hue=hsv(:,:,1);
sat=hsv(:,:,2);
val=hsv(:,:,3);

binaryH = hue >= hThresholds(1) & hue <= hThresholds(2);
	binaryS = sat >= sThresholds(1) & sat <= sThresholds(2);
	binaryV = val >= vThresholds(1) & val <= vThresholds(2);

% Overall color mask is the AND of all the masks.
	coloredMask = binaryH & binaryS & binaryV;
	% Filter out small blobs.
	coloredMask = bwareaopen(coloredMask, 500);
	% Fill holes
	coloredMask = imfill(coloredMask, 'holes');
    
    
    subplot(3, 1, 1);
	imshow(binaryH, []);
	axis on;
	title('Hue Mask');
	subplot(3, 1, 2);
	imshow(binaryS, []);
	axis on;
	title('Saturation Mask');
	subplot(3, 1, 3);
	imshow(binaryV, []);
	axis on;
	title('Value Mask');