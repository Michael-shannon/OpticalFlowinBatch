function smoothDist = TimeAverageDistSmoothing(dist, numSmoothedFrames)
%% Check numSmoothedFrames to be odd
if mod(numSmoothedFrames, 2) == 0
    error('numFrames needs to be odd');
end
%% Time Average Smooth
smoothDist = zeros(size(dist));
numFrames = size(dist, 1);
badIdx = (numSmoothedFrames - 1)/2;
for frameNum = 1:numFrames
    potIdx = (frameNum - badIdx):(frameNum + badIdx); 
    potIdx(potIdx(:) < 1) = []; 
    potIdx(potIdx(:) > numFrames) = [];
    smoothDist(frameNum, :) = mean(dist(potIdx, :), 1);
end