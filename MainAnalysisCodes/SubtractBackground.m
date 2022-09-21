function SubtractBackground(exportFolder, bgSubParams, origImage)
% Params
bgSubSig = bgSubParams.bgSubSig;
bgSubOneSidedNumSig = bgSubParams.bgSubOneSidedNumSig;
bgSubPadSize = bgSubParams.bgSubPadSize;
bgSubMeanFac = bgSubParams.bgSubMeanFac;

% Pad Image
bgSubImage = padarray(origImage, bgSubPadSize, bgSubMeanFac*mean(origImage(:)));

% Filter
[xFil, yFil, ~] = DecomposedGaussian3(bgSubSig, bgSubOneSidedNumSig);
bgSubImage = double(bgSubImage) - imfilter(imfilter(double(bgSubImage), xFil), yFil);
bgSubImage(bgSubImage(:) < 0) = 0;

% Normalize and unpad
bgSubImage = uint16((2^16 - 1)*(bgSubImage - min(bgSubImage(:)))/(max(bgSubImage(:)) - min(bgSubImage(:))));
bgSubImage = bgSubImage(...
    (bgSubPadSize(1) + 1):(end - bgSubPadSize(1)), ...
    (bgSubPadSize(2) + 1):(end - bgSubPadSize(2)), ...
    (bgSubPadSize(3) + 1):(end - bgSubPadSize(3)));

% Make mask
bgSubMask = imfill(imerode(imdilate(imbinarize(max(bgSubImage, [], 3)), ones(5)), ones(5)), 'holes');
info = regionprops(bgSubMask, 'Area');
areaList = sort([info.Area]);
if length(areaList) > 1
    bgSubMask = imfill(imdilate(bwareaopen(bgSubMask, areaList(end - 1)), ones(5)), 'holes');
end

% Make file
BackgroundSubtract.bgSubImage = bgSubImage;
BackgroundSubtract.bgSubMask = bgSubMask;
BackgroundSubtract.bgSubParams = bgSubParams;

% Save
save([exportFolder, 'BackgroundSubtract.mat'], 'BackgroundSubtract');