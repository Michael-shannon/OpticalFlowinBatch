function FlowClusterTracksData(fileParams, mainAnalysisParams)
%% File Parameters
exportFolder = fileParams.exportFolder;
pxPerMicron = fileParams.pxPerMicron;
secBtwFrames = fileParams.secBtwFrames;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;
minBtwFrame = secBtwFrames/60;

%% Main Analysis Parameters
minTrackLength = mainAnalysisParams.minTrackLength;

%% Define Folders
trackExportFolder = [exportFolder, ...
    filesep, 'TrackFigure', filesep];
if exist(trackExportFolder, 'dir')
else
    mkdir(trackExportFolder);
end

%% <-------- Could check exist of TracksData here

%% Load Files
load([exportFolder, 'FlowClusterTracks.mat'], 'FlowClusterTracks');

%% Create Long Tracks
allTracks = FlowClusterTracks.tracks;
longTracks = ApplyMinTrackLength(allTracks, minTrackLength);

%% Calculate Velocities
allVels = CalculateVelocities(allTracks, pxPerMicron, minBtwFrame);
longVels = CalculateVelocities(longTracks, pxPerMicron, minBtwFrame);

%% Save Results
FlowClusterTracksData.minTrackLength = minTrackLength;
FlowClusterTracksData.allTracks = allTracks;
FlowClusterTracksData.longTracks = longTracks;
FlowClusterTracksData.allVels = allVels;
FlowClusterTracksData.longVels = longVels;
save([trackExportFolder, 'FlowClusterTracksData.mat'], 'FlowClusterTracksData');

%% Plot Velocity Distributions
h = figure; 

minVal = 0;
ssVal = 0.25;
maxVal = 6;

data = [allVels.Velocities{:}]; 
histogram(data, minVal:ssVal:maxVal, 'Normalization', 'probability');
title('Distribution of Velocities: All Tracks')
xlabel('Velocity (\mum/min)');
ylabel('Normalized Count');
xlim([minVal, maxVal]);
drawnow;
saveas(gca, [trackExportFolder, 'AllTracks - Velocities.png'], 'png');

data = allVels.AvgInstVelocity;
histogram(data, minVal:ssVal:maxVal, 'Normalization', 'probability');
title('Distribution of Average Instantaneous Velocities: All Tracks')
xlabel('Velocity (\mum/min)');
ylabel('Normalized Count');
xlim([minVal, maxVal]);
drawnow;
saveas(gca, [trackExportFolder, 'AllTracks - AvgerageInstantaneousVelocities.png'], 'png');

data = allVels.AvgVelocity;
histogram(data, minVal:ssVal:maxVal, 'Normalization', 'probability');
title('Distribution of Average Velocities: All Tracks')
xlabel('Velocity (\mum/min)');
ylabel('Normalized Count');
xlim([minVal, maxVal]);
drawnow;
saveas(gca, [trackExportFolder, 'AllTracks - AvgerageVelocities.png'], 'png');

data = [longVels.Velocities{:}]; 
histogram(data, minVal:ssVal:maxVal, 'Normalization', 'probability');
title('Distribution of Velocities: Long Tracks')
xlabel('Velocity (\mum/min)');
ylabel('Normalized Count');
xlim([minVal, maxVal]);
drawnow;
saveas(gca, [trackExportFolder, 'LongTracks - Velocities.png'], 'png');

data = longVels.AvgInstVelocity;
histogram(data, minVal:ssVal:maxVal, 'Normalization', 'probability');
title('Distribution of Average Instantaneous Velocities: Long Tracks')
xlabel('Velocity (\mum/min)');
ylabel('Normalized Count');
xlim([minVal, maxVal]);
drawnow;
saveas(gca, [trackExportFolder, 'LongTracks - AvgerageInstantaneousVelocities.png'], 'png');

data = longVels.AvgVelocity;
histogram(data, minVal:ssVal:maxVal, 'Normalization', 'probability');
title('Distribution of Average Velocities: Long Tracks')
xlabel('Velocity (\mum/min)');
ylabel('Normalized Count');
xlim([minVal, maxVal]);
drawnow;
saveas(gca, [trackExportFolder, 'LongTracks - AvgerageVelocities.png'], 'png');