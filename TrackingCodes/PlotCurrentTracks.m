function PlotCurrentTracks(tracks, frameNum, trackColor, lineWidth, frameFlip, varargin)
if isempty(varargin)
    %% Whole Image Plotting
    trackIDs = unique(tracks(tracks(:, 3) == frameNum, 4));
    for trackIdx = 1:length(trackIDs)
        currTrack = tracks(tracks(:, 4) == trackIDs(trackIdx), :);
        currTrack = currTrack(currTrack(:, 3) <= frameNum, :);
        if min(currTrack(:, 3)) <= frameFlip
            currTrackColor = trackColor;
        else
            currTrackColor = [0 1 0];%1 - trackColor;
        end
        plot(currTrack(:, 1), currTrack(:, 2), 'color', currTrackColor, 'linewidth', lineWidth);
    end
    
    oldTrackIDs = unique(tracks(tracks(:, 3) < frameNum, 4));
    oldTrackIDs = oldTrackIDs(~ismember(oldTrackIDs, trackIDs));
    for trackIdx = 1:length(oldTrackIDs)
        currTrack = tracks(tracks(:, 4) == oldTrackIDs(trackIdx), :);
        if frameNum - max(currTrack(:, 3)) <= 4
            colorDecayFac = (5 - (frameNum - max(currTrack(:, 3))))/5;
            if min(currTrack(:, 3)) <= frameFlip
                currTrackColor = trackColor;
            else
                currTrackColor = [0 1 0];%1 - trackColor;
            end
%             plot(currTrack(:, 1), currTrack(:, 2), 'color', currTrackColor*colorDecayFac, 'linewidth', lineWidth); %<------------- FIX THIS
            plot(currTrack(:, 1), currTrack(:, 2), 'color', currTrackColor, 'linewidth', lineWidth)
        end
    end
    
else
    %% Single Cell Plotting
    
    % Import varargin
    xIdx = varargin{1};
    yIdx = varargin{2};
    thetaInDegrees = varargin{3};
    thetaInRadians = varargin{4};
    
    % Adjust tracks
    currX = tracks(:, 1);
    currY = tracks(:, 2);
    newX = currX*cos(thetaInRadians) - currY*sin(thetaInRadians);
    newY = currX*sin(thetaInRadians) + currY*cos(thetaInRadians);
    tracks(:, 1) = newX;
    tracks(:, 2) = newY;
    
    % Plot Tracks
    trackIDs = unique(tracks(tracks(:, 3) == frameNum, 4));
    for trackIdx = 1:length(trackIDs)
        currTrack = tracks(tracks(:, 4) == trackIDs(trackIdx), :);
        currTrack = currTrack(currTrack(:, 3) <= frameNum, :);
        currX = currTrack(:, 1);
        currY = currTrack(:, 2);
        flag = double(currX < min(yIdx)) + double(currY < min(xIdx)) + ...
            double(currX > max(yIdx)) + double(currY > max(xIdx)) > 0;
        currX(flag) = [];
        currY(flag) = [];
        if min(currTrack(:, 3)) <= frameFlip
            currTrackColor = trackColor;
        else
            currTrackColor = [0 1 0];%1 - trackColor;
        end
        plot(currX + 1 - min(yIdx), currY + 1 - min(xIdx), 'color', currTrackColor, 'linewidth', lineWidth);
    end
    
    oldTrackIDs = unique(tracks(tracks(:, 3) < frameNum, 4));
    oldTrackIDs = oldTrackIDs(~ismember(oldTrackIDs, trackIDs));
    for trackIdx = 1:length(oldTrackIDs)
        currTrack = tracks(tracks(:, 4) == oldTrackIDs(trackIdx), :);
        if frameNum - max(currTrack(:, 3)) <= 4
            currX = currTrack(:, 1);
            currY = currTrack(:, 2);
            flag = double(currX < min(yIdx)) + double(currY < min(xIdx)) + ...
                double(currX > max(yIdx)) + double(currY > max(xIdx)) > 0;
            currX(flag) = [];
            currY(flag) = [];
            colorDecayFac = (5 - (frameNum - max(currTrack(:, 3))))/5;
            if min(currTrack(:, 3)) <= frameFlip
                currTrackColor = trackColor;
            else
                currTrackColor = [0 1 0];%1 - trackColor;
            end
%             plot(currX + 1 - min(yIdx), currY + 1 - min(xIdx), 'color', currTrackColor*colorDecayFac, 'linewidth', lineWidth); %<---------------- FIX THIS TOO
            plot(currX + 1 - min(yIdx), currY + 1 - min(xIdx), 'color', currTrackColor, 'linewidth', lineWidth); 
        end
    end
    
end