function Image3_ColoredFlowImage(imageExportFolder, fileParams, flowFigureImageParams, vxMat, vyMat, relMat, numMicrons)
%% Check exist
fileName = 'WholeImage_WithColoredFlow.png';

%% Import parameters

% File Params
pxPerMicron = fileParams.pxPerMicron;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;

% Flow Figure Params
frameNum = flowFigureImageParams.frameNum;
relGamma = flowFigureImageParams.relGamma;
relThreshFac = flowFigureImageParams.relThreshFac;
magGamma = flowFigureImageParams.magGamma;
magThresh = flowFigureImageParams.magThresh;
flowSig = flowFigureImageParams.flowSig;
cmap = flowFigureImageParams.periodicxcmap1;

%% Define flow vectors

% Define vectors
vxMatShow = vxMat(:, :, frameNum);
vyMatShow = vyMat(:, :, frameNum);
relMatShow = relMat(:, :, frameNum);
relThresh = relThreshFac*prctile(relMat(:), 99);

% Rotate vectors
[vxMatShow, vyMatShow] = RotateQuiver(vxMatShow, vyMatShow, thetaInDegrees, thetaInRadians);
relMatShow = imrotate(relMatShow, thetaInDegrees);

% Smooth vectors
vxMatShow = imfilter(vxMatShow, fspecial('gaussian', 6*flowSig + 1, flowSig));
vyMatShow = imfilter(vyMatShow, fspecial('gaussian', 6*flowSig + 1, flowSig));
relMatShow = imfilter(relMatShow, fspecial('gaussian', 6*flowSig + 1, flowSig));
magMatShow = sqrt(vxMatShow.^2 + vyMatShow.^2);
thetaMatShow = round(255*RenormalizeImage(atan2(-vyMatShow, vxMatShow)));

% Create masks
relMatMask = relMatShow > relThresh;
magMask = double(magMatShow > magThresh);

% Set up vector weights
relMatShow = RenormalizeImage(relMatShow);
vecWeight = magMask.*relMatMask.*(relMatShow.^relGamma).*(magMatShow.^(1 + magGamma));
vecWeight(vecWeight == 0) = nan; 
vecWeight = RenormalizeImage(vecWeight); 
vecWeight(isnan(vecWeight(:))) = 0;

%% Define channel images
c1Image = nan(size(thetaMatShow));
c2Image = nan(size(thetaMatShow));
c3Image = nan(size(thetaMatShow));

%% Fill images
for i = 0:255
    c1Image(thetaMatShow(:) == i) = 1 - cmap(i + 1, 1);
    c2Image(thetaMatShow(:) == i) = 1 - cmap(i + 1, 2);
    c3Image(thetaMatShow(:) == i) = 1 - cmap(i + 1, 3);
end
c1Image(magMatShow == 0) = 0;
c2Image(magMatShow == 0) = 0;
c3Image(magMatShow == 0) = 0;

%% Apply weights
c1Image = c1Image.*vecWeight;
c2Image = c2Image.*vecWeight;
c3Image = c3Image.*vecWeight;

%% Create final image
dispImage = 1 - cat(3, c1Image, c2Image, c3Image);

%% Produce output
h = figure;
imshow(dispImage);
axis equal
axis off

%% Add scale bar
barSize = numMicrons*pxPerMicron;
AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);

%% Save output
origPos = get(gcf, 'Position');
set(gcf, 'Position', [1, 41, 1920, 964]);
f = getframe(gca);
f = frame2im(f);
imwrite(f, [imageExportFolder, fileName], 'png');
set(gcf, 'Position', origPos);
close(h);