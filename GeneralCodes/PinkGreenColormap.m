function cmap = PinkGreenColormap(numColors)
vec = linspace(0, 1, round(numColors/2))';
cmap = [vec, ones(size(vec)), vec; ...
    ones(size(vec)), flipud(vec), ones(size(vec))];