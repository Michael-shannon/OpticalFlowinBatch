function TrackFigureMovies(fileParams, trackFigureMovieParams)
%% File Parameters
timeBtwFrames = fileParams.timeBtwFrames;
timeUnit = fileParams.timeUnit;
pxPerMicron = fileParams.pxPerMicron;
exportFolder = fileParams.exportFolder;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;
if timeUnit == 1
    secPerFrame = timeBtwFrames;
elseif timeUnit == 2
    secPerFrame = round(60*timeBtwFrames);
end

%% Input Parameters
numMicrons = 10;

%% Track Figure Parameters
intPower = trackFigureMovieParams.intPower;
clusterFil = trackFigureMovieParams.clusterFil;
posThreshVec = trackFigureMovieParams.posThreshVec;
negThreshVec = trackFigureMovieParams.negThreshVec;
posThreshColor = trackFigureMovieParams.posThreshColor;
negThreshColor = trackFigureMovieParams.negThreshColor;
plotStyle = trackFigureMovieParams.plotStyle;

%% Define Folders
fileExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep];
trackExportFolder = [exportFolder, ...
    filesep, 'TrackFigure', ...
    filesep];

%% Load Files

% Optical Flow Image
fprintf('Loading MainAnalysis Images\n');
load([exportFolder, 'OriginalImage.mat'], 'OriginalImage');
load([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage');
load([exportFolder, 'EnhancedImage.mat'], 'EnhancedImage');
load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');

% Flow Figure Data
fprintf('Loading Flow Figure Data\n');
load([fileExportFolder, 'ImageA.mat'], 'imageA');
load([fileExportFolder, 'FigureAImages.mat'], 'FigureAImages');
load([fileExportFolder, 'FigureBImages.mat'], 'FigureBImages');
load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
load([fileExportFolder, 'FigureBParams.mat'], 'FigureBParams');

%% Set Up Files - Whole Image
fprintf('Setting Up Cluster Images\n');

% Original Image
origImage = OriginalImage.Image(:, :, :, OriginalImage.ActinChannel);

% Difference Image
diffImage = DifferenceImage.smoothDiffImage;

% Optical Flow Images
vxMat = OpticalFlow.vxMat;
vyMat = OpticalFlow.vyMat;
magMat = sqrt(vxMat.^2 + vyMat.^2);

% Enhanced Flow Images
enhImage = EnhancedImage.SmoothEnhancedRelMat;

% Cluster Images
vxMat = vxMat./magMat;
vyMat = vyMat./magMat;
alignMat = (vxMat.*imfilter(vxMat, clusterFil) + vyMat.*imfilter(vyMat, clusterFil)).^2;
posClusterMat = enhImage.*double(diffImage > 0).*alignMat;
negClusterMat = enhImage.*double(diffImage < 0).*alignMat;

%% Start Movie
v = VideoWriter([trackExportFolder, 'ClusterMovie - WholeImage.avi']);
v.FrameRate = 12;
open(v);
for frameNum = 1:size(posClusterMat, 3)
    %% Create Figure
    h = figure;
    
    %% Set Disp Image
    dispImage = origImage(:, :, frameNum);
    dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage, 1).^(1/intPower));
    imshow(dispImage);
    colormap gray;
    axis equal;
    axis off;
    set(h, 'Position', [1, 41, 1920, 964]);
    lineWidth = 3.5;
    
    %% Draw Clusters
    hold on;
    for threshNum = 1:length(posThreshVec)
        clusterMask = posClusterMat(:, :, frameNum) > posThreshVec(threshNum);
        clusterBounds = bwboundaries(clusterMask);
        clusterBounds = CutBounds(size(clusterMask), clusterBounds, lineWidth);
        for boundNum = 1:length(clusterBounds)
            if plotStyle == 1
                plot(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), 'Color', posThreshColor(threshNum, :), 'linewidth', lineWidth);
            elseif plotStyle == 2
                fill(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), posThreshColor(threshNum, :));
            end
        end
    end
    
    hold on;
    for threshNum = 1:length(negThreshVec)
        clusterMask = negClusterMat(:, :, frameNum) > negThreshVec(threshNum);
        clusterBounds = bwboundaries(clusterMask);
        clusterBounds = CutBounds(size(clusterMask), clusterBounds, lineWidth);
        for boundNum = 1:length(clusterBounds)
            if plotStyle == 1
                plot(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), 'Color', negThreshColor(threshNum, :), 'linewidth', lineWidth);
            elseif plotStyle == 2
                fill(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), negThreshColor(threshNum, :));
            end
        end
    end
    
    hold off;

    %% Add Scale Bar
    barSize = numMicrons*pxPerMicron;
    AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
   
    %% Save Output
    drawnow;
    f = getframe(gca);
    
    %% Add Timer
    numSec = mod(secPerFrame*(frameNum - 1), 60);
    numSec = sprintf('%02u', numSec);
    numMin = floor(secPerFrame*(frameNum - 1)/60);
    numMin = sprintf('%02u', numMin);
    f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
        'FontSize', 18, ...
        'TextColor', 'white', ...
        'BoxColor', 'red', ...
        'BoxOpacity', 0);
    writeVideo(v, f);
    
    %% Close Figure
    close(h);
end
close(v);

%% Set Up Files - Single Cells
fprintf('Setting Up Cluster Images\n');

% Set "A" Images
imageAshow = FigureAImages.ImageA;
numA = length(imageAshow);
vxMatShowA = FigureAImages.vxMatA;
vyMatShowA = FigureAImages.vyMatA;
xIdx = FigureAParams.xIdx;
yIdx = FigureAParams.yIdx;

for cellNum = 1:numA
    
    % Original Image
    origImage = imageAshow{cellNum};
    
    % Difference Image
    diffImage = imrotate(DifferenceImage.smoothDiffImage, thetaInDegrees);
    diffImage = diffImage(xIdx{cellNum}, yIdx{cellNum}, :);
    
    % Optical Flow Images
    vxMat = vxMatShowA{cellNum};
    vyMat = vyMatShowA{cellNum};
    magMat = sqrt(vxMat.^2 + vyMat.^2);
    
    % Enhanced Flow Images
    enhImage = imrotate(EnhancedImage.SmoothEnhancedRelMat, thetaInDegrees);
    enhImage = enhImage(xIdx{cellNum}, yIdx{cellNum}, :);
    
    % Cluster Images
    vxMat = vxMat./magMat;
    vyMat = vyMat./magMat;
    alignMat = (vxMat.*imfilter(vxMat, clusterFil) + vyMat.*imfilter(vyMat, clusterFil)).^2;
    posClusterMat = enhImage.*double(diffImage > 0).*alignMat;
    negClusterMat = enhImage.*double(diffImage < 0).*alignMat;
    
    %% Start Movie
    v = VideoWriter([trackExportFolder, 'ClusterMovie - Cell', num2str(cellNum), 'of', num2str(numA),'.avi']);
    v.FrameRate = 12;
    open(v);
    for frameNum = 1:size(posClusterMat, 3)
        %% Create Figure
        h = figure;
        
        %% Set Disp Image
        dispImage = origImage(:, :, frameNum);
        dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage, 1).^(1/intPower));
        imshow(dispImage);
        colormap gray;
        axis equal;
        axis off;
        set(h, 'Position', [1, 41, 1920, 964]);
        lineWidth = 3.5;
        
        %% Draw Clusters
        hold on;
        for threshNum = 1:length(posThreshVec)
            clusterMask = posClusterMat(:, :, frameNum) > posThreshVec(threshNum);
            clusterBounds = bwboundaries(clusterMask);
            clusterBounds = CutBounds(size(clusterMask), clusterBounds, lineWidth);
            for boundNum = 1:length(clusterBounds)
                if plotStyle == 1
                    plot(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), 'Color', posThreshColor(threshNum, :), 'linewidth', lineWidth);
                elseif plotStyle == 2
                    fill(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), posThreshColor(threshNum, :));
                end
            end
        end
        
        hold on;
        for threshNum = 1:length(negThreshVec)
            clusterMask = negClusterMat(:, :, frameNum) > negThreshVec(threshNum);
            clusterBounds = bwboundaries(clusterMask);
            clusterBounds = CutBounds(size(clusterMask), clusterBounds, lineWidth);
            for boundNum = 1:length(clusterBounds)
                if plotStyle == 1
                    plot(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), 'Color', negThreshColor(threshNum, :), 'linewidth', lineWidth);
                elseif plotStyle == 2
                    fill(clusterBounds{boundNum}(:, 2), clusterBounds{boundNum}(:, 1), negThreshColor(threshNum, :));
                end
            end
        end
        
        hold off;
        
        %% Add Scale Bar
        barSize = numMicrons*pxPerMicron;
        AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
        
        %% Save Output
        drawnow;
        f = getframe(gca);
        
        %% Add Timer
        numSec = mod(secPerFrame*(frameNum - 1), 60);
        numSec = sprintf('%02u', numSec);
        numMin = floor(secPerFrame*(frameNum - 1)/60);
        numMin = sprintf('%02u', numMin);
        f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
            'FontSize', 18, ...
            'TextColor', 'white', ...
            'BoxColor', 'red', ...
            'BoxOpacity', 0);
        writeVideo(v, f);
        
        %% Close Figure
        close(h);
    end
    close(v);
    
end