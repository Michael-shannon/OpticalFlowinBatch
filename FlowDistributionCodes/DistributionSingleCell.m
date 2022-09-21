function DistributionSingleCell(histExportFolder, histDataFilename, relMat, diffIm, magMat, angMat, dataBinWidth, relThresh)
%% Calculate Histogram Data

% Set mainFlowMask
mainFlowMask = ...
    double(relMat > 0).* ... % Where the relMat is > 0
    double(diffIm > 0).* ...     % Where the diffIm is > 0
    double(magMat > 0) ...   % Where the magMat is > 0
    > 0;

% Raw Vector Directions
flowMask = mainFlowMask;
angList = mod(angMat(flowMask(:) == 1)*180/pi, 360);
angWeights = ones(size(angList));
rawCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);

% Masked Vector Directions - Reliability
flowMask = mainFlowMask.*double(relMat > relThresh) > 0;
angList = mod(angMat(flowMask(:) == 1)*180/pi, 360);
angWeights = ones(size(angList));
threshCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);

% Weighted Vector Directions - Reliability
flowMask = mainFlowMask;
angList = mod(angMat(flowMask(:) == 1)*180/pi, 360);
angWeights = relMat(flowMask(:) == 1);
relCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);

% Weighted Vector Directions - Magnitude
flowMask = mainFlowMask;
angList = mod(angMat(flowMask(:) == 1)*180/pi, 360);
angWeights = magMat(flowMask(:) == 1);
magCounts = HistcountsWeighted(angList, angWeights, 0:dataBinWidth:360);

%% Assign Histogram Data
HistogramData.BinWidth = dataBinWidth;
HistogramData.RelThresh = relThresh;
HistogramData.RawCounts = rawCounts;
HistogramData.ThreshCounts = threshCounts;
HistogramData.RelCountsWeighted = relCounts;
HistogramData.MagCountsWeighted = magCounts;

%% Save Results
save([histExportFolder, histDataFilename], 'HistogramData');