% This script aims to help with visualization of the flows

clc;
clear all;
%% Code lines for Optical Flow Post-processing
% Open the folder containing the optical flow outputs in MATLAB

load('OpticalFlow.mat')
load('OriginalImage.mat')
load('DifferenceImage.mat')
%%

mkdir Flows;

vx = OpticalFlow.vxMat;
vy = OpticalFlow.vyMat;

rel = OpticalFlow.relMat;

relVal = 0.055*max(rel(:)); % Originally Lenny tried 1e-3, but it varies across movies

% Reliability mask is generated
relMask = rel > relVal;
%%
v = VideoWriter('Flow.avi','Uncompressed AVI'); 
v.FrameRate = 10; %FPS fpr playback

open(v);
for i=1:1:OriginalImage.NumFrames-1
    f = figure;
    hold on;
    imagesc(OriginalImage.Image(:,:,i+1)); colormap(gray); % Plot the original image
     
    dx = 5; % For visibility, this parameter will plot every dx'th vector. dx = 5 has worked well for me
    
    x = 1:size(OriginalImage.Image(:,:,1),2);
    y = 1:size(OriginalImage.Image(:,:,1),1);
    q = quiver(x(1:dx:end),y(1:dx:end),vx(1:dx:end, 1:dx:end,i).*relMask(1:dx:end, 1:dx:end,i), ...
        vy(1:dx:end, 1:dx:end,i).*relMask(1:dx:end, 1:dx:end,i), 0);
    % Plot the optical flow vectors. We're only plotting every 5th vector
    % to make them more visible
    q.Color = 'yellow';
    q.LineWidth = 1;
    q.AutoScaleFactor = 10; % Scaling factor for the arrows. Increase if they aren't visible in the movie
    
    frame = getframe(gca);
    
    writeVideo(v, frame);
    
    close(f);
 
end
close(v);