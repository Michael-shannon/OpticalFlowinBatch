function Image1and2_WholeImageWithFlow_and_WithFlowColoredByDirection(imageExportFolder, fileParams, flowFigureImageParams, imageA, vxMat, vyMat, relMat, numMicrons, imageNumber)
%% Check exist
if imageNumber == 1
    fileName = 'WholeImage_WithFlow.png';
elseif imageNumber == 2
    fileName = 'WholeImage_WithFlow_ColoredByDirection.png';
else
    error('imageNumber provided is not recognized');
end
    
%% Import parameters

% File Params
pxPerMicron = fileParams.pxPerMicron;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;

% Flow Figure Params
frameNum = flowFigureImageParams.frameNum;
intGamma = flowFigureImageParams.intGamma;
intThresh = flowFigureImageParams.intThresh;
relGamma = flowFigureImageParams.relGamma;
relThreshFac = flowFigureImageParams.relThreshFac;
magGamma = flowFigureImageParams.magGamma;
magThresh = flowFigureImageParams.magThresh;
flowSig = flowFigureImageParams.flowSig;
spacing = flowFigureImageParams.spacingA;
spacingFac = flowFigureImageParams.spacingFacA;
lineWidth = flowFigureImageParams.vecLineWidthA;
cmap = flowFigureImageParams.periodicxcmap2;

%% Create dispImage
dispImage = imageA(:, :, frameNum);
dispImage(dispImage(:) <= intThresh) = 0;
dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);

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

% Create masks
relMatMask = relMatShow > relThresh;
magMask = double(magMatShow > magThresh);

% Set up vector weights
relMatShow = RenormalizeImage(relMatShow);
vecWeight = magMask.*relMatMask.*(relMatShow.^relGamma).*(magMatShow.^magGamma);

% Create final vectors
[vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacing);
vxMatShow = vxMatShow*spacingFac.*vecWeight;
vyMatShow = vyMatShow*spacingFac.*vecWeight;
[vxMatShow, vyMatShow] = CutQuiverVectors(vxMatShow, vyMatShow);

%% Produce output
h = figure;
imshow(dispImage);
colormap gray
axis equal
axis off
hold on;
if imageNumber == 1
    quiver(vxMatShow, vyMatShow, 0, 'g', 'linewidth', lineWidth);
elseif imageNumber == 2
    ColorQuiver(vxMatShow, vyMatShow, cmap, lineWidth);
end
hold off;

%% Add scale bar
barSize = numMicrons*pxPerMicron;
AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);

%% Save output
origPos = get(gcf, 'Position');
set(gcf, 'Position', [1, 41, 1920, 964]);
drawnow; pause(2); drawnow;
f = getframe(gca);
f = frame2im(f);
imwrite(f, [imageExportFolder, fileName], 'png');
set(gcf, 'Position', origPos);
close(h);