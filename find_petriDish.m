function [handle] = find_petriDish(handle)
%
%   Detailed explanation goes here
image = getsnapshot(vid_handle);
image_white = im2bw(image,0.45);
[centers,radii] = imfindcircles(image_white,[400 500],'ObjectPolarity','bright', ...
    'Sensitivity',0.99);
k_max =  (radii == max(radii));
handle.petri_center = centers(k_max,:);
handle.petri_radius = radii(k_max);
end

