function [x, y, theta,isLocWorking] = LocalizationTopView(current_frame,mask)
% filter the first color to locate the head
% this is arcieved with colorfilter.m

red_thr = 0.85; 
red_area_size = 70;
blue_thr = 0.85; 
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


% I = current_frame;
% [nx,ny,d] = size(I) ;
% [X,Y] = meshgrid(1:ny,1:nx);
% hold on
% r = petri_radius ;
% th = linspace(0,2*pi) ;
% xc = petri_center(1)+r*cos(th) ;
% yc = petri_center(2)+r*sin(th) ;
% plot(xc,yc,'r') ;
% % Keep only points lying inside circle
% idx = inpolygon(X(:),Y(:),xc',yc) ;
% for i = 1:d
% I1 = I(:,:,i) ;
% I1(~idx) = 255 ;
% I(:,:,i) = I1 ;
% end

%     I = current_frame;
%     croppedImage = uint8(zeros(size(I)));
%     croppedImage(:,:,1) = I(:,:,1).*mask;
%     croppedImage(:,:,2) = I(:,:,2).*mask;
%     croppedImage(:,:,3) = I(:,:,3).*mask;
%     rgbaq = croppedImage;

    rgbaq = current_frame; % read image
    rgbaq_normalized = bsxfun(@rdivide,im2double(rgbaq),sqrt(sum((im2double(rgbaq)).^2,3))); % find red parts 
    
    rgbaq_thresholded_red = (rgbaq_normalized(:,:,1)>red_thr).*rgbaq_normalized(:,:,1); % threshold them 
    BW2 = bwareaopen(rgbaq_thresholded_red,red_area_size); % reduce into closed area
    red_region  = regionprops(BW2, 'centroid', 'Orientation', 'Area');

    rgbaq_thresholded_blue = (rgbaq_normalized(:,:,3)>blue_thr).*rgbaq_normalized(:,:,3); % threshold them 
    BW3 = bwareaopen(rgbaq_thresholded_blue,blue_area_size); % reduce into closed area
    blue_region  = regionprops(BW3, 'centroid', 'Orientation', 'Area');


if (length(red_region) >= 1)
    if (length(red_region) > 1)
        
        red_region = red_region([red_region.Area] == max([red_region.Area]));
        
%         red_region = red_region(1);% to fix occcasionally finding exactly the same area size for max red area
            
    end
    if (length(blue_region) > 1)
        blue_region = blue_region([blue_region.Area] == max([blue_region.Area]));
%        blue_region = blue_region(1);% to fix occcasionally finding exactly the same area size for max red area  
    end

   
    
    % store all the centroids into handle
    if (numel(red_region) == 0)
        red_centroid = [0 0];
    else
        red_centroid = red_region.Centroid;
    end
    
    if (numel(blue_region) == 0)
        blue_centroid = [0 0];
    else
        blue_centroid = blue_region.Centroid;
    end
    
    center = (red_centroid + blue_centroid)/2;
    x = center(1);
    y = center(2);
    center_dif = red_centroid - center;
    theta = atan2d(center_dif(2), -center_dif(1));
    
    isLocWorking = 1;
else
    x = 0;
    y = 0;
    theta = 0;
    disp("Localization Failed")
    isLocWorking = 0;
end

% scalar = 94/800; % mm / pixel
% % rotate the coordinate system to the current system
% x_real = (y - petri_center(2))* scalar;
% y_real = (-x + petri_center(1))*scalar;
% theta_real = theta - pi/2;


end



