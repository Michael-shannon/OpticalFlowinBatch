function TrackOFxMovie(origIm, flowTracks, vxMat, vyMat, clusterIm, fileName)
close all; 

%% INITIALIZE OBJECTS
% Padding
padSize = 1; 
vxMat = padarray(vxMat, [padSize, padSize, 0], 0); 
vyMat = padarray(vyMat, [padSize, padSize, 0], 0); 
clusterIm = padarray(clusterIm, [padSize, padSize, 0], 0); 

% Save movie
vv = VideoWriter([fileName, '.avi']); 
open(vv); 

% Colors
colorScheme = lines(max(flowTracks(:, 4))); 

% Images
imLeft = double(origIm(:, :, 1));
imRight = double(origIm(:, :, 1));
imLeft = uint8(255*RenormalizeImage(imLeft));
imRight = uint8(255*RenormalizeImage(imRight));
showIm = [imLeft, 255*ones(size(origIm, 1), padSize*2, 'uint8'), imRight];
dispFig = imshow(showIm); hold on; 
set(1, 'Position', [1, 41, 1920, 964]); drawnow; 

% Quiver plot
quiverFactor = 3; 
vxMat(mod(1:size(vxMat, 1), quiverFactor) ~= 0, :, :) = 0; 
vxMat(:, mod(1:size(vxMat, 2), quiverFactor) ~= 0, :) = 0; 
vyMat(mod(1:size(vyMat, 1), quiverFactor) ~= 0, :, :) = 0; 
vyMat(:, mod(1:size(vyMat, 2), quiverFactor) ~= 0, :) = 0;
vxLeft = zeros(size(vxMat(:, :, 1)));
vyLeft = zeros(size(vyMat(:, :, 1)));
vxRight = vxMat(:, :, 1);
vyRight = vyMat(:, :, 1);
vxVectors = [vxLeft, vxRight];
vyVectors = [vyLeft, vyRight];
vectorMask = [vxLeft, imbinarize(clusterIm(:, :, 1), 'adaptive')];
quiverPlot = quiver(vxVectors.*vectorMask, vyVectors.*vectorMask, 4*quiverFactor, 'Color', 'g');

for tIdx = 1:(size(origIm, 3) - 1)
    %% UPDATE IMAGES
    imLeft = double(origIm(:, :, tIdx));
    imRight = double(origIm(:, :, tIdx));
    imLeft = uint8(255*RenormalizeImage(imLeft));
    imRight = uint8(255*RenormalizeImage(imRight));
    showIm = [imLeft, 255*ones(size(origIm, 1), padSize*2, 'uint8'), imRight];
    set(dispFig, 'CData', showIm); hold on;
    
    %% PLOT TRACKS FOR TRACKS WITHIN TIME FRAME
    tIdxIds = unique(flowTracks(flowTracks(:, 3) == tIdx, 4));
    for idIdx = 1:length(tIdxIds)
        trackId = tIdxIds(idIdx);
        trackPath = flowTracks((flowTracks(:, 4) == trackId).*(flowTracks(:, 3) <= tIdx) > 0, [1, 2]);
        if size(trackPath, 1) == 0
        elseif size(trackPath, 1) == 1
            leadPoint{trackId} = scatter(padSize + trackPath(end, 1), padSize + trackPath(end, 2), 80, colorScheme(trackId, :), 'filled');  hold on;
            pathPlots{trackId} = plot(padSize + trackPath(:, 1), padSize + trackPath(:, 2), '-', 'Color', colorScheme(trackId, :), 'LineWidth', 3);  hold on;
        else
            set(leadPoint{trackId}, 'XData', padSize + trackPath(end, 1), 'YData', padSize + trackPath(end, 2));
            set(pathPlots{trackId}, 'XData', padSize + trackPath(:, 1), 'YData', padSize + trackPath(:, 2));
        end
    end
    
    %% PLOT OPTICAL FLOW VECTORS AND CLUSTERS
    vxRight = vxMat(:, :, tIdx);
    vyRight = vyMat(:, :, tIdx);
    vxVectors = [vxLeft, vxRight];
    vyVectors = [vyLeft, vyRight];
    vectorMask = [vxLeft, imbinarize(clusterIm(:, :, tIdx), 'adaptive')];
    set(quiverPlot, 'UData', vxVectors.*vectorMask, 'VData', vyVectors.*vectorMask); 
    
    %% DRAW IMAGE AND SAVE
    drawnow;
    frame = getframe(gca); 
    writeVideo(vv, frame); 
  
end
close(vv); 