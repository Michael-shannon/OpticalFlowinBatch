%% Main Flow Tracking Analysis Script
%  The goal of this analysis is to track actin dynamics in actin
%  fluorescence movies using Optical Flow and Crocker-Grier Least-Squares
%  Minimization Particle Tracking.
function MainAnalysisScript_GuvenPaperModified(fileParameters, mainAnalysisParams)
%% Start MainAnalysisScript
fprintf('\n- - - Starting MainAnalysisScript - - -\n\n')

%% File Parameters

% Load Parameters
fileName = fileParameters.fileName;
importFolder = fileParameters.importFolder;
exportFolder = fileParameters.exportFolder;
pxPerMicron = fileParameters.pxPerMicron;
secBtwFrames = fileParameters.secBtwFrames;

% Create Export Folder
if ~exist(exportFolder, 'dir')
    mkdir(exportFolder);
end

% Save Parameters
save([exportFolder, 'FileParameters.mat'], 'fileParameters');

%% Main Analysis Parameters
smoothSig = mainAnalysisParams.smoothSig;
wSig = mainAnalysisParams.wSig;
minR = mainAnalysisParams.minR;
maxR = mainAnalysisParams.maxR;
clusterRad = mainAnalysisParams.clusterRad;
peakSize = mainAnalysisParams.peakSize;
trackMaxDisp = mainAnalysisParams.trackMaxDisp;
minTrackLength = mainAnalysisParams.minTrackLength;

%% Static Analysis Parameters

% Smoothing Parameters
smoothOneSidedNumSig = 3;
smoothPadSize = ceil(smoothSig.*smoothOneSidedNumSig);
smoothMeanFac = 1;
smoothSigFac = 10;

% Difference Image Parameters
corrThresh = 0.9;

% Optical Flow Calculation
relThresh = 0;

% Optical Flow Enhancement Parameters
enhSig = [2, 2, .5];
enhNumSig = 3;
enhBgSubSig = [20, 20, 5];

% Flow Tracking Parameters
sz = ceil(6*clusterRad + 1) + mod(ceil(6*clusterRad + 1) + 1, 2);
clusterFil = fspecial('gaussian', sz, clusterRad); clusterFil((sz + 1)/2, (sz + 1)/2) = 0; clusterFil = clusterFil/sum(clusterFil(:));
peakThresh = 1e-4;

%% Import Images
if exist([exportFolder, 'OriginalImage.mat'], 'file')
    fprintf('- Original Image Located\n');
else
    fprintf('- Importing Original Image\n');
%     ImportImage(importFolder, exportFolder, fileName);
    ImportImage_GuvenPaperModified(importFolder, exportFolder, fileName);
end

%% Smooth Original Images
if exist([exportFolder, 'SmoothedImages.mat'], 'file')
    fprintf('- Smoothed Image Located\n');
else
    % Load Dependencies
    fprintf('- Loading Original Image for Smoothing\n');
    load([exportFolder, 'OriginalImage.mat'], 'OriginalImage');
    origImage = OriginalImage.Image(:, :, :, OriginalImage.ActinChannel);
    % Perform Smoothing
    fprintf('  Creating Smoothed Image\n');
    smoothParams.smoothSig = smoothSig;
    smoothParams.smoothOneSidedNumSig = smoothOneSidedNumSig;
    smoothParams.smoothPadSize = smoothPadSize;
    smoothParams.smoothMeanFac = smoothMeanFac;
    smoothParams.smoothSigFac = smoothSigFac;
    SmoothImages(exportFolder, smoothParams, origImage);
end

%% Calculate Optical Flow
if exist([exportFolder, 'OpticalFlow.mat'], 'file')
    fprintf('- Optical Flow Images Located\n');
else
    % Load Dependencies
    fprintf('- Loading Smoothed Image for Optical Flow Calculations\n');
    load([exportFolder, 'SmoothedImages.mat'], 'SmoothedImages');
    smoothImage = SmoothedImages.smoothImage;
    % Calculate Optical Flow
    fprintf('  Calculating Optical Flow\n');
    optFlowParams.WindowSigma = wSig;
    optFlowParams.ReliabilityThreshold = relThresh;
    CalculateOpticalFlow(exportFolder, optFlowParams, smoothImage);
end

%% Calculate Difference Image
if exist([exportFolder, 'DifferenceImage.mat'], 'file')
    fprintf('- Difference Image Located\n');
else
    % Load dependencies
    if ~exist('origImage', 'var')
        fprintf('- Loading Original Image for Difference Image Calculation\n');
        load([exportFolder, 'OriginalImage.mat'], 'OriginalImage');
        origImage = squeeze(OriginalImage.Image(:, :, :, OriginalImage.ActinChannel));
    end
    if ~exist('smoothImage', 'var')
        fprintf('  Loading Smoothed Image for Difference Image Calculation\n');
        load([exportFolder, 'SmoothedImages.mat'], 'SmoothedImages');
        smoothImage = SmoothedImages.smoothImage;
    end   
    % Create Difference Image
    fprintf('  Creating Difference Image\n');
    diffImageParams.corrThresh = corrThresh;
    CalculateDifferenceImage(exportFolder, diffImageParams, origImage, smoothImage);
end

%% Enhance Optical Flow
if exist([exportFolder, 'EnhancedImage.mat'], 'file')
    fprintf('- Enhanced Optical Flow Image Located\n'); 
else
    % Load Dependencies
    fprintf('- Loading Difference Image for Optical Flow Image Enhancement\n');
    load([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage');
    smoothDiffImage = DifferenceImage.smoothDiffImage;
    fprintf('  Loading Optical Flow Images for Optical Flow Image Enhancement\n');
    load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');
    relMat = OpticalFlow.relMat;   
    % Enhance Optical Flow Images
    fprintf('  Enhancing Images\n');
    enhOptFlowParams.minR = minR;
    enhOptFlowParams.maxR = maxR;
    enhOptFlowParams.enhSig = enhSig;
    enhOptFlowParams.enhNumSig = enhNumSig;
    enhOptFlowParams.enhBgSubSig = enhBgSubSig;
    EnhanceOpticalFlow(exportFolder, enhOptFlowParams, relMat, smoothDiffImage);
end

%% Track Flow Clusters
if exist([exportFolder, 'FlowClusterTracks.mat'], 'file')
    fprintf('- Flow Cluster Tracks Located\n');
else
    if ~exist('smoothDiffImage', 'var')
        fprintf('- Loading Difference Image for Flow Cluster Tracking\n');
        load([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage');
        smoothDiffImage = DifferenceImage.smoothDiffImage;
        str = ' ';
    else
        str = '-';
    end   
    if ~exist('OpticalFlow', 'var')
        fprintf([str, ' Loading Optical Flow Images for Flow Cluster Tracking\n']);
        load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');
        str = ' ';
    else
        str = '-';
    end   
    fprintf([str, ' Loading Enhanced Optical Flow Images for Flow Cluster Tracking\n']);
    load([exportFolder, 'EnhancedImage.mat'], 'EnhancedImage');
    smoothEnhRelMat = EnhancedImage.SmoothEnhancedRelMat;
    fprintf('  Tracking Flow Clusters\n');
    clusterTrackParams.pxPerMicron = pxPerMicron;
    clusterTrackParams.minBtwFrames = secBtwFrames/60;
    clusterTrackParams.clusterRad = clusterRad;
    clusterTrackParams.clusterFil = clusterFil;
    clusterTrackParams.peakThresh = peakThresh;
    clusterTrackParams.peakSize = peakSize;
    clusterTrackParams.trackMaxDisp = trackMaxDisp;
    clusterTrackParams.trackMinLength = minTrackLength;
    TrackFlowClusters(exportFolder, clusterTrackParams, smoothDiffImage, smoothEnhRelMat, OpticalFlow);
end