function cutBounds = CutBounds(sz, bounds, buffer)
badBounds = [];
for i = 1:length(bounds)
    currBound = bounds{i};
    flag = double(currBound(:, 2) + buffer > sz(1)) + double(currBound(:, 1) + buffer > sz(2)) + ...
        double(currBound(:, 2) - buffer < 1) + double(currBound(:, 1) - buffer < 1) > 0;
    if sum(flag) > 0
        badBounds = [badBounds, i];
        continue;
    end
end
cutBounds = bounds;
cutBounds(badBounds) = [];