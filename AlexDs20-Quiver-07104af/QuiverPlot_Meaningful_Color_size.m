clear all
%% Load Optical Flow Outputs

load('OpticalFlow.mat')
load('OriginalImage.mat')
load('DifferenceImage.mat')

%%
rel = OpticalFlow.relMat;
im = OriginalImage.Image;
% reliability threshold is defined
relVal = 0.012*max(rel(:)); 

% Reliability mask is defined
relMask = rel > relVal;
% folder to store frames
mkdir FlowMovie2;
cd 'C:\Users\Ivan\Documents\NanoPatterns\Optical Flow Analysis Results\1.8um ridges\Cell4\OptFlowResults\FlowMovie2'

%image with vectors showing direction
for i = 2:size(im,3)-1 % or length of your movie
    
    IndexM = relMask(:,:,i);
    vx = OpticalFlow.vxMat(:,:,i);
    vy = OpticalFlow.vyMat(:,:,i);
    mag = atan2(-vy, vx); %color code based on directionality
    %mag = sqrt(vx.*vx + vy.*vy); %color code based on magnitude
    currentMag = abs(mag(IndexM));
%     figure;histogram(mag)
    
    figure
    imshow(im(:, :, i),[])
%   imagesc(im(:, :, i)) 
%   colormap(gray)                                                                                                                  
    
% reduce randomly the number of arrows considered for the map
    rVals = randi([1 size(IndexM,1)*size(IndexM,2)],round(size(IndexM,1)*size(IndexM,2)*0.85),1 );
    IndexM(rVals)=0;
    vx(find(IndexM==0))=nan;
    vy(find(IndexM==0))=nan;    
    
    hold on; 
    q = quiver(vx, vy);    
    colormap(jet);
    %colorbar;
    % function that color code the arrows based on their magnitude
    SetQuiverColor(q,jet,'mags',mag,'range',[0 3]);
    % Function that control arrow size base don magnitude
    SetQuiverLength(q,mag,'HeadLength',0.1,'HeadAngle',90);
%     xlim([20 245])
%     ylim([10 330])
    Valname = sprintf('OptiFlow%d.tif',i);
    saveas(q, Valname,'tiff');    
end
