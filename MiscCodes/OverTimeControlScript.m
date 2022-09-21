%% Distributions "Over Time" Script
%  The goal of this script is to create "over time" distributions of the
%  flow directions.
%
%  This script is designed to be executed AFTER "ControlScript" has been
%  fully executed at least once. Thereafter, the only definitions needed
%  are in the pre-amble include "fileParams" and "flowDistParams".
%
%  Written by L. Campanello 4/14/2018

numSmoothedFrames = 15;

flowDistOverTimeParams.numSmoothedFrames = numSmoothedFrames;

FlowDistributionOverTime(fileParams, flowDistParams, flowDistOverTimeParams);