function tracksOut = RotateTracks(tracksIn, thetaInRadians, origSize, newSize)
oldCM = origSize([1, 2])/2;
newCM = newSize([1, 2])/2;
x = newCM(1) + cos(thetaInRadians)*(tracksIn(:, 2) - oldCM(1)) - sin(thetaInRadians)*(tracksIn(:, 1) - oldCM(2));
y = newCM(2) + sin(thetaInRadians)*(tracksIn(:, 2) - oldCM(1)) + cos(thetaInRadians)*(tracksIn(:, 1) - oldCM(2));
tracksOut = tracksIn;
tracksOut(:, 1) = y;
tracksOut(:, 2) = x;