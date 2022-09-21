clear all
close all
clc

%% Group histogram data

% Define an output folder - the folder which contains all of the
% "exportFolders"
outputFolder = ['D:\Google Drive\Optical Flow Analysis of Actin Waves\Output\HL60\'];

% Include any folder or file names that should NOT be included in the data
% grouping
badNameList = {'.', '..', '...', 'desktop.ini'};

% Define folderNameList
folderNameList = dir(outputFolder);
folderNameList = {folderNameList.name}';

% Filter out bad names
badIdx = zeros(size(folderNameList));
for badNameIdx = 1:length(badNameList)
    badIdx = badIdx + strcmp(folderNameList, badNameList(badNameIdx));
end
badIdx = find(badIdx);
folderNameList(badIdx) = [];

% Identify data groups
groupList = nan(size(folderNameList));
groupNameList = cell(size(folderNameList));
for nameIdx = 1:length(folderNameList)
    exportFolder = [outputFolder, filesep, folderNameList{nameIdx}, filesep];
    
    load([exportFolder, 'FileParameters.mat'], 'fileParameters');
    groupList(nameIdx) = fileParameters.dataGroup;
    groupNameList{nameIdx} = fileParameters.dataGroupName;
    
end
groupNums = unique(groupList);
numGroups = length(groupNums);

% Group the appropriate data
totalRawCounts = cell(numGroups, 2);
totalThreshCounts = cell(numGroups, 2);
totalRelCounts = cell(numGroups, 2);
totalMagCounts = cell(numGroups, 2);

for groupIdx = 1:numGroups
    
    % Set group
    groupNum = groupNums(groupIdx);
    groupIdxs = find(groupList == groupNum);
    
    % Label group
    totalRawCounts{groupIdx, 1} = groupNameList{groupIdxs};
    totalThreshCounts{groupIdx, 1} = groupNameList{groupIdxs};
    totalRelCounts{groupIdx, 1} = groupNameList{groupIdxs};
    totalMagCounts{groupIdx, 1} = groupNameList{groupIdxs};
    
    % Group data
    tempRawCounts = [];
    tempThrCounts = [];
    tempRelCounts = [];
    tempMagCounts = [];
    
    for fileNum = 1:length(groupIdxs)
        
        exportFolder = [outputFolder, filesep, folderNameList{fileNum}, filesep];
        
        fileExportFolder = [exportFolder, ...
            filesep, 'FlowFigure', ...
            filesep];
        histExportFolder = [fileExportFolder, ...
            filesep, 'HistogramData', ...
            filesep];
        
        numCells = length(dir([histExportFolder, filesep, '*.mat'])) - 1;
        for cellNum = 1:numCells
            histDataFilename = ['HistogramData_Cell', num2str(cellNum), 'of', num2str(numCells), '.mat'];
            load([histExportFolder, histDataFilename], 'HistogramData');
            
            tempRawCounts = [tempRawCounts; HistogramData.RawCounts];
            tempThrCounts = [tempThrCounts; HistogramData.ThreshCounts];
            tempRelCounts = [tempRelCounts; HistogramData.RelCountsWeighted];
            tempMagCounts = [tempMagCounts; HistogramData.MagCountsWeighted];
            
        end
        
    end
    
    totalRawCounts{groupIdx, 2} = [totalRawCounts{groupIdx, 2}; tempRawCounts];
    totalThreshCounts{groupIdx, 2} = [totalThreshCounts{groupIdx, 2}; tempThrCounts];
    totalRelCounts{groupIdx, 2} = [totalRelCounts{groupIdx, 2}; tempRelCounts];
    totalMagCounts{groupIdx, 2} = [totalMagCounts{groupIdx, 2}; tempMagCounts];
    
end

histDataExportFolder = [outputFolder, ...
    filesep, 'HistogramData', ...
    filesep];
if ~exist(histDataExportFolder, 'dir')
    mkdir(histDataExportFolder);
end

save([histDataExportFolder, 'TotalHistogramData.mat'], 'totalRawCounts', 'totalThreshCounts', 'totalRelCounts', 'totalMagCounts');

%


