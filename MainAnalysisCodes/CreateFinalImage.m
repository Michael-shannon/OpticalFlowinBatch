function [diffIm, diffImBack] = CreateFinalImage(imageStack, corrPeaks)
diffIm = zeros(size(imageStack, 1), size(imageStack, 2), size(imageStack, 3) - 1);
factorArray = GetFactorArray(mean(corrPeaks), 1, std(corrPeaks)/mean(corrPeaks));
for i = 1:size(diffIm, 3)
    tempArray = factorArray(1:min(length(factorArray), size(diffIm, 3) - i + 1));
    tempArray = (1/norm(tempArray))*tempArray;
    temp_im = zeros(size(imageStack, 1), size(imageStack, 2), length(factorArray));
    for j = 1:length(tempArray)
        temp_im(:, :, j) = tempArray(j)*(double(imageStack(:, :, i + j)) - double(imageStack(:, :, i)));
    end
    diffIm(:, :, i) = sum(temp_im, 3);
end
if nargout == 2
    diffImBack = diffIm;
    diffImBack(diffImBack(:) > 0) = 0;
    diffIm(diffIm(:) < 0) = 0;
end
end