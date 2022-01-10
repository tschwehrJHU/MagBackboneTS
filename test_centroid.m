close all
clear all
clc


% DlgH = figure;
% H = uicontrol('Style', 'PushButton', ...
%                     'String', 'Break', ...
%                     'Callback', 'delete(gcbf)');


% v = videoinput('gentl', 1, 'BGR8');
% image = getsnapshot(v);

image  = imread('image.png');

% ROI = bwareafilt(image_white,1,'largest');

% threshold the image and find the circle 
image_white = im2bw(image,0.45);
[centers,radii] = imfindcircles(image_white,[300 500],'ObjectPolarity','bright', ...
    'Sensitivity',0.99);
k_max =  (radii == max(radii));
petri_center = centers(k_max,:);
petri_radius = radii(k_max);


% image_white = im2bw(image,0.22);imshow(image_white)
imshow(image)
hold on

roi = images.roi.Circle(gca,'Center',petri_center,'Radius',petri_radius);

% image_red = im2bw(image,0.25);
% 
% image_red = ~bwareaopen(image_red,100,4);
% image_red = bwareaopen(image_red,50,4);
% image_red = imfill(image_red, 'holes');
% red_region  = regionprops(image_red, 'centroid', 'Area');
% red = red_region(2);
% 
% figure(2)
% imshow(image_red)


% BW2_filled_blue = imfill(BW_connected, 'holes');
% blue_region  = regionprops(BW2_filled_blue, 'centroid', 'Area');


% BW_blue_density = (uint16(image(:,:,3))./uint16((rgb2gray(image))));
% BW_connected = ~bwareaopen(BW_blue_density,500,4);
% BW_connected = bwareaopen(BW_connected,20,4);
% BW2_filled_blue = imfill(BW_connected, 'holes');
% blue_region  = regionprops(BW2_filled_blue, 'centroid', 'Area');
% blue_centers = blue_region.Centroid;
% isblueinROI = inROI(roi,blue_centers(:,1),blue_centers(:,2));
% k = find(isblueinROI == 1);
% blue_region = blue_region(max(blue_region(k).Area));

% blue_region =  blue_region([blue_region.Area] == max([blue_region.Area]));
% blue_center = blue_region.Centroid;





% 
% isinROI = inROI(roi,centers(:,1),centers(:,2));
% k = find(isinROI == 1);
% centroids = blue_region.Centroid;



% viscircles(petri_center,petri_radius)
% plot(blue_center(:,1), blue_center(:,2),'r*')



% I = getsnapshot(v);
% % I = imread('img2.png');
% [c,rc,bc,orien] = colorfilter_test(I);
% % imshow(c)

% imshow(I)
% hold on
% % plot(rc(:,1),rc(:,2),'b*')
% % plot(bc(:,1),bc(:,2),'b*')
% plot(c(:,1),c(:,2),'b*')
% plot([rc(:,1), bc(:,1)],[rc(:,2),bc(:,2)])
% hold off


% clear all



% v = videoinput('gentl', 1, 'BGR8');
% frame = getsnapshot(v);
% I = imread('img2.png');
% [c,rc,bc,orien] = colorfilter_test(I);
% % imshow(c)
%
% imshow(I)
% hold on
% % plot(rc(:,1),rc(:,2),'b*')
% % plot(bc(:,1),bc(:,2),'b*')
% % plot(c(:,1),c(:,2),'b*')
% plot([rc(:,1), bc(:,1)],[rc(:,2),bc(:,2)])
% % hold off

