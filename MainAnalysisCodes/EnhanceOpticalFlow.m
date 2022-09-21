function EnhanceOpticalFlow(exportFolder, enhOptFlowParams, relMat, smoothDiffImage)
% Params
minR = enhOptFlowParams.minR;
maxR = enhOptFlowParams.maxR;
enhSig = enhOptFlowParams.enhSig;
enhNumSig = enhOptFlowParams.enhNumSig;
enhBgSubSig = enhOptFlowParams.enhBgSubSig;
rArray = minR:maxR;

% Enhance Optical Flow
filImage = relMat.*smoothDiffImage;
enhMat = zeros([size(filImage), length(rArray)], 'single');
for r = 1:length(rArray)
    [a, b, c, d] = DecomposedMexiHat(rArray(r));
    padSize = ceil(3*rArray(r));
    dummy = padarray(filImage, [padSize, padSize, 0], 0);
    dummy = imfilter(imfilter(dummy, a), b) + imfilter(imfilter(dummy, c), d);
    enhMat(:, :, :, r) = dummy((padSize + 1):(end - padSize), (padSize + 1):(end - padSize), :);
end
enhMat = max(enhMat, [], 4);
[a, b, c] = DecomposedGaussian3(enhSig, enhNumSig);
smoothEnhMat = imfilter(imfilter(imfilter(smoothDiffImage.*enhMat, a), b), c);
[a, b, c] = DecomposedGaussian3(enhBgSubSig, enhNumSig);
smoothEnhMat = smoothEnhMat - imfilter(imfilter(imfilter(smoothEnhMat, a), b), c);
smoothEnhMat(smoothEnhMat(:) < 0) = 0;
smoothEnhMat = RenormalizeImage(smoothEnhMat);

% Make file
EnhancedImage.EnhancedRelMat = enhMat;
EnhancedImage.SmoothEnhancedRelMat = smoothEnhMat;
EnhancedImage.enhOptFlowParams = enhOptFlowParams;

% Save
save([exportFolder, 'EnhancedImage.mat'], 'EnhancedImage', '-v7.3');