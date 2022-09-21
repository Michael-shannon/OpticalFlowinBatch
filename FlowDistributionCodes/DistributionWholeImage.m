function DistributionWholeImage(exportFolder, fileExportFolder, fileParams, flowDistParams)
%% Import Parameters

% File Parameters
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;

% Figure Parameters
dataBinWidth = flowDistParams.dataBinWidth;

%% Load Files

% Main Analysis Images
load([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage');
load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');

%% Set Files

% Difference Image
diffIm = DifferenceImage.origDiffImage;

% Optical Flow Images
vxMat = OpticalFlow.vxMat;
vyMat = OpticalFlow.vyMat;
relMat = OpticalFlow.relMat;

%% Process Files

% Difference Image
diffIm = imrotate(diffIm, thetaInDegrees);

% Optical Flow Images
[vxMat, vyMat] = RotateQuiver(vxMat, vyMat, thetaInDegrees, thetaInRadians);
angMat = atan2(vyMat, vxMat);
magMat = sqrt(vxMat.^2 + vyMat.^2);

% Flow reliability
relMat = imrotate(relMat, thetaInDegrees);
relThresh = 0.01*max(relMat(:));

%% Calculate Histogram Data
DistributionSingleCell(fileExportFolder, 'HistogramData.mat', relMat, diffIm, magMat, angMat, dataBinWidth, relThresh);