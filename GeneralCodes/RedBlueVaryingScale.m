function cmap = RedBlueVaryingScale(numColors, minVal, maxVal)
ss = (maxVal - minVal)/numColors;
numR = ceil(abs(minVal)/ss) - 1; 
numB = ceil(abs(maxVal)/ss) - 1;
bluSeg = 1 - linspace(numB/max(numB, numR), 0, numB); 
redSeg = 1 - linspace(numR/max(numB, numR), 0, numR);
redLine = [ones(length(redSeg), 1); 1; flipud(bluSeg(:))];
grnLine = [redSeg(:); 1; flipud(bluSeg(:))];
bluLine = [redSeg(:); 1; ones(length(bluSeg), 1)];
cmap = [redLine, grnLine, bluLine];
end