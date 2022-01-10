function [ cd,red_cd,blue_cd, head_orientation ] = colorfilter_test(image)
%     image = getsnapshot(handles.video);
    
 
% % find blue region
% blue_binary = (uint16(image(:,:,3))./uint16((rgb2gray(image))));
% blue_binary = ~bwareaopen(blue_binary,500,4);   % remove large blue region
% blue_binary = bwareaopen(blue_binary,20,4);     % remove small blue region
% filled_blue = imfill(blue_binary, 'holes');     % fill holes
% blue_region  = regionprops(filled_blue, 'centroid', 'Area', 'Orientation');
% 
% % find red region
% red_binary = (uint16(image(:,:,1))./uint16((rgb2gray(image))));
% red_binary = ~bwareaopen(red_binary,500,4);     % remove large red region
% red_binary = bwareaopen(red_binary,20,4);       % remove small red region
% filled_red = imfill(red_binary, 'holes');       % fill holes
% red_region  = regionprops(filled_red, 'centroid', 'Area', 'Orientation');
red_thr = 0.85; 
red_area_size = 70;
blue_thr = 0.9; 
blue_area_size = 70;

% % find blue region
% blue_binary = (uint16(image(:,:,3))./uint16((rgb2gray(image))));
% blue_binary = ~bwareaopen(blue_binary,500,4);   % remove large blue region
% blue_binary = bwareaopen(blue_binary,20,4);     % remove small blue region
% filled_blue = imfill(blue_binary, 'holes');     % fill holes
% blue_region  = regionprops(filled_blue, 'centroid', 'Area', 'Orientation');
% 
% % find red region
% red_binary = (uint16(image(:,:,1))./uint16((rgb2gray(image))));
% red_binary = ~bwareaopen(red_binary,500,4);     % remove large red region
% red_binary = bwareaopen(red_binary,20,4);       % remove small red region
% filled_red = imfill(red_binary, 'holes');       % fill holes
% red_region  = regionprops(filled_red, 'centroid', 'Area', 'Orientation');
    
    rgbaq = image;
    rgbaq_normalized = bsxfun(@rdivide,im2double(rgbaq),sqrt(sum((im2double(rgbaq)).^2,3))); % find red parts 
    
    rgbaq_thresholded_red = (rgbaq_normalized(:,:,1)>red_thr).*rgbaq_normalized(:,:,1); % threshold them 
    BW2 = bwareaopen(rgbaq_thresholded_red,red_area_size); % reduce into closed area
    red_region  = regionprops(BW2, 'centroid', 'Orientation', 'Area');

    rgbaq_thresholded_blue = (rgbaq_normalized(:,:,3)>blue_thr).*rgbaq_normalized(:,:,3); % threshold them 
    BW3 = bwareaopen(rgbaq_thresholded_blue,blue_area_size); % reduce into closed area
    blue_region  = regionprops(BW3, 'centroid', 'Orientation', 'Area');
    
%     size = red_region.Area;
    
if (length(red_region) >= 1)
    if (length(red_region) > 1)
        red_region = red_region([red_region.Area] == max([red_region.Area]));
        red_region = red_region(1);% to fix occcasionally finding exactly the same area size for max red area
            
    end
    if (length(blue_region) > 1)
        blue_region = blue_region([blue_region.Area] == max([blue_region.Area]));
       blue_region = blue_region(1);% to fix occcasionally finding exactly the same area size for max red area  
    end
%     cd = (blue_region.Centroid*blue_region.Area + red_region.Centroid*red_region.Area)/ (red_region.Area + blue_region.Area);
    red_cd = red_region.Centroid;
    blue_cd = blue_region.Centroid;
    cd  = (red_cd + blue_cd)/2;
    cent_dif = red_cd - cd; 
    expected_orientation = atan2d(cent_dif(2), -cent_dif(1));
    head_orientation = expected_orientation;% this line added by Onder at 03082019


else
    head_orientation = 0;
    cd = [0 0];
    if (isempty(blue_region))
        display ('No Blue Region is detected for camera 2')
    end
    if (isempty(red_region))
        display ('No Red Region is detected for camera 2')
    end
end
    
    
end