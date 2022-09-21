function tracksOut = IsolateTracks(tracksIn, mask)
[ix, iy] = find(mask);
y = [min(ix), max(ix)]; 
x = [min(iy), max(iy)];
badIdxs = [tracksIn(:, 1) < x(1), tracksIn(:, 1) > x(2), tracksIn(:, 2) < y(1), tracksIn(:, 2) > y(2)];
badIdxs = unique(tracksIn(sum(badIdxs, 2) > 0, 4));
tracksOut = tracksIn; 
for i = 1:length(badIdxs)
    tracksOut(tracksOut(:, 4) == badIdxs(i), :) = [];
end