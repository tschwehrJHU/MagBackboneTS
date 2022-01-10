function  [handle] = colorfilter(handle)
image = getsnapshot(handles.video); % read image

red_thr = 0.85;
red_area_size = 70;
blue_thr = 0.9;
blue_area_size = 70;

rgbaq = image;
rgbaq_normalized = bsxfun(@rdivide,im2double(rgbaq),sqrt(sum((im2double(rgbaq)).^2,3))); % find red parts

rgbaq_thresholded_red = (rgbaq_normalized(:,:,1)>red_thr).*rgbaq_normalized(:,:,1); % threshold them
BW2 = bwareaopen(rgbaq_thresholded_red,red_area_size); % reduce into closed area
red_region  = regionprops(BW2, 'centroid', 'Orientation', 'Area');

rgbaq_thresholded_blue = (rgbaq_normalized(:,:,3)>blue_thr).*rgbaq_normalized(:,:,3); % threshold them
BW3 = bwareaopen(rgbaq_thresholded_blue,blue_area_size); % reduce into closed area
blue_region  = regionprops(BW3, 'centroid', 'Orientation', 'Area');

if (length(red_region) >= 1 && length(blue_region)>=1)
    if (length(blue_region) > 1)    % if there are more than 1 blue region
        blue_region = blue_region([blue_region.Area] == max([blue_region.Area]));
        blue_region = blue_region(1);   % use the largest blue region
    end
    if (length(red_region) > 1)     % if there are more than 1 red region
        red_region = red_region([red_region.Area] == max([red_region.Area]));
        red_region = red_region(1);     % use the largest red region
        
    end
    
    % store all the centroids into handle
    handle.data.red_centriod = red_region.Centroid;
    handle.data.blue_centroid = blue_region.Centroid;
    center = (red_centriod + blue_centroid)/2;
    handle.data.current_x = center(1);
    handle.data.current_y = center(2);
    cent_dif = red_centriod - center;
    handle.data.orientation = atan2d(cent_dif(2), -cent_dif(1));
    
else
    handle.orientation = 0;
    handle.data.current_x = 0;
    handle.data.current_y = 0;
    handle.red_centriod = [0 0];
    handle.blue_centroid = [0 0];
    disp("Localization Failed")
end


end