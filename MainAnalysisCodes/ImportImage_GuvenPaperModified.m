function ImportImage_GuvenPaperModified(importFolder, exportFolder, fileName)
load([importFolder, fileName]);
OriginalImage.Image = double(origImage);
OriginalImage.NumChannels = 1;
OriginalImage.NumFrames = size(origImage, 3);
OriginalImage.ActinChannel = 1;
try
    save([exportFolder, 'OriginalImage.mat'], 'OriginalImage');
catch
    save([exportFolder, 'OriginalImage.mat'], 'OriginalImage', '-v7.3');
end