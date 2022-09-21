%% Difference Image Control Script

% intPower = 0.9;
% clusterFilSig = 3; 
% clusterFil = fspecial('gaussian', 6*clusterFilSig + 1, clusterFilSig);
% clusterFil(3*clusterFilSig + 1, 3*clusterFilSig + 1) = 0; clusterFil = clusterFil/sum(clusterFil(:));
% cVec = (0.55:0.15:1)';
% posThreshVec = [0, 0.0001, 0.001, 0.005];
% negThreshVec = [0, 0.005, 0.01, 0.1];
% posThreshColor = [zeros(4, 1), cVec/2, cVec];
% negThreshColor = [cVec, zeros(4, 1), cVec/2];
% 
% trackFigureMovieParams.intPower = intPower;
% trackFigureMovieParams.clusterFilSig = clusterFilSig;
% trackFigureMovieParams.clusterFil = clusterFil;
% trackFigureMovieParams.posThreshVec = posThreshVec;
% trackFigureMovieParams.negThreshVec = negThreshVec;
% trackFigureMovieParams.posThreshColor = posThreshColor;
% trackFigureMovieParams.negThreshColor = negThreshColor;

DifferenceImageMovies(fileParams);