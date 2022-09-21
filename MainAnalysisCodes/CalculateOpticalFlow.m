function CalculateOpticalFlow(exportFolder, optFlowParams, image)
% Params
wSig = optFlowParams.WindowSigma;
relThresh = optFlowParams.ReliabilityThreshold;

% Calculate Optical Flow
vxMat = zeros(size(image, 1), size(image, 2), size(image, 3) - 1);
vyMat = zeros(size(image, 1), size(image, 2), size(image, 3) - 1);
relMat = zeros(size(image, 1), size(image, 2), size(image, 3) - 1);
for i = 1:(size(image, 3) - 1)
    [vx, vy, rel] = LKxOptFlow(image(:, :, i), image(:, :, i + 1), wSig, relThresh);
    vxMat(:, :, i) = vx;
    vyMat(:, :, i) = vy;
    relMat(:, :, i) = real(rel);
end

% Make file
OpticalFlow.vxMat = vxMat;
OpticalFlow.vyMat = vyMat;
OpticalFlow.relMat = relMat;
OpticalFlow.OpticalFlowParams = optFlowParams;

% Save
save([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow', '-v7.3');