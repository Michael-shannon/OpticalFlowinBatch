function PlotClusterTrackMovie(movieExportFolder, fileName, image, tracks, trackColors, pxPerMicron, secBtwFrames)
close all
%% Parse inputs
fullIdxList = unique(tracks(:, 4));
pointSize = 40; 
lineWidth = 2; 
numMicrons = 10;

%% Initialize

% Initialize figure
h = figure;
g1 = imshow(image(:, :, 1)); hold on;
set(h, 'Position', [1, 1, 1920, 1080]);

% Initialize movie
v = VideoWriter([movieExportFolder, fileName]); 
v.FrameRate = 12;
open(v);

%% Plot Tracks
for frameNum = 1:size(image, 3)
    %% Update image
    set(g1, 'CData', image(:, :, frameNum)); hold on;
    
    %% Add scale bar
    barSize = numMicrons*pxPerMicron;
    AddScaleBar([.95*size(image, 1) - barSize, .95*size(image, 1) - barSize/10, barSize, barSize/10]); hold on; 
    
    %% Plot and/or update tracks
    idxList = unique(tracks(tracks(:, 3) == frameNum, 4));
    for idxNum = 1:length(idxList)      
        currIdx = idxList(idxNum);
        currPath = tracks(double(tracks(:, 4) == currIdx).*double(tracks(:, 3) <= frameNum) > 0, [1, 2]);
        if size(currPath, 1) == 0
            continue;
        elseif size(currPath, 1) == 1
            g2{fullIdxList == currIdx} = scatter(currPath(1), currPath(2), pointSize, trackColors(fullIdxList == currIdx, :), 'filled'); hold on; 
            g3{fullIdxList == currIdx} = plot(currPath(1), currPath(2), '-', 'Color', trackColors(fullIdxList == currIdx, :), 'LineWidth', lineWidth); hold on;
        else
            set(g2{fullIdxList == currIdx}, 'XData', currPath(end, 1), 'YData', currPath(end, 2));
            set(g3{fullIdxList == currIdx}, 'XData', currPath(:, 1), 'YData', currPath(:, 2));
        end
    end
    
    %% Store axis
    drawnow; 
    currFrame = getframe(gca);
    
    %% Add timer
    numMin = floor(secBtwFrames*(frameNum - 1)/60);
    numSec = mod(secBtwFrames*(frameNum - 1), 60);
    numDec = round(10*mod(numSec, 1))/10;
    numSec = sprintf('%02u', numSec);
    numMin = sprintf('%02u', numMin);
    numDec = num2str(numDec);
    currFrame.cdata = insertText(currFrame.cdata, [0, 0], [numMin, ':', numSec, '.', numDec], ...
        'FontSize', 18, ...
        'TextColor', 'white', ...
        'BoxColor', 'red', ...
        'BoxOpacity', 0);
    
    %% Save output
    writeVideo(v, currFrame);
    
end
close(v);