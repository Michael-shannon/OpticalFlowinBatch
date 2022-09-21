function PlotOpticalFlow(OriginalImage, OpticalFlow, s, fac, varargin)
im = OriginalImage.Image(:, :, :, OriginalImage.ActinChannel);
vx = OpticalFlow.vxMat;
vy = OpticalFlow.vyMat;
% vx = imfilter(vx, fspecial('gaussian', 7, 1));
% vy = imfilter(vy, fspecial('gaussian', 7, 1));
rel = OpticalFlow.relMat;
flag = 0;
if length(varargin) == 1
    DifferenceImage = varargin{1};
    diff = DifferenceImage.smoothDiffImage;
    diffMask = diff > 0;
elseif length(varargin) == 2
    if ~isempty(varargin{1})
        DifferenceImage = varargin{1};
        diff = DifferenceImage.smoothDiffImage;
        diffMask = diff > 0;
    else
        diffMask = ones([size(im, 1), size(im, 2), size(im, 3) - 1], 'double');
    end
    fileName = varargin{2};
    v = VideoWriter(fileName); 
    v.FrameRate = 12;
    open(v);
    flag = 1;
    close all;
    figure; pause(5);
else
    diffMask = ones([size(im, 1), size(im, 2), size(im, 3) - 1], 'double');
end
    
mag = sqrt(vx.^2 + vy.^2);
[vx, vy] = DeclutterQuiver(vx, vy, s);
vx = vx./mag;
vy = vy./mag;
mag = RenormalizeImage(mag, 1);
relMask = rel > 0.01*max(rel(:));
vxShow = s*fac*vx.*mag.*relMask;
vyShow = s*fac*vy.*mag.*relMask;

vxShow = vxShow.*diffMask;
vyShow = vyShow.*diffMask;

periodicxcmap = parula(64);
periodicxcmap = circshift([flipud(periodicxcmap); periodicxcmap; flipud(periodicxcmap); periodicxcmap], size(periodicxcmap, 1));

h1 = imagesc(im(:, :, 1), [min(im(:)), max(im(:))]); 
hold on;
h2 = quiver(vxShow(:, :, 1), vyShow(:, :, 1), 0, 'g'); 
% h2 = ColorQuiver(vxShow(:, :, 1), vyShow(:, :, 1), periodicxcmap, 1);
hold off;
for i = 1:(size(im, 3) - 1)
    set(h1, 'cdata', im(:, :, i)); colormap gray;
    set(h2, 'udata', vxShow(:, :, i), 'vdata', vyShow(:, :, i));
%     ColorQuiver(vxShow(:, :, i), vyShow(:, :, i), periodicxcmap, 1, h2);
    axis equal tight off;
    drawnow;
    if flag == 1
        f = getframe(gca);
        writeVideo(v, f);
    end
end
if flag == 1
    close(v);
end