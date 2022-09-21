function [allCountList, allAngList, trackCountList, trackAngList] = AccumulateTrackAngles(tracks, angRange, angStepSize)
if strcmp(angRange, '90') == 1
    allCountList = zeros(1, length(0:angStepSize:90) - 1);
    trackCountList = zeros(1, length(0:angStepSize:90) - 1);
elseif strcmp(angRange, '360') == 1
    allCountList = zeros(1, length(0:angStepSize:360) - 1);
    trackCountList = zeros(1, length(0:angStepSize:360) - 1);
end
idxs = unique(tracks(:, 4));
allAngList = [];
trackAngList = [];
for idx = 1:length(idxs)
    currIdx = idxs(idx);
    currTrack = tracks(tracks(:, 4) == currIdx, 1:3);
    allDiffs = currTrack(2:end, :) - currTrack(1:(end - 1), :);
    allAngs = atan2(allDiffs(:, 2), allDiffs(:, 1));
    trackDiff = currTrack(end, :) - currTrack(1, :);
    trackAngs = atan2(trackDiff(2), trackDiff(1));
    if strcmp(angRange, '90') == 1
        allAngs = asin(sin(acos(cos(allAngs))));
        trackAngs = asin(sin(acos(cos(trackAngs))));
    end
    allAngList = [allAngList(:); allAngs(:)];
    trackAngList = [trackAngList(:); trackAngs(:)];
    allAngs = 180*allAngs/pi;
    trackAngs = 180*trackAngs/pi;
    if strcmp(angRange, '90') == 1
        allCounts = histcounts(allAngs, 0:2.5:90);
        trackCount = histcounts(trackAngs, 0:2.5:90);
    elseif strcmp(angRange, '360') == 1
        allCounts = histcounts(allAngs, 0:2.5:360);
        trackCount = histcounts(mod(trackAngs, 360), 0:2.5:360);
    end
    allCountList = allCountList + allCounts;
    trackCountList = trackCountList + trackCount;
end