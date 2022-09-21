function DifferenceImageMovies(fileParams)
%% File Parameters
secBtwFrame = fileParams.secBtwFrames;
pxPerMicron = fileParams.pxPerMicron;
exportFolder = fileParams.exportFolder;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;

%% Input Parameters
numMicrons = 10;

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
load([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage');

% Flow Figure Data
fprintf('Loading Flow Figure Data\n');
load([fileExportFolder, 'ImageA.mat'], 'imageA');
load([fileExportFolder, 'FigureAImages.mat'], 'FigureAImages');
load([fileExportFolder, 'FigureBImages.mat'], 'FigureBImages');
load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
load([fileExportFolder, 'FigureBParams.mat'], 'FigureBParams');

%% Set Up Files - Whole Image
fprintf('Setting Up Cluster Images\n');

% Difference Image
origDiffImage = DifferenceImage.origDiffImage;
smoothDiffImage = DifferenceImage.smoothDiffImage;
o1 = min(origDiffImage(:));
o2 = max(origDiffImage(:));
s1 = min(smoothDiffImage(:));
s2 = max(smoothDiffImage(:));

%% Start Movie
v1 = VideoWriter([trackExportFolder, 'OriginalDifferenceImageMovie - WholeImage.avi']);
v2 = VideoWriter([trackExportFolder, 'SmoothDifferenceImageMovie - WholeImage.avi']);
v1.FrameRate = 12;
v2.FrameRate = 12;
open(v1);
open(v2);

cmap = RedBlueVaryingScale(256, o1, o2);
tempOrigDiffImage = RenormalizeImage(origDiffImage);

% for frameNum = 1:size(origDiffImage, 3)
%     %% Original Difference Image
%     
%     % Create Figure
%     h = figure;
%     
%     % Set Disp Image
%     dispImage = tempOrigDiffImage(:, :, frameNum);
%     dispImage = im2RGB(dispImage, cmap, 0, 1);
%     imshow(dispImage);
%     axis equal;
%     axis off;
%     set(h, 'Position', [1, 41, 1920, 964]);
%     
%     % Add Scale Bar
%     barSize = numMicrons*pxPerMicron;
%     AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
%     
%     % Save Output
%     drawnow;
%     f = getframe(gca);
%     
%     % Add Timer
%     numSec = mod(secPerFrame*(frameNum - 1), 60);
%     numSec = sprintf('%02u', numSec);
%     numMin = floor(secPerFrame*(frameNum - 1)/60);
%     numMin = sprintf('%02u', numMin);
%     f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
%         'FontSize', 18, ...
%         'TextColor', 'black', ...
%         'BoxColor', 'red', ...
%         'BoxOpacity', 0);
%     writeVideo(v1, f);
%     
%     % Close Figure
%     close(h);
%     
% end
% close(v1);
% 
% cmap = RedBlueVaryingScale(256, o1, o2);
% tempSmoothDiffImage = RenormalizeImage(smoothDiffImage);
% 
% for frameNum = 1:size(smoothDiffImage, 3)
%     %% Smooth Difference Image
%     
%     % Create Figure
%     h = figure;
%     
%     % Set Disp Image
%     dispImage = tempSmoothDiffImage(:, :, frameNum);
%     dispImage = im2RGB(dispImage, cmap, 0, 1);
%     imshow(dispImage);
%     axis equal;
%     axis off;
%     set(h, 'Position', [1, 41, 1920, 964]);
%     
%     % Add Scale Bar
%     barSize = numMicrons*pxPerMicron;
%     AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
%     
%     % Save Output
%     drawnow;
%     f = getframe(gca);
%     
%     % Add Timer
%     numSec = mod(secPerFrame*(frameNum - 1), 60);
%     numSec = sprintf('%02u', numSec);
%     numMin = floor(secPerFrame*(frameNum - 1)/60);
%     numMin = sprintf('%02u', numMin);
%     f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
%         'FontSize', 18, ...
%         'TextColor', 'black', ...
%         'BoxColor', 'red', ...
%         'BoxOpacity', 0);
%     writeVideo(v2, f);
%     
%     % Close Figure
%     close(h);
%     
% end
% close(v2);


%% Set Up Files - Single Cells
fprintf('Setting Up Cluster Images\n');

% Set "A" Params
xIdx = FigureAParams.xIdx;
yIdx = FigureAParams.yIdx;
numA = length(xIdx);

% Difference Images
origDiffImage = DifferenceImage.origDiffImage;
origDiffImage = imrotate(origDiffImage, thetaInDegrees);
smoothDiffImage = DifferenceImage.smoothDiffImage;
smoothDiffImage = imrotate(smoothDiffImage, thetaInDegrees);

%% Start Cell Loop

for cellNum = 1:numA
    
    tempOrigDiffImage = origDiffImage(xIdx{cellNum}, yIdx{cellNum}, :);
    tempSmoothDiffImage = smoothDiffImage(xIdx{cellNum}, yIdx{cellNum}, :);
    
    o1 = min(tempOrigDiffImage(:));
    o2 = max(tempOrigDiffImage(:));
    s1 = min(tempSmoothDiffImage(:));
    s2 = max(tempSmoothDiffImage(:));
    
    %% Start Movie
    v1 = VideoWriter([trackExportFolder, 'OriginalDifferenceImageMovie - Cell', num2str(cellNum), 'of', num2str(numA),'.avi']);
    v2 = VideoWriter([trackExportFolder, 'SmoothDifferenceImageMovie - Cell', num2str(cellNum), 'of', num2str(numA),'.avi']);
    v1.FrameRate = 12;
    v2.FrameRate = 12;
    open(v1);
    open(v2);
    
    cmap = RedBlueVaryingScale(256, o1, o2);
    tempOrigDiffImage = RenormalizeImage(tempOrigDiffImage);
    
    for frameNum = 1:size(tempOrigDiffImage, 3)
        %% Original Difference Image
        
        % Create Figure
        h = figure;
        
        % Set Disp Image
        dispImage = tempOrigDiffImage(:, :, frameNum);
        dispImage = im2RGB(dispImage, cmap, 0, 1);
        imshow(dispImage);
        axis equal;
        axis off;
        set(h, 'Position', [1, 41, 1920, 964]);
        
        % Add Scale Bar
        barSize = numMicrons*pxPerMicron;
        AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
        
        % Save Output
        drawnow;
        f = getframe(gca);
        
        % Add Timer
        numSec = mod(secBtwFrame*(frameNum - 1), 60);
        numSec = sprintf('%02u', numSec);
        numMin = floor(secBtwFrame*(frameNum - 1)/60);
        numMin = sprintf('%02u', numMin);
        f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
            'FontSize', 18, ...
            'TextColor', 'black', ...
            'BoxColor', 'red', ...
            'BoxOpacity', 0);
        writeVideo(v1, f);
        
        % Close Figure
        close(h);
        
    end
    close(v1);
    
    cmap = RedBlueVaryingScale(256, o1, o2);
    tempSmoothDiffImage = RenormalizeImage(tempSmoothDiffImage);
    
    for frameNum = 1:size(tempSmoothDiffImage, 3)
        %% Smooth Difference Image
        
        % Create Figure
        h = figure;
        
        % Set Disp Image
        dispImage = tempSmoothDiffImage(:, :, frameNum);
        dispImage = im2RGB(dispImage, cmap, 0, 1);
        imshow(dispImage);
        axis equal;
        axis off;
        set(h, 'Position', [1, 41, 1920, 964]);
        
        % Add Scale Bar
        barSize = numMicrons*pxPerMicron;
        AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
        
        % Save Output
        drawnow;
        f = getframe(gca);
        
        % Add Timer
        numSec = mod(secBtwFrame*(frameNum - 1), 60);
        numSec = sprintf('%02u', numSec);
        numMin = floor(secBtwFrame*(frameNum - 1)/60);
        numMin = sprintf('%02u', numMin);
        f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec], ...
            'FontSize', 18, ...
            'TextColor', 'black', ...
            'BoxColor', 'red', ...
            'BoxOpacity', 0);
        writeVideo(v2, f);
        
        % Close Figure
        close(h);
        
    end
    close(v2);
    
end