function angList = AccumulateFlowAngleList(vx, vy, mask, angRange)
angList = atan2(vy(mask(:) > 0), vx(mask(:) > 0));
if strcmp(angRange, '90')
    angList = asin(sin(acos(cos(angList)))); 
end
angList = angList(:);