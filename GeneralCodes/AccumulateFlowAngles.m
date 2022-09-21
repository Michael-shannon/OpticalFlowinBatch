function [countList, angList] = AccumulateFlowAngles(vx, vy, mask, angRange, angStepSize)
angList = atan2(vy(mask(:) > 0), vx(mask(:) > 0));
if strcmp(angRange, '90')
    binEdges = 0:angStepSize:90;
    angList = asin(sin(acos(cos(angList)))); 
elseif strcmp(angRange, '360')
    binEdges = 0:angStepSize:360; 
end
angList = angList(:);
countList = histcounts(mod(180*angList(:)/pi, 360), binEdges);