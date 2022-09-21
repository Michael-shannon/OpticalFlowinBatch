%% Flow Distribution Data and Plots
function FlowDistributionData(fileParams, flowDistParams)
%% Make Flow Distribution Data
fprintf('\n\n- - - Starting FlowDistributionData - - -\n');

%% Figure Parameters
distOption = flowDistParams.distOption;
dataBinWidth = flowDistParams.dataBinWidth;
showBinWidth = flowDistParams.showBinWidth;

%% File Parameters
exportFolder = fileParams.exportFolder;
fileExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep];
histExportFolder = [fileExportFolder, ...
    filesep, 'HistogramData', ...
    filesep];

%% Create folder
if ~exist(histExportFolder, 'dir')
    mkdir(histExportFolder);
end

%% Full Image Distribution Data
if exist([histExportFolder, 'HistogramData.mat'], 'file')
    %% Load Full Image Distribution Data
    fprintf('Loading Full Image Distribution Data\n');
    load([histExportFolder, 'HistogramData.mat'], 'HistogramData');
else
    %% Calculate Full Image Distribution Data
    fprintf('Calculating Full Image Distribution Data\n');
    DistributionWholeImage(exportFolder, histExportFolder, fileParams, flowDistParams);
    load([histExportFolder, 'HistogramData.mat'], 'HistogramData');
end
%% Plot Full Image Distribution Data
fprintf('Plotting Full Image Distribution Data\n');
filePrefix = 'FullImage';
PlotDistributions(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, HistogramData, 1);
PlotDistributions(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, HistogramData, 2);

%% Load Variables
load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
numCells = length(FigureAParams.Masks);

%% Individual Cell Distribution Data
for cellNum = 1:numCells
    %% Define Filename
    histDataFilename = ['HistogramData_Cell', num2str(cellNum), 'of', num2str(numCells), '.mat'];  
    
    if exist([histExportFolder, histDataFilename], 'file')
        %% Load Individual Cell Distribution Data
        fprintf(['Loading Distribution Data for Cell ', num2str(cellNum), ' of ', num2str(numCells), '\n']);
        load([histExportFolder, histDataFilename], 'HistogramData');
    else        
        %% Load Files
        
        % Main Analysis Images
        load([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage');
        load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');
        
        %% Set Files
        
        % File Parameters
        thetaInDegrees = fileParams.thetaInDegrees;
        thetaInRadians = fileParams.thetaInRadians;
        
        % Flow Figure Params
        xIdx = FigureAParams.xIdx;
        yIdx = FigureAParams.yIdx;
        
        % Main Analysis Images
        diffIm = DifferenceImage.origDiffImage;
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
        
        %% Assign Region
        diffIm = diffIm(xIdx{cellNum}, yIdx{cellNum}, :);
        angMat = angMat(xIdx{cellNum}, yIdx{cellNum}, :);
        magMat = magMat(xIdx{cellNum}, yIdx{cellNum}, :);
        relMat = relMat(xIdx{cellNum}, yIdx{cellNum}, :);
        
        %% Calculate Individual Cell Distribution Data
        fprintf(['Calculating Distribution Data for Cell ', num2str(cellNum), ' of ', num2str(numCells), '\n']);
        DistributionSingleCell(histExportFolder, histDataFilename, relMat, diffIm, magMat, angMat, dataBinWidth, relThresh);
        load([histExportFolder, histDataFilename], 'HistogramData');      
    end
    %% Plot Individual Cell Distribution Data
    fprintf(['Plotting Cell ', num2str(cellNum), ' of ', num2str(numCells), ' Distribution Data\n']);
    filePrefix = ['Cell', num2str(cellNum), 'of', num2str(numCells)];
    PlotDistributions(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, HistogramData, 1);
    PlotDistributions(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, HistogramData, 2);
    
end