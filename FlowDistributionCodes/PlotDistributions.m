function PlotDistributions(histExportFolder, filePrefix, distOption, dataBinWidth, showBinWidth, HistogramData, plotType)
%% Assign values
rawCounts = HistogramData.RawCounts;
thrCounts = HistogramData.ThreshCounts;
relCounts = HistogramData.RelCountsWeighted;
magCounts = HistogramData.MagCountsWeighted;

%% Check variables for compatibility
if mod(showBinWidth, dataBinWidth) ~= 0 || mod(90, showBinWidth) ~= 0
    error('binWidths not compatible');
end
numBinsFac = showBinWidth/dataBinWidth;

%% Setup x and y data
if plotType == 1
    [xData, yData1] = MakeHistogramData(showBinWidth, rawCounts, numBinsFac, distOption);
    [~, yData2] = MakeHistogramData(showBinWidth, thrCounts, numBinsFac, distOption);
    [~, yData3] = MakeHistogramData(showBinWidth, relCounts, numBinsFac, distOption);
    [~, yData4] = MakeHistogramData(showBinWidth, magCounts, numBinsFac, distOption);
elseif plotType == 2
    [xData, yData1] = MakeRoseplotData(showBinWidth, rawCounts, numBinsFac, distOption);
    [~, yData2] = MakeRoseplotData(showBinWidth, thrCounts, numBinsFac, distOption);
    [~, yData3] = MakeRoseplotData(showBinWidth, relCounts, numBinsFac, distOption);
    [~, yData4] = MakeRoseplotData(showBinWidth, magCounts, numBinsFac, distOption);
end

%% Set Limits
if plotType == 1
    if distOption == 1
        lowerX = 0;
        upperX = 90;
    elseif distOption == 2
        lowerX = -showBinWidth/2;
        upperX = 360 - showBinWidth/2;
    end
    upperY = ceil(10*max([yData1(:); yData2(:); yData3(:); yData4(:)]))/10;
elseif plotType == 2
    if distOption == 1
        lowerTheta = 0;
        upperTheta = 90;
    elseif distOption == 2
        lowerTheta = 0;
        upperTheta = 360;
    end
    upperR = ceil(10*max([yData1(:); yData2(:); yData3(:); yData4(:)]))/10;
end

%% Make the distributions
if plotType == 1
    h = figure;
    g = plot(xData, yData1, ...
        'LineWidth', 2, ...
        'Color', [0 0.5 0.75]);
    xlabel('Degrees');
    ylabel('Fractional Count');
    xlim([lowerX, upperX]);
    ylim([0, upperY]);
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_RawHistogram.png'], 'png');
    g.YData = yData2;
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_ThreshHistogram.png'], 'png');
    g.YData = yData3;
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_ReliabilityHistogram.png'], 'png');
    g.YData = yData4;
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_MagnitudeHistogram.png'], 'png');
    close(h);
elseif plotType == 2
    h = figure;
    g = polarplot(xData, yData1, ...
        'LineWidth', 2, ...
        'Color', [0 0.5 0.75]);
    thetalim([lowerTheta, upperTheta]);
    rlim([0, upperR]);
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_RawRoseplot.png'], 'png');
    g.RData = yData2;
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_ThreshRoseplot.png'], 'png');
    g.RData = yData3;
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_ReliabilityRoseplot.png'], 'png');
    g.RData = yData4;
    drawnow;
    saveas(gca, [histExportFolder, filePrefix, '_MagnitudeRoseplot.png'], 'png');
    close(h);
end
end