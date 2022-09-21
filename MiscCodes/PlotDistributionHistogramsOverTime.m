function PlotDistributionHistogramsOverTime(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, numSmoothedFrames, HistogramTimeData)
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
v1 = VideoWriter([histExportFolder, filePrefix, '_RawHistogram_OverTime.avi']);
v2 = VideoWriter([histExportFolder, filePrefix, '_ThreshHistogram_OverTime.avi']);
v3 = VideoWriter([histExportFolder, filePrefix, '_ReliabilityHistogram_OverTime.avi']);
v4 = VideoWriter([histExportFolder, filePrefix, '_MagnitudeHistogram_OverTime.avi']);
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
    lowerX = - showBinWidth/2;
    upperX = 90 - showBinWidth/2;
elseif distOption == 2
    lowerX = -showBinWidth/2;
    upperX = 360 - showBinWidth/2;
end
upperY1 = ceil(10*max(max((smoothRawCounts + circshift(smoothRawCounts, [0, 1]))./repmat(sum(smoothRawCounts, 2), [1, size(smoothRawCounts, 2)]))))/10;
upperY2 = ceil(10*max(max((smoothThrCounts + circshift(smoothThrCounts, [0, 1]))./repmat(sum(smoothThrCounts, 2), [1, size(smoothThrCounts, 2)]))))/10;
upperY3 = ceil(10*max(max((smoothRelCounts + circshift(smoothRelCounts, [0, 1]))./repmat(sum(smoothRelCounts, 2), [1, size(smoothRelCounts, 2)]))))/10;
upperY4 = ceil(10*max(max((smoothMagCounts + circshift(smoothMagCounts, [0, 1]))./repmat(sum(smoothMagCounts, 2), [1, size(smoothMagCounts, 2)]))))/10;

%% Start Distribution Loop
h = figure;
numFrames = size(smoothRawCounts, 1);
for frameNum = 1:numFrames
    %% Setup x and y data
    [xData, yData1] = MakeHistogramData(showBinWidth, smoothRawCounts(frameNum, :), numBinsFac, distOption);
    [~, yData2] = MakeHistogramData(showBinWidth, smoothThrCounts(frameNum, :), numBinsFac, distOption);
    [~, yData3] = MakeHistogramData(showBinWidth, smoothRelCounts(frameNum, :), numBinsFac, distOption);
    [~, yData4] = MakeHistogramData(showBinWidth, smoothMagCounts(frameNum, :), numBinsFac, distOption);
    
    %% Make the histograms
    g = plot(xData, yData1, ...
        'LineWidth', 2, ...
        'Color', [0 0.5 0.75]);
    xlabel('Degrees');
    ylabel('Fractional Count');
    
    % Save v1
    xlim([lowerX, upperX]);
    ylim([0, upperY1]);
    drawnow;
    f = getframe(gcf);
    writeVideo(v1, f);

    % Save v2
    xlim([lowerX, upperX]);
    ylim([0, upperY2]);
    g.YData = yData2;
    drawnow;
    f = getframe(gcf);
    writeVideo(v2, f);
    
    % Save v3
    xlim([lowerX, upperX]);
    ylim([0, upperY3]);
    g.YData = yData3;
    drawnow;
    f = getframe(gcf);
    writeVideo(v3, f);
    
    % Save v4
    xlim([lowerX, upperX]);
    ylim([0, upperY4]);
    g.YData = yData4;
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