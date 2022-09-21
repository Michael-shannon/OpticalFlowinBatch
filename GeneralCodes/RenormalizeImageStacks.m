function out = RenormalizeImageStacks(input, varargin)
input = double(input);
[l, w] = size(input);
if isempty(varargin)
    minMat = min(min(input, [], 1), [], 2);
    maxMat = max(max(input, [], 1), [], 2);
    out = (input - repmat(minMat, [l, w, 1]))./(repmat(maxMat - minMat, [l, w, 1]));
else
    minMat = zeros(1, 1, size(input, 3));
    maxMat = zeros(1, 1, size(input, 3));
    for i = 1:size(input, 3)
        mat = input(:, :, i);
        minMat(i) = prctile(mat(:), varargin{1});
        maxMat(i) = prctile(mat(:), varargin{2});
    end
    out = (input - repmat(minMat, [l, w, 1]))./(repmat(maxMat - minMat, [l, w, 1]));
    out(out(:) > 1) = 1;
    out(out(:) < 0) = 0;
end