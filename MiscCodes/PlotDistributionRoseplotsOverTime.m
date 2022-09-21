function PlotDistributionRoseplotsOverTime(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, numSmoothedFrames, HistogramTimeData)
%% Assign values
rawCounts = HistogramTimeData.RawCounts;
thrCounts = HistogramTimeData.ThreshCounts;
relCounts = HistogramTimeData.RelCountsWeighted;
magCounts = HistogramTimeData.MagCountsWeighted;

%% Check variables for compatibility
if mod(showBinWidth, dataBinWidth) ~= 0 || mod(90, showBinWidth) ~= 0
    error('binWidths not compatible');
end
numBinsFac = showBinWidth/dataBinWidth;

%% Time Average Smooth
smoothRawCounts = TimeAverageDistSmoothing(rawCounts, numSmoothedFrames);
smoothThrCounts = TimeAverageDistSmoothing(thrCounts, numSmoothedFrames);
smoothRelCounts = TimeAverageDistSmoothing(relCounts, numSmoothedFrames);
smoothMagCounts = TimeAverageDistSmoothing(magCounts, numSmoothedFrames);

%% Define and Open Files
v1 = VideoWriter([histExportFolder, filePrefix, '_RawRoseplot_OverTime.avi']);
v2 = VideoWriter([histExportFolder, filePrefix, '_ThreshRoseplot_OverTime.avi']);
v3 = VideoWriter([histExportFolder, filePrefix, '_ReliabilityRoseplot_OverTime.avi']);
v4 = VideoWriter([histExportFolder, filePrefix, '_MagnitudeRoseplot_OverTime.avi']);
v1.FrameRate = 12;
v2.FrameRate = 12;
v3.FrameRate = 12;
v4.FrameRate = 12;
open(v1);
open(v2);
open(v3);
open(v4);

%% Set Limits
if distOption == 1
    lowerTheta = 0 - showBinWidth/2;
    upperTheta = 90 + showBinWidth/2;
elseif distOption == 2
    lowerTheta = 0;
    upperTheta = 360;
end
upperR1 = ceil(10*max(max((smoothRawCounts + circshift(smoothRawCounts, [0, 1]))./repmat(sum(smoothRawCounts, 2), [1, size(smoothRawCounts, 2)]))))/10;
upperR2 = ceil(10*max(max((smoothThrCounts + circshift(smoothThrCounts, [0, 1]))./repmat(sum(smoothThrCounts, 2), [1, size(smoothThrCounts, 2)]))))/10;
upperR3 = ceil(10*max(max((smoothRelCounts + circshift(smoothRelCounts, [0, 1]))./repmat(sum(smoothRelCounts, 2), [1, size(smoothRelCounts, 2)]))))/10;
upperR4 = ceil(10*max(max((smoothMagCounts + circshift(smoothMagCounts, [0, 1]))./repmat(sum(smoothMagCounts, 2), [1, size(smoothMagCounts, 2)]))))/10;

%% Start Distribution Loop
h = figure;
numFrames = size(smoothRawCounts, 1);
for frameNum = 1:numFrames
    %% Setup x and y data
    [xData, yData1] = MakeRoseplotData(showBinWidth, smoothRawCounts(frameNum, :), numBinsFac, distOption);
    [~, yData2] = MakeRoseplotData(showBinWidth, smoothThrCounts(frameNum, :), numBinsFac, distOption);
    [~, yData3] = MakeRoseplotData(showBinWidth, smoothRelCounts(frameNum, :), numBinsFac, distOption);
    [~, yData4] = MakeRoseplotData(showBinWidth, smoothMagCounts(frameNum, :), numBinsFac, distOption);
    
    %% Make the histograms
    g = polarplot(xData, yData1, ...
        'LineWidth', 2, ...
        'Color', [0 0.5 0.75]);
    
    % Save v1
    thetalim([lowerTheta, upperTheta]);
    rlim([0, upperR1]);
    drawnow;
    f = getframe(gcf);
    writeVideo(v1, f);
    
    % Save v2
    thetalim([lowerTheta, upperTheta]);
    rlim([0, upperR2]);
    g.RData = yData2;
    drawnow;
    f = getframe(gcf);
    writeVideo(v2, f);
    
    % Save v3
    thetalim([lowerTheta, upperTheta]);
    rlim([0, upperR3]);
    g.RData = yData3;
    drawnow;
    f = getframe(gcf);
    writeVideo(v3, f);
    
    % Save v4
    thetalim([lowerTheta, upperTheta]);
    rlim([0, upperR4]);
    g.RData = yData4;
    drawnow;
    f = getframe(gcf);
    writeVideo(v4, f);
    
end
close(h);

%% Close Files
close(v1);
close(v2);
close(v3);
close(v4);

end