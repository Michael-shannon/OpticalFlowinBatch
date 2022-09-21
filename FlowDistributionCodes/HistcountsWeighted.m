function weightedCounts = HistcountsWeighted(data, weights, edges)
if ~isequal(size(data), size(weights))
    error('"data" and "weights" not the same size.'); 
end
[~, ~, bins] = histcounts(data(:), edges); 
weightedCounts = zeros(1, length(edges) - 1);
for i = 1:length(weightedCounts)
    weightedCounts(i) = sum(weights(bins(:) == i)); 
end