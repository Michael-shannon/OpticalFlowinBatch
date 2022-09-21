function cqObj = ColorQuiver(vx, vy, cmap, lineWidth, varargin)
ang = atan2(vy, vx);
ang = mod(ang, 2*pi);
ang = RenormalizeImage(ang);
if isempty(varargin)
    numBins = size(cmap, 1);
    ang = round(ang*(numBins - 1)) + 1;
    angs = unique(ang(~isnan(ang)));
    cqObj = cell(length(angs), 1);
    for i = 1:length(angs)
        angMask = double(ang == angs(i));
        totalMask = angMask;
        [ix, iy] = find(totalMask);
        cqObj{i} = quiver(iy, ix, vx(totalMask(:) == 1), vy(totalMask(:) == 1), 0, 'Color', cmap(angs(i), :), 'LineWidth', lineWidth, 'autoscale', 'off', 'maxheadsize', 1);
    end
elseif length(varargin) == 1
    cqObj = varargin{1};
    numBins = length(cqObj);
    ang = round(ang*(numBins - 1)) + 1;
    angs = unique(ang(~isnan(ang)));
    for i = 1:length(angs)
        angMask = double(ang == angs(i));
        totalMask = angMask;
        [ix, iy] = find(totalMask);
        set(cqObj{i}, 'XData', iy, 'YData', ix, 'UData', vx(totalMask(:) == 1), 'VData', vy(totalMask(:) == 1));
    end
end