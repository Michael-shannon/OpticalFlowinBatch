function DistributionSingleCellOverTime(histExportFolder, histDataFilename, relMat, diffIm, magMat, angMat, dataBinWidth, relThresh)
%% Calculate Histogram Data

% Set mainFlowMask
mainFlowMask = ...
    double(relMat > 0).* ... % Where the relMat is > 0
    double(diffIm > 0).* ...     % Where the diffIm is > 0
    double(magMat > 0) ...   % Where the magMat is > 0
    > 0;

numTimePoints = size(mainFlowMask, 3);
rawCountsTime = [];
threshCountsTime = [];
relCountsTime = [];
magCountsTime = [];

for timePoint = 1:numTimePoints

    % Set Angle Time Point
    tempAngMat = angMat(:, :, timePoint);
    
    % Raw Vector Directions
    flowMask = mainFlowMask(:, :, timePoint);
    angList = mod(tempAngMat(flowMask(:) == 1)*180/pi, 360);
    angWeights = ones(size(angList));
    rawCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);
    rawCountsTime = [rawCountsTime; rawCounts];

    % Masked Vector Directions - Reliability
    flowMask = mainFlowMask(:, :, timePoint).*double(relMat(:, :, timePoint) > relThresh) > 0;
    angList = mod(tempAngMat(flowMask(:) == 1)*180/pi, 360);
    angWeights = ones(size(angList));
    threshCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);
    threshCountsTime = [threshCountsTime; threshCounts];

    % Weighted Vector Directions - Reliability
    flowMask = mainFlowMask(:, :, timePoint);
    angList = mod(tempAngMat(flowMask(:) == 1)*180/pi, 360);
    angWeights = relMat(flowMask(:) == 1);
    relCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);
    relCountsTime = [relCountsTime; relCounts];
    
    % Weighted Vector Directions - Magnitude
    flowMask = mainFlowMask(:, :, timePoint);
    angList = mod(tempAngMat(flowMask(:) == 1)*180/pi, 360);
    angWeights = magMat(flowMask(:) == 1);
    magCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);
    magCountsTime = [magCountsTime; magCounts];

end

%% Assign Histogram Data
HistogramTimeData.BinWidth = dataBinWidth;
HistogramTimeData.RelThresh = relThresh;
HistogramTimeData.RawCounts = rawCountsTime;
HistogramTimeData.ThreshCounts = threshCountsTime;
HistogramTimeData.RelCountsWeighted = relCountsTime;
HistogramTimeData.MagCountsWeighted = magCountsTime;

%% Save Results
save([histExportFolder, histDataFilename], 'HistogramTimeData');