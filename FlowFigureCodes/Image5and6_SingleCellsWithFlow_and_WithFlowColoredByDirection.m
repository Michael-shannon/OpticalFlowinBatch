function Image5and6_SingleCellsWithFlow_and_WithFlowColoredByDirection(imageExportFolder, fileParams, flowFigureImageParams, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA, numMicrons, imageNumber)
%% Import parameters

% File Params
pxPerMicron = fileParams.pxPerMicron;

% Flow Figure Params
frameNum = flowFigureImageParams.frameNum;
intGamma = flowFigureImageParams.intGamma;
intThresh = flowFigureImageParams.intThresh;
relGamma = flowFigureImageParams.relGamma;
relThreshFac = flowFigureImageParams.relThreshFac;
magGamma = flowFigureImageParams.magGamma;
magThresh = flowFigureImageParams.magThresh;
flowSig = flowFigureImageParams.flowSig;
spacing = flowFigureImageParams.spacingB;
spacingFac = flowFigureImageParams.spacingFacB;
lineWidth = flowFigureImageParams.vecLineWidthB;
cmap = flowFigureImageParams.periodicxcmap2;

%%
numCells = numA;
for cellNum = 1:numCells
    %% Check exist
    if imageNumber == 5
        fileName = ['Cell', num2str(cellNum), 'of', num2str(numCells), '_WithFlow.png'];
    elseif imageNumber == 6
        fileName = ['Cell', num2str(cellNum), 'of', num2str(numCells), '_WithFlow_ColoredByDirection.png'];
    else
        error('imageNumber provided is not recognized');
    end
    
    %% Create dispImage
    dispImage = imageAshow{cellNum}(:, :, frameNum);
    dispImage(dispImage(:) <= intThresh) = 0;
    dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
    dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);
    
    %% Define flow vectors
    
    % Set up vectors
    vxMatShow = vxMatShowA{cellNum}(:, :, frameNum);
    vyMatShow = vyMatShowA{cellNum}(:, :, frameNum);
    relMatShow = relMatShowA{cellNum}(:, :, frameNum);
    relThresh = relThreshFac*prctile(relMatShowA{cellNum}(:), 99);
    
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
    
    %% Produce output
    h = figure;
    imshow(dispImage);
    colormap gray
    axis equal
    axis off
    hold on;
    if imageNumber == 5
        quiver(vxMatShow, vyMatShow, 0, 'g', 'linewidth', lineWidth);
        fileName = ['Cell', num2str(cellNum), 'of', num2str(numCells), '_WithFlow.png'];
    elseif imageNumber == 6
        ColorQuiver(vxMatShow, vyMatShow, cmap, lineWidth);
        fileName = ['Cell', num2str(cellNum), 'of', num2str(numCells), '_WithFlow_ColoredByDirection.png'];
    else
        error('imageNumber provided is not recognized');
    end
    hold off;
    
    %% Add scale bar
    barSize = numMicrons*pxPerMicron;
    AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
    
    %% Save output
    origPos = get(gcf, 'Position');
    set(gcf, 'Position', [1, 41, 1920, 964]);
    f = getframe(gca);
    f = frame2im(f);
    imwrite(f, [imageExportFolder, fileName], 'png');
    set(gcf, 'Position', origPos);
    close(h);
    
end

