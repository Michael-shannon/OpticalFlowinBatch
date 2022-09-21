%% Make Flow Figure Images
function FlowFigureMovies(fileParams, flowFigureImageParams)
%% Start FlowFigureImages Script
fprintf('\n\n- - - Starting FlowFigureMovies - - -\n\n');

%% Import Parameters

% Input parameters
numMicrons = 10;

% File Parameters
pxPerMicron = fileParams.pxPerMicron;
secBtwFrames = fileParams.secBtwFrames;
exportFolder = fileParams.exportFolder;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;

% Flow Figure Parameters
intGamma = flowFigureImageParams.intGamma;
relGamma = flowFigureImageParams.relGamma;
relThreshFac = flowFigureImageParams.relThreshFac;
magGamma = flowFigureImageParams.magGamma;
magThresh = flowFigureImageParams.magThresh;
flowSig = flowFigureImageParams.flowSig;
spacing = flowFigureImageParams.spacingA;
spacingFac = flowFigureImageParams.spacingFacA;
lineWidth = flowFigureImageParams.vecLineWidthA;
cmap = flowFigureImageParams.periodicxcmap2;

%% Define Folders
fileExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep];

%% Load Files

% Optical Flow Image
fprintf('Loading Optical Flow Images\n');
load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');

% Flow Figure Data
fprintf('Loading Flow Figure Data\n');
load([fileExportFolder, 'ImageA.mat'], 'imageA');
load([fileExportFolder, 'FigureAImages.mat'], 'FigureAImages');
load([fileExportFolder, 'FigureBImages.mat'], 'FigureBImages');
load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
load([fileExportFolder, 'FigureBParams.mat'], 'FigureBParams');

%% Set Files

% Set Optical Flow
vxMat = OpticalFlow.vxMat;
vyMat = OpticalFlow.vyMat;
relMat = OpticalFlow.relMat;

% Set "A" Images
imageAshow = FigureAImages.ImageA;
vxMatShowA = FigureAImages.vxMatA;
vyMatShowA = FigureAImages.vyMatA;
relMatShowA = FigureAImages.relMatA;
numA = length(FigureAParams.xIdx);
xIdxA = FigureAParams.xIdx;
yIdxA = FigureAParams.yIdx;

% Set "B" Images
imageBshow = FigureBImages.ImageB;
vxMatShowB = FigureBImages.vxMatB;
vyMatShowB = FigureBImages.vyMatB;
relMatShowB = FigureBImages.relMatB;
xIdxB = FigureBParams.xIdx;
yIdxB = FigureBParams.yIdx;

%% Set Up Movie Images - Movies 1 and 2

% Define vectors
vxMatShow = vxMat;
vyMatShow = vyMat;
relMatShow = relMat;
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

%% Movie 1
v1 = VideoWriter([fileExportFolder, 'WholeImage_WithFlow.avi']);
v1.FrameRate = 12;
open(v1);

% Create Figure
h = figure;
g1 = imshow(zeros(size(imageA, 1), size(imageA, 2), 'uint16'));
hold on;
g2 = quiver(zeros(size(imageA, 1), size(imageA, 2)), zeros(size(imageA, 1), size(imageA, 2)), 0, 'g', 'linewidth', lineWidth);
hold off;
barSize = numMicrons*pxPerMicron;
set(h, 'Position', [1, 41, 1920, 964]);
Movie1and2_WholeImageWithFlow_and_WithFlowColoredByDirection(v1, g1, g2, imageA, vxMatShow, vyMatShow, intGamma, barSize, secBtwFrames, 1);
close(v1);
close(h);

%% Movie 2
v2 = VideoWriter([fileExportFolder, 'WholeImage_WithColoredFlow.avi']);
v2.FrameRate = 12;
open(v2);

% Create Figure
h = figure;
g1 = imshow(zeros(size(imageA, 1), size(imageA, 2), 'uint16'));
hold on;
g2 = ColorQuiver(zeros(size(imageA, 1), size(imageA, 2)), zeros(size(imageA, 1), size(imageA, 2)), cmap, lineWidth);
hold off;
barSize = numMicrons*pxPerMicron;
set(h, 'Position', [1, 41, 1920, 964]);
Movie1and2_WholeImageWithFlow_and_WithFlowColoredByDirection(v1, g1, g2, imageA, vxMatShow, vyMatShow, intGamma, barSize, secBtwFrames, 2, cmap, lineWidth);
close(v2);
close(h);

%% Make Movies for Single Cells
% Set Up Movie Images - Movies 3 and 4

% Input parameters
numMicrons = 10;

% Import parameters
pxPerMicron = fileParams.pxPerMicron;
spacingB = flowFigureImageParams.spacingB;
spacingFacB = flowFigureImageParams.spacingFacB;
lineWidth = flowFigureImageParams.vecLineWidthB;
relPower = flowFigureImageParams.relPower;
magThresh = flowFigureImageParams.magThresh;
magFac = flowFigureImageParams.magFac;
cmap = flowFigureImageParams.periodicxcmap2;

%% Start Loop
for cellNum = 1:numA
    %% Set Up Movie Images - Movies 3 and 4
    
    % Set up vectors
    vxMatShow = vxMatShowA{cellNum};
    vyMatShow = vyMatShowA{cellNum};
    
    % Set up vector weights
    magMatShow = sqrt(vxMatShow.^2 + vyMatShow.^2);
    magMask = double(magMatShow > magThresh);
    relMatShow = RenormalizeImage(relMatShowA{cellNum});
    vecWeight = magFac*magMask.*(relMatShow.^(1/relPower))./magMatShow;
    
    % Create final vectors
    [vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacingB);
    vxMatShow = vxMatShow*spacingFacB*spacingB.*vecWeight;
    vyMatShow = vyMatShow*spacingFacB*spacingB.*vecWeight;
    [vxMatShow, vyMatShow] = CutQuiverVectors(vxMatShow, vyMatShow);
    
    %% Movie 3
    v3 = VideoWriter([fileExportFolder, 'Cell', num2str(cellNum), 'of', num2str(numA), '_WithFlow.avi']);
    v3.FrameRate = 12;
    open(v3);
    
    % Create Figure
    h = figure;
    
    % Create dispImage
    dispImage = imageAshow{cellNum}(:, :, 1);
    dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
    dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);
    
    % Initialize imshow
    g1 = imshow(dispImage);
    colormap gray
    axis equal
    axis off
    g1.CData = dispImage;
    vxTemp = vxMatShow(:, :, 1);
    vyTemp = vyMatShow(:, :, 1);
    idx = find(~isnan(vxTemp));
    [ix, iy] = ind2sub(size(vxTemp), idx);
    hold on;
    g2 = quiver(iy, ix, vxTemp(idx), vyTemp(idx), 0, 'g', 'linewidth', lineWidth);
    hold off;
    set(h, 'Position', [1, 41, 1920, 964]);
    
    numFrames = size(imageA, 3) - 1;
    for frameNum = 1:numFrames
        %% Create dispImage
        dispImage = imageAshow{cellNum}(:, :, frameNum);
        dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
        dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);
        
        %% Produce Output 1
        g1.CData = dispImage;
        vxTemp = vxMatShow(:, :, frameNum);
        vyTemp = vyMatShow(:, :, frameNum);
        idx = find(~isnan(vxTemp));
        [ix, iy] = ind2sub(size(vxTemp), idx);
        set(g2, 'XData', iy, 'YData', ix, 'UData', vxTemp(idx), 'VData', vyTemp(idx));
        
        %% Add Scale Bar
        barSize = numMicrons*pxPerMicron;
        AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
        
        %% Save Output
        drawnow;
        f = getframe(gca);
        
        %% Add Timer
        numSec = mod(secBtwFrames*(frameNum - 1), 60);
        numSec = sprintf('%02u', numSec);
        numMin = floor(secBtwFrames*(frameNum - 1)/60);
        numMin = sprintf('%02u', numMin);
        f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
            'FontSize', 18, ...
            'TextColor', 'white', ...
            'BoxColor', 'red', ...
            'BoxOpacity', 0);
        writeVideo(v3, f);
        
    end
    close(v3);
    close(h);
    
    %% Movie 4
    v4 = VideoWriter([fileExportFolder, 'Cell', num2str(cellNum), 'of', num2str(numA), '_WithFlow_WithColoredFlow.avi']);
    v4.FrameRate = 12;
    open(v4);
    
    % Create Figure
    h = figure;
    
    % Create dispImage
    dispImage = imageAshow{cellNum}(:, :, 1);
    dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
    dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);
    
    % Initialize imshow
    g1 = imshow(dispImage);
    colormap gray
    axis equal
    axis off
    g1.CData = dispImage;
    hold on;
    g2 = ColorQuiver(vxMatShow(:, :, 1), vyMatShow(:, :, 1), cmap, lineWidth);
    hold off;
    set(h, 'Position', [1, 41, 1920, 964]);
    
    numFrames = size(imageA, 3) - 1;
    for frameNum = 1:numFrames
        %% Create dispImage
        dispImage = imageAshow{cellNum}(:, :, frameNum);
        dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
        dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);
        
        %% Produce Output 1
        g1.CData = dispImage;
        g2 = ColorQuiver(vxMatShow(:, :, frameNum), vyMatShow(:, :, frameNum), cmap, lineWidth, g2);
        
        %% Add Scale Bar
        barSize = numMicrons*pxPerMicron;
        AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
        
        %% Save Output
        drawnow;
        f = getframe(gca);
        
        %% Add Timer
        numSec = mod(secBtwFrames*(frameNum - 1), 60);
        numSec = sprintf('%02u', numSec);
        numMin = floor(secBtwFrames*(frameNum - 1)/60);
        numMin = sprintf('%02u', numMin);
        f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
            'FontSize', 18, ...
            'TextColor', 'white', ...
            'BoxColor', 'red', ...
            'BoxOpacity', 0);
        writeVideo(v4, f);
        
    end
    close(v4);
    close(h);
    
end

%% Whole Image w/ Flow

% %% Colored Flow Image
%
% Image3_ColoredFlowImage(imageExportFolder, fileParams, flowFigureImageParams, vxMat, vyMat, relMat, 10)
%
% %% Whole Image w/ Outlines
%
% Image4_WholeImageWithOutlines(imageExportFolder, fileParams, flowFigureImageParams, imageA, xIdxA, yIdxA, 10);
%
% %% Individual Cells w/ Flow
%
% Image5_SingleCellsWithFlow(imageExportFolder, fileParams, flowFigureImageParams, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA, 2);
%
% %% Individual Cells w/ Flow Colored by Direction
%
% Image6_SingleCellsWithColoredFlow(imageExportFolder, fileParams, flowFigureImageParams, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA, 2);

%%
% for i = 1:length(imageAshow)
%     if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)),'_WithFlow.png'], 'file')
%         h = figure;
%
%         dispImage = imageAshow{i};
%         dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
%         dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage));
%         imshow(dispImage);
%
%         barSize = 5*pxPerMicron;
%         AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
%
%         colormap gray
%         axis equal
%         axis off
%         vxMatShow = vxMatShowA{i};
%         vyMatShow = vyMatShowA{i};
%         magMatShow = sqrt(vxMatShow.^2 + vyMatShow.^2);
%         relMatShow = RenormalizeImage(relMatShowA{i});
%         [vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacingB);
%         vxMatShow = vxMatShow*spacingFacB*spacingB.*(relMatShow.^(1/relPower))./magMatShow;
%         vyMatShow = vyMatShow*spacingFacB*spacingB.*(relMatShow.^(1/relPower))./magMatShow;
%         hold on;
%         quiver(vxMatShow, vyMatShow, 0, 'g');
%         hold off;
%         set(gcf, 'Position', [1, 41, 1920, 964]);
%         axis equal;
%         axis off;
%         f = getframe(gca);
%         f = frame2im(f);
%         imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)),'_WithFlow.png'], 'png');
%         close(h);
%     end
%     if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)),'_WithFlow_ColoredByDirection.png'], 'file')
%         h = figure;
%         dispImage = imageAshow{i};
%         dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
%         dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage));
%         imshow(dispImage);
%         barSize = 5*pxPerMicron;
%         AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
%         colormap gray
%         axis equal
%         axis off
%         vxMatShow = vxMatShowA{i};
%         vyMatShow = vyMatShowA{i};
%         magMatShow = sqrt(vxMatShow.^2 + vyMatShow.^2);
%         relMatShow = RenormalizeImage(relMatShowA{i});
%         [vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacingB);
%         vxMatShow = vxMatShow*spacingFacB*spacingB.*(relMatShow.^(1/relPower))./magMatShow;
%         vyMatShow = vyMatShow*spacingFacB*spacingB.*(relMatShow.^(1/relPower))./magMatShow;
%         hold on;
%         ColorQuiver(vxMatShow, vyMatShow, periodicxcmap2, 0, 1);
%         hold off;
%         set(gcf, 'Position', [1, 41, 1920, 964]);
%         axis equal;
%         axis off;
%         f = getframe(gca);
%         f = frame2im(f);
%         imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)),'_WithFlow_ColoredByDirection.png'], 'png');
%         close(h);
%     end
%     if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)),'_WithColorCodedFlow.png'], 'file')
%         h = figure;
%         vxMatShow = vxMatShowA{i};
%         vyMatShow = vyMatShowA{i};
%         relMatShow = relMatShowA{i};
%         thetaMatShow = round(255*RenormalizeImage(atan2(-vyMatShow, vxMatShow)));
%         magMatShow = RenormalizeImage(sqrt(vxMatShow.^2 + vyMatShow.^2));
%         dispImageFac = RenormalizeImage(sqrt(relMatShow).*magMatShow).^(1/5);
%         c1Image = nan(size(thetaMatShow));
%         c2Image = nan(size(thetaMatShow));
%         c3Image = nan(size(thetaMatShow));
%         for j = 0:255
%             c1Image(thetaMatShow(:) == j) = 1 - periodicxcmap1(j + 1, 1);
%             c2Image(thetaMatShow(:) == j) = 1 - periodicxcmap1(j + 1, 2);
%             c3Image(thetaMatShow(:) == j) = 1 - periodicxcmap1(j + 1, 3);
%         end
%         c1Image = c1Image.*dispImageFac;
%         c2Image = c2Image.*dispImageFac;
%         c3Image = c3Image.*dispImageFac;
%         c1Image(isnan(magMatShow)) = 0;
%         c2Image(isnan(magMatShow)) = 0;
%         c3Image(isnan(magMatShow)) = 0;
%         dispImage = cat(3, c1Image, c2Image, c3Image);
%         imshow(1 - dispImage); colormap(periodicxcmap1);
%         barSize = 5*pxPerMicron;
%         AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
%         axis equal
%         axis off
%         set(gcf, 'Position', [1, 41, 1920, 964]);
%         f = getframe(gca);
%         f = frame2im(f);
%         imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)),'_WithColorCodedFlow.png'], 'png');
%         close(h);
%     end
% end
%
% % Display Image
% figure;
% subplot(1, length(imageAshow) + 1, 1);
% imagesc(imageA(:, :, frameNum));
% colormap gray
% axis equal
% axis off
% for i = 1:length(xIdxA)
%     hold on;
%     plot(yIdxA{i}, min(xIdxA{i}) + zeros(size(yIdxA{i})), 'r', 'linewidth', 1.5);
%     plot(yIdxA{i}, max(xIdxA{i}) + zeros(size(yIdxA{i})), 'r', 'linewidth', 1.5);
%     plot(min(yIdxA{i}) + zeros(size(xIdxA{i})), xIdxA{i}, 'r', 'linewidth', 1.5);
%     plot(max(yIdxA{i}) + zeros(size(xIdxA{i})), xIdxA{i}, 'r', 'linewidth', 1.5);
%     hold off;
% end
% for i = 1:length(imageAshow)
%     subplot(1, length(imageAshow) + 1, i + 1);
%     imagesc(imageAshow{i});
%     colormap gray
%     axis equal
%     axis off
%     vxMatShow = vxMatShowA{i};
%     vyMatShow = vyMatShowA{i};
%     [vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacingB);
%     hold on;
%     quiver(vxMatShow, vyMatShow, spacingFacB*spacingB, 'g');
%     hold off;
% end
%
% %% Individual Cells w/ Outlines and Individual Zoomed Regions w/ Flow
% for i = 1:length(imageAshow)
%     if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep], 'dir')
%         mkdir([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep]);
%     end
%     if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), '_RegionOutline.png'], 'file')
%         h = figure;
%         dispImage = imageAshow{i};
%         dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
%         dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage));
%         imshow(dispImage);
%         barSize = 5*pxPerMicron;
%         AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
%         colormap gray
%         axis equal
%         axis off
%         hold on;
%         for j = 1:size(imageBshow, 2)
%             if ~isempty(imageBshow{i, j})
%                 plot(yIdxB{i, j}, min(xIdxB{i, j}) + zeros(size(yIdxB{i, j})), 'r', 'linewidth', 1.5);
%                 plot(yIdxB{i, j}, max(xIdxB{i, j}) + zeros(size(yIdxB{i, j})), 'r', 'linewidth', 1.5);
%                 plot(min(yIdxB{i, j}) + zeros(size(xIdxB{i, j})), xIdxB{i, j}, 'r', 'linewidth', 1.5);
%                 plot(max(yIdxB{i, j}) + zeros(size(xIdxB{i, j})), xIdxB{i, j}, 'r', 'linewidth', 1.5);
%             end
%         end
%         hold off
%         set(gcf, 'Position', [1, 41, 1920, 964]);
%         f = getframe(gca);
%         f = frame2im(f);
%         imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), '_RegionOutline.png'], 'png');
%         close(h);
%     end
%     for j = 1:size(imageBshow, 2)
%         try
%             if ~isempty(imageBshow{i, j})
%                 if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep, 'Region_', num2str(j), 'of', size(imageBshow, 2), '_Outline.png'], 'file')
%                     h = figure;
%                     dispImage = imageAshow{i};
%                     dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
%                     dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage));
%                     imshow(dispImage);
%                     colormap gray
%                     axis equal
%                     axis off
%                     set(gcf, 'Position', [1, 41, 1920, 964]);
%                     hold on
%                     plot(yIdxB{i, j}, min(xIdxB{i, j}) + zeros(size(yIdxB{i, j})), 'r', 'linewidth', 1.5);
%                     plot(yIdxB{i, j}, max(xIdxB{i, j}) + zeros(size(yIdxB{i, j})), 'r', 'linewidth', 1.5);
%                     plot(min(yIdxB{i, j}) + zeros(size(xIdxB{i, j})), xIdxB{i, j}, 'r', 'linewidth', 1.5);
%                     plot(max(yIdxB{i, j}) + zeros(size(xIdxB{i, j})), xIdxB{i, j}, 'r', 'linewidth', 1.5);
%                     hold off
%                     f = getframe(gca);
%                     f = frame2im(f);
%                     imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep, 'Region_', num2str(j), 'of', num2str(sum(~cellfun('isempty', imageBshow(i, :)))), '_Outline.png'], 'png');
%                     close(h);
%                 end
%                 if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep, 'Region_', num2str(j), 'of', size(imageBshow, 2), '_Image.png'], 'file')
%                     h = figure;
%                     dispImage = imageBshow{i, j};
%                     dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
%                     dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage));
%                     imshow(dispImage);
%                     colormap gray
%                     axis equal
%                     axis off
%                     set(gcf, 'Position', [1, 41, 1920, 964]);
%                     f = getframe(gca);
%                     f = frame2im(f);
%                     imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep, 'Region_', num2str(j), 'of', num2str(sum(~cellfun('isempty', imageBshow(i, :)))), '_Image.png'], 'png');
%                     close(h);
%                 end
%                 if ~exist([imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep, 'Region_', num2str(j), 'of', size(imageBshow, 2), '_Image_WithFlow.png'], 'file')
%                     h = figure;
%                     dispImage = imageBshow{i, j};
%                     dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
%                     dispImage = uint16((2^16 - 1)*RenormalizeImage(dispImage));
%                     vxMatShow = vxMatShowB{i, j};
%                     vyMatShow = vyMatShowB{i, j};
%                     magMatShow = sqrt(vxMatShow.^2 + vyMatShow.^2);
%                     relMatShow = RenormalizeImage(relMatShowB{i, j});
%                     [vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacingC);
%                     vxMatShow = vxMatShow*spacingFacC*spacingC.*(relMatShow.^(1/relPower))./magMatShow;
%                     vyMatShow = vyMatShow*spacingFacC*spacingC.*(relMatShow.^(1/relPower))./magMatShow;
%                     imshow(dispImage);
%                     colormap gray
%                     axis equal
%                     axis off
%                     hold on
%                     quiver(vxMatShow, vyMatShow, 0, 'g');
%                     hold off
%                     set(gcf, 'Position', [1, 41, 1920, 964]);
%                     f = getframe(gca);
%                     f = frame2im(f);
%                     imwrite(f, [imageExportFolder, 'Cell_', num2str(i), 'of', num2str(length(imageAshow)), filesep, 'Region_', num2str(j), 'of', num2str(sum(~cellfun('isempty', imageBshow(i, :)))), '_Image_WithFlow.png'], 'png');
%                     close(h);
%                 end
%             end
%         catch
%             disp('Error - Zoomed Regions');
%         end
%     end
% end
%
% % Display Image
% for i = 1:length(imageAshow)
%     figure;
%     subplot(1, sum(~cellfun('isempty', imageBshow(i, :))) + 1, 1);
%     imagesc(imageAshow{i});
%     colormap gray
%     axis equal
%     axis off
%     for j = 1:size(imageBshow, 2)
%         subplot(1, sum(~cellfun('isempty', imageBshow(i, :))) + 1, 1);
%         hold on;
%         plot(yIdxB{i, j}, min(xIdxB{i, j}) + zeros(size(yIdxB{i, j})), 'r', 'linewidth', 1.5);
%         plot(yIdxB{i, j}, max(xIdxB{i, j}) + zeros(size(yIdxB{i, j})), 'r', 'linewidth', 1.5);
%         plot(min(yIdxB{i, j}) + zeros(size(xIdxB{i, j})), xIdxB{i, j}, 'r', 'linewidth', 1.5);
%         plot(max(yIdxB{i, j}) + zeros(size(xIdxB{i, j})), xIdxB{i, j}, 'r', 'linewidth', 1.5);
%         hold off
%         if ~isempty(imageBshow{i, j})
%             subplot(1, sum(~cellfun('isempty', imageBshow(i, :))) + 1, j + 1);
%             imagesc(imageBshow{i, j});
%             colormap gray
%             axis equal
%             axis off
%             hold on;
%             vxMatShow = vxMatShowB{i, j};
%             vyMatShow = vyMatShowB{i, j};
%             [vxMatShow, vyMatShow] = DeclutterQuiver(vxMatShow, vyMatShow, spacingC);
%             quiver(vxMatShow, vyMatShow, spacingFacC*spacingC, 'g');
%             hold off
%         end
%     end
% end