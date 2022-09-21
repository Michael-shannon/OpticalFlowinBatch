function Image4_WholeImageWithOutlines(imageExportFolder, fileParams, flowFigureImageParams, imageA, xIdx, yIdx, numMicrons)
%% Check exist
fileName = 'WholeImage_WithOutlines.png';

%% Import parameters

% File Params
pxPerMicron = fileParams.pxPerMicron;

% Flow Figure Params
frameNum = flowFigureImageParams.frameNum;
intGamma = flowFigureImageParams.intGamma;
intThresh = flowFigureImageParams.intThresh;
lineWidth = flowFigureImageParams.outlineLineWidth;

%% Create dispImage
dispImage = imageA(:, :, frameNum);
dispImage(dispImage(:) <= intThresh) = 0;
dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);

%% Produce output
h = figure;
imshow(dispImage);
colormap gray
axis equal
axis off
hold on;
for i = 1:length(xIdx)
    plot(yIdx{i}, min(xIdx{i}) + zeros(size(yIdx{i})), 'r', 'linewidth', lineWidth);
    plot(yIdx{i}, max(xIdx{i}) + zeros(size(yIdx{i})), 'r', 'linewidth', lineWidth);
    plot(min(yIdx{i}) + zeros(size(xIdx{i})), xIdx{i}, 'r', 'linewidth', lineWidth);
    plot(max(yIdx{i}) + zeros(size(xIdx{i})), xIdx{i}, 'r', 'linewidth', lineWidth);
end
hold off;

%% Add scale bar
barSize = numMicrons*pxPerMicron;
AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);

%% Save output
origPos = get(gcf, 'Position');
set(gcf, 'Position', [1, 41, 1920, 964]);
f = getframe(gca);
f = frame2im(f);
imwrite(f, [imageExportFolder, fileName], 'png');
set(gcf, 'Position', origPos);
close(h);