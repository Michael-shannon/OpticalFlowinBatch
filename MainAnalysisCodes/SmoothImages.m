function SmoothImages(exportFolder, smoothParams, image)
%% Params
smoothSig = smoothParams.smoothSig;
smoothOneSidedNumSig = smoothParams.smoothOneSidedNumSig;
smoothPadSize = smoothParams.smoothPadSize;
smoothMeanFac = smoothParams.smoothMeanFac;
smoothSigFac = smoothParams.smoothSigFac;

%% Smooth Image
% Pad Image
smoothImage = padarray(image, smoothPadSize, smoothMeanFac*mean(image(:)));

% Filter
[xFil, yFil, zFil] = DecomposedGaussian3(smoothSig, smoothOneSidedNumSig);
smoothImage = imfilter(imfilter(imfilter(double(smoothImage), xFil), yFil), zFil);
smoothImage = smoothImage(...
    (smoothPadSize(1) + 1):(end - smoothPadSize(1)), ...
    (smoothPadSize(2) + 1):(end - smoothPadSize(2)), ...
    (smoothPadSize(3) + 1):(end - smoothPadSize(3)));

% %% Backgound subtract smoothImage
% % Pad Image
% smoothPadSize2 = smoothSigFac*smoothPadSize;
% smoothImage = padarray(smoothImage, smoothPadSize2, smoothMeanFac*mean(smoothImage(:)));
% 
% % Filter
% [xFil, yFil, zFil] = DecomposedGaussian3(smoothSigFac*smoothSig, smoothOneSidedNumSig);
% smoothImage = smoothImage - imfilter(imfilter(imfilter(smoothImage, xFil), yFil), zFil);
% smoothImage = smoothImage(...
%     (smoothPadSize2(1) + 1):(end - smoothPadSize2(1)), ...
%     (smoothPadSize2(2) + 1):(end - smoothPadSize2(2)), ...
%     (smoothPadSize2(3) + 1):(end - smoothPadSize2(3)));
% smoothImage(smoothImage(:) < 0) = 0;

%% Create Outputs
% Make files
SmoothedImages.smoothImage = smoothImage; 
SmoothedImages.smoothParams = smoothParams; 

% Save
save([exportFolder, 'SmoothedImages.mat'], 'SmoothedImages', '-v7.3'); 