function Movie1and2_WholeImageWithFlow_and_WithFlowColoredByDirection(v, g1, g2, intIm, vxMat, vyMat, intGamma, barSize, secPerFrame, varargin)
numFrames = size(intIm, 3) - 1;
for frameNum = 1:numFrames
    %% Create dispImage
    dispImage = intIm(:, :, frameNum);
    dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
    dispImage = uint16((2^16 - 1)*RenormalizeImage(double(dispImage)).^intGamma);
    %% Produce Output
    g1.CData = dispImage;
    vxTemp = vxMat(:, :, frameNum);
    vyTemp = vyMat(:, :, frameNum);
    idx = find(~isnan(vxTemp));
    [ix, iy] = ind2sub(size(vxTemp), idx);
    if varargin{1} == 1
        set(g2, 'XData', iy, 'YData', ix, 'UData', vxTemp(idx), 'VData', vyTemp(idx));
    elseif varargin{1} == 2
        cmap = varargin{2};
        linewidth = varargin{3};
        ColorQuiver(vxTemp, vyTemp, cmap, linewidth, g2);
    end
    %% Add Scale Bar
    AddScaleBar([.95*size(dispImage, 1) - barSize, .95*size(dispImage, 1) - barSize/10, barSize, barSize/10]);
    %% Save Output
    drawnow;
    f = getframe(gca);
    %% Add Timer
    numMin = floor(secPerFrame*(frameNum - 1)/60);
    numSec = mod(secPerFrame*(frameNum - 1), 60);
    numDec = round(10*mod(numSec, 1))/10;
    numSec = sprintf('%02u', numSec);
    numMin = sprintf('%02u', numMin);
    numDec = num2str(numDec);
    f.cdata = insertText(f.cdata, [0, 0], [numMin, ':', numSec, '.', numDec], ...
        'FontSize', 18, ...
        'TextColor', 'white', ...
        'BoxColor', 'red', ...
        'BoxOpacity', 0);
    writeVideo(v, f);
end