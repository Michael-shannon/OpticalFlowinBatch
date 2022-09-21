function FlowClusterTracksMovies(fileParams)
%% File Parameters
exportFolder = fileParams.exportFolder;
pxPerMicron = fileParams.pxPerMicron;
secBtwFrames = fileParams.secBtwFrames;
thetaInRadians = fileParams.thetaInRadians;
cmap = flipud(Rainbow(22)); cmap = cmap(3:end, :); 

%% Define folders
flowExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep];
trackExportFolder = [exportFolder, ...
    filesep, 'TrackFigure', ...
    filesep];

%% Load Files

% Original Image
load([exportFolder, 'OriginalImage.mat'], 'OriginalImage');

% Flow Figure Data
load([flowExportFolder, 'ImageA.mat'], 'imageA');
load([flowExportFolder, 'FigureAParams.mat'], 'FigureAParams');

% Cluster Track Data
load([exportFolder, 'FlowClusterTracks.mat'], 'FlowClusterTracks');

%% Process data

% Find "center of mass" of images
rotCMold = [size(OriginalImage.Image, 1)/2, size(OriginalImage.Image, 2)/2];
rotCMnew = [size(imageA, 1)/2, size(imageA, 2)/2];

% Rotate tracks
clusterTracks = FlowClusterTracks.tracks;
clusterTracks = ApplyMinTrackLength(clusterTracks, 10);
xTrackList = rotCMnew(1) + cos(thetaInRadians)*(clusterTracks(:, 2) - rotCMold(1)) - sin(thetaInRadians)*(clusterTracks(:, 1) - rotCMold(2)); 
yTrackList = rotCMnew(2) + sin(thetaInRadians)*(clusterTracks(:, 2) - rotCMold(1)) + cos(thetaInRadians)*(clusterTracks(:, 1) - rotCMold(2));
clusterTracks(:, 1) = yTrackList;
clusterTracks(:, 2) = xTrackList;
    
% Predefine parameters
numCells = length(FigureAParams.Masks);
numTracks = max(clusterTracks(:, 4));

%% Plot cell tracks
for cellNum = 1:numCells
    %% Find cell window
    currCellxIdx = FigureAParams.xIdx{cellNum};
    currCellyIdx = FigureAParams.yIdx{cellNum};
    currCellImage = imageA(currCellxIdx, currCellyIdx, :);
    
    %% Define tracks in window
    badIdx = unique(clusterTracks(...
        (clusterTracks(:, 1) < min(currCellyIdx)) + ...
        (clusterTracks(:, 2) < min(currCellxIdx)) + ...
        (clusterTracks(:, 1) > max(currCellyIdx)) + ...
        (clusterTracks(:, 2) > max(currCellxIdx)) > 0, 4));
    goodIdx = find(~ismember(1:numTracks, badIdx));
    currCellTracks = clusterTracks(ismember(clusterTracks(:, 4), goodIdx), :);
    currCellTracks(:, 1) = currCellTracks(:, 1) - min(currCellyIdx) + 1;
    currCellTracks(:, 2) = currCellTracks(:, 2) - min(currCellxIdx) + 1;
    
    %% Plot Tracks
    fileName = ['ClusterTrackMovie - Cell ', num2str(cellNum), 'of', num2str(numCells), '.avi'];
    clusterTrackImage = uint8(255*RenormalizeImage(currCellImage, 0.25));
    clusterTrackVels = CalculateVelocities(currCellTracks, pxPerMicron, secBtwFrames/60);
    clusterTrackVels = 1 + round(min(clusterTrackVels.AvgInstVelocity(:), 19));
    clusterTrackColors = cmap(clusterTrackVels, :);
    PlotClusterTrackMovie(trackExportFolder, fileName, clusterTrackImage, currCellTracks, clusterTrackColors, pxPerMicron, secBtwFrames);
    
end