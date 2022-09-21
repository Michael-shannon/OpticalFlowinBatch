function SpiderPlotTracks(tracks)
idxs = unique(tracks(:, 4));
for idx = 1:length(idxs)
    currIdx = idxs(idx);
    currTrack = tracks(tracks(:, 4) == currIdx, 1:3);
    plot(currTrack(:, 1) - currTrack(1, 1), currTrack(:, 2) - currTrack(1, 2)); hold on;
end
axis equal;
axis([-50 50 -50 50]);
drawnow;