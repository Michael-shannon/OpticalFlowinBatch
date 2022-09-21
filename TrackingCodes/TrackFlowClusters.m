function TrackFlowClusters(exportFolder, clusterTrackParams, diffImage, enhImage, optFlow)
%% Create folder
trackFolder = [exportFolder, 'TrackFigure', filesep];
if ~exist(trackFolder, 'dir')
    mkdir(trackFolder);
end

%% Import params
pxPerMicron = clusterTrackParams.pxPerMicron;
clusterFil = clusterTrackParams.clusterFil;
peakThresh = clusterTrackParams.peakThresh;
peakSize = clusterTrackParams.peakSize;
trackMaxDisp = clusterTrackParams.trackMaxDisp;
trackMinLength = clusterTrackParams.trackMinLength;

%% Create cluster image
% Set up flow images
vx = optFlow.vxMat;
vy = optFlow.vyMat;
mag = sqrt(vx.^2 + vy.^2); 
vx = vx./mag; 
vy = vy./mag;

% Calculate flow alignment
filFlow = (vx.*imfilter(vx, clusterFil) + vy.*imfilter(vy, clusterFil)).^2;

% Calculate cluster image
clusterIm = double(enhImage).*filFlow.*double(diffImage > 0);

%% Find peaks in cluster image
xyt = [];
for i = 1:size(clusterIm, 3)
    pks = pkfnd(clusterIm(:, :, i), peakThresh, peakSize);
    if isempty(pks)
        pks2 = [];
    else
        pks2 = cntrd(clusterIm(:, :, i), pks, peakSize);
        if isempty(pks2)
            pks2 = [];
        else
            pks2 = pks2(:, [1, 2]);
        end
    end
    xyt = [xyt; [pks2, zeros(size(pks2, 1), 1) + i]]; %#ok<AGROW>
end

%% Track peaks
tracks = track(xyt, trackMaxDisp);

%% Save results
FlowClusterTracks.peaks = xyt;
FlowClusterTracks.tracks = tracks;
FlowClusterTracks.clusterTrackParams = clusterTrackParams;
save([exportFolder, 'FlowClusterTracks.mat'], 'FlowClusterTracks');
end

