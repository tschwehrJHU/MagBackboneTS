close all 
clear all 
clc 

% create a figure 
DlgH = figure;
set(gcf,'Position',[100 100 1000 800])
H = uicontrol('Style', 'PushButton', ...
                    'String', 'Break', ...
                    'Callback', 'delete(gcbf)');
                
                
save_var = uibuttongroup('Visible','off',...
              'Position',[0 0 200 200],...
              'SelectionChangedFcn',@bselection);
              
% Create three radio buttons in the button group.
r1 = uicontrol(save_var,'Style',...
                  'radiobutton',...
                  'String','save on',...
                  'Position',[10 600 100 30],...
                  'HandleVisibility','off');
              
r2 = uicontrol(save_var,'Style','radiobutton',...
                  'String','save off',...
                  'Position',[10 650 100 30],...
                  'HandleVisibility','off');
              
% Make the uibuttongroup visible after creating child objects. 
save_var.Visible = 'on';

while (ishandle(H))

    
    pause(0.01)
end


