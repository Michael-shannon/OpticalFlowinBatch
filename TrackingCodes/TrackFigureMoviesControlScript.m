%% Flow Cluster Control Script

intPower = 0.9;
clusterFilSig = 3; 
clusterFil = fspecial('gaussian', 6*clusterFilSig + 1, clusterFilSig);
clusterFil(3*clusterFilSig + 1, 3*clusterFilSig + 1) = 0; clusterFil = clusterFil/sum(clusterFil(:));
cVec = (0.55:0.15:1)';
posThreshVec = 0.0001;%[0, 0.0001, 0.001, 0.005];
negThreshVec = 0;%[0, 0.005, 0.01, 0.1];
posThreshColor = [0, 0.5, 1];%[zeros(4, 1), cVec/2, cVec];
negThreshColor = [1, 0, 0.5];%[cVec, zeros(4, 1), cVec/2];
plotStyle = 1; % <----------- 1 = plotBounds, 2 = fillBounds
trackType = 1; % <----------- 1 = tracks, 2 = longTracks
minTrackLength = 2;
trackColor = [1, 0, 0];
lineWidth = 3.5;
frameFlip = 30; % <----------- Make "0" if unwanted

trackFigureMovieParams.intPower = intPower;
trackFigureMovieParams.clusterFilSig = clusterFilSig;
trackFigureMovieParams.clusterFil = clusterFil;
trackFigureMovieParams.posThreshVec = posThreshVec;
trackFigureMovieParams.negThreshVec = negThreshVec;
trackFigureMovieParams.posThreshColor = posThreshColor;
trackFigureMovieParams.negThreshColor = negThreshColor;
trackFigureMovieParams.plotStyle = plotStyle;
trackFigureMovieParams.trackType = trackType;
trackFigureMovieParams.minTrackLength = minTrackLength;
trackFigureMovieParams.trackColor = trackColor;
trackFigureMovieParams.lineWidth = lineWidth;
trackFigureMovieParams.frameFlip = frameFlip;

% TrackFigureMovies(fileParams, trackFigureMovieParams);

TrackFigureMoviesWithTracks(fileParams, trackFigureMovieParams);