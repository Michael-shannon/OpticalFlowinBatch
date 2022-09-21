function CalculateDifferenceImage(exportFolder, diffImageParams, origImage, smoothImage)
% Params
corrThresh = diffImageParams.corrThresh;

% Calculate Difference Image
% corrPeaks = GetCorrPeaks(smoothImage, corrThresh);
corrPeaks = 3 + zeros(30, 1);
origDiffImage = CreateFinalImage(origImage, corrPeaks);
smoothDiffImage = CreateFinalImage(smoothImage, corrPeaks);

% Make file
DifferenceImage.origDiffImage = origDiffImage;
DifferenceImage.smoothDiffImage = smoothDiffImage;
DifferenceImage.diffImageParams = diffImageParams;

% Save
save([exportFolder, 'DifferenceImage.mat'], 'DifferenceImage', '-v7.3');