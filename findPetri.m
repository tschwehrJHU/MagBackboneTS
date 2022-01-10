function [petri_center,petri_radius] = findPetri(current_frame)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    image = current_frame; 
    image_white = im2bw(image,0.45);
    [centers,radii] = imfindcircles(image_white,[300 500],'ObjectPolarity','bright', ...
    'Sensitivity',0.99);
    k_max =  (radii == max(radii));
    petri_center = centers(k_max,:);
    petri_radius = radii(k_max);


end

