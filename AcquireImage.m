function [frame] = AcquireImage(vid_handle)
    frame = getsnapshot(vid_handle);
% frame = vid_handle.snapshot;
%     frame = uint16(rgb2gray(frame));
    
% vid = videoinput('gentl', 1, 'BGR8');
% vid.FramesPerTrigger = 1;
% 
% preview(vid);
%  
% stoppreview(vid);
end