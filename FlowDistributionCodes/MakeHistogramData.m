function [x, y] = MakeHistogramData(xInt, yVec, int, distOption)
if distOption == 1
    %% Plot histograms from 0 to 90
    x = xInt:xInt:(90 - xInt);
    x = [x', x']';
    x = [0; x(:); 90];
    angList = xInt/2:xInt:(360 - xInt/2);
    angList = [angList; angList];
    angList = angList(:)*pi/180;
    angList = acos(cos(asin(sin(angList))));
    angList = round(angList*180/pi);
    [~, ~, angList] = unique(angList);
    yVec = circshift(yVec, 1);
    for i = 1:max(angList(:))
        y(i) = sum(yVec(angList(:) == i));
    end
    y = y(:)/sum(y(:));
    y = [y'; y']; 
    y = y(:);
    
elseif distOption == 2
    %% Plot histograms from 0 to 360
    x = xInt/2:xInt:(360 - xInt - xInt/2);
    x = [x', x']';
    x = [-xInt/2; x(:); 360 - xInt/2];
    y = circshift(yVec, 1);
    y = reshape(y, [int, length(y)/int]);
    y = sum(y, 1)/sum(y(:));
    y = [y', y']';
    y = y(:);
end
end