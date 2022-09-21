%% Make Flow Figure Images
function FlowFigureImages(fileParams, flowFigureImageParams)
%% Start FlowFigureImages Script
fprintf('\n\n- - - Starting FlowFigureImages - - -\n\n');

%% File Parameters
exportFolder = fileParams.exportFolder;

%% Flow Figure Parameters
frameNum = flowFigureImageParams.frameNum;

%% Define Folders
fileExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep];
imageExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep, 'Frame = ', num2str(frameNum), ...
    filesep];
if exist(imageExportFolder, 'dir')
else
    mkdir(imageExportFolder);
end

%% Load Files
fprintf('- Loading Image Files\n');

% Optical Flow Image
fprintf('  Loading Optical Flow Images\n');
load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');

% Flow Figure Data
fprintf('  Loading Flow Figure Data\n');
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

%% Create Images
fprintf('- Starting Image Creation\n');

% Whole Image w/ Flow
Image1and2_WholeImageWithFlow_and_WithFlowColoredByDirection(imageExportFolder, fileParams, flowFigureImageParams, imageA, vxMat, vyMat, relMat, 10, 1);

% Whole Image w/ Flow Colored by Direction
Image1and2_WholeImageWithFlow_and_WithFlowColoredByDirection(imageExportFolder, fileParams, flowFigureImageParams, imageA, vxMat, vyMat, relMat, 10, 2);

% Colored Flow Image
Image3_ColoredFlowImage(imageExportFolder, fileParams, flowFigureImageParams, vxMat, vyMat, relMat, 10)

% Whole Image w/ Outlines
Image4_WholeImageWithOutlines(imageExportFolder, fileParams, flowFigureImageParams, imageA, xIdxA, yIdxA, 10)

% Individual Cells w/ Flow
Image5and6_SingleCellsWithFlow_and_WithFlowColoredByDirection(imageExportFolder, fileParams, flowFigureImageParams, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA, 10, 5);

% Individual Cells w/ Flow Colored by Direction
Image5and6_SingleCellsWithFlow_and_WithFlowColoredByDirection(imageExportFolder, fileParams, flowFigureImageParams, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA, 10, 6);

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