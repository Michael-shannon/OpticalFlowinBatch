function ImportImage(importFolder, exportFolder, fileName)
info = imfinfo([importFolder, fileName]);
info = info(1).ImageDescription; 
automateFlag = 1; %changed
if automateFlag == 1
    %% Automated
%     ChLoc = strfind(info, 'channels');
%     FrLoc = strfind(info, 'frames');
%     numChannels = str2double(info(ChLoc + 9));
%     numFrames = str2double(info(FrLoc + (7:9)));
    numChannels = 1;
    numFrames = 120; %THIS THIS NEEDS CHANGED MANUALLY - MJS
elseif automateFlag == 0
    %% Manual
    disp(' ');
    disp(info);
    disp(' ');
    numChannels = input('Number of Channels? ');
   % numChannels = 1;
    disp(' ');
    numFrames = input('Number of Frames? ');
   % numFrames = 20;
    disp(' ');
%     startFrame = input('What is the First Frame? ');
%     disp(' ');
%     endFrame = input('What is the Last Frame? ');
%     disp(' ');
end
if numChannels == 1
    image = imread([importFolder, fileName], 1);
    image = zeros([size(image), numFrames, numChannels]);
    for i = 1:numFrames
        image(:, :, i) = imread([importFolder, fileName], i);
%         image = imread([importFolder, fileName](i).name);
%         I{i}=double(image);
    end
    actinChannel = 1;
elseif numChannels == 2
    image = imread([importFolder, fileName], 1);
    image = zeros([size(image), numFrames, numChannels]);
    for i = 1:numFrames
        if mod(i, 10) == 0
            fprintf(['Frame ', num2str(i), ' of ', num2str(numFrames), '\n']);
        end
        for j = 1:numChannels
            image(:, :, i, j) = imread([importFolder, fileName], 2*(i - 1) + j);
        end
    end
    figure;
    subplot(1, 2, 1);
    imagesc(max(image(:, :, :, 1), [], 3));
    title('Channel 1');
    axis equal; axis off;
    subplot(1, 2, 2);
    imagesc(max(image(:, :, :, 2), [], 3));
    title('Channel 2');
    axis equal; axis off;
    disp(' ');
    actinChannel = input('Which is the actin channel? ');
    disp(' ');
    close all;
    if (actinChannel ~= 1) && (actinChannel ~= 2)
        error('Unexpected channel!');
    end
elseif numChannels == 3
    image = imread([importFolder, fileName], 1);
    image = zeros([size(image), numFrames, numChannels]);
    for i = 1:numFrames
        if mod(i, 10) == 0
            fprintf(['Frame ', num2str(i), ' of ', num2str(numFrames), '\n']);
        end
        for j = 1:numChannels
            image(:, :, i, j) = imread([importFolder, fileName], 3*(i - 1) + j);
        end
    end
    figure;
    subplot(1, 3, 1);
    imagesc(max(image(:, :, :, 1), [], 3));
    title('Channel 1');
    axis equal; axis off;
    subplot(1, 3, 2);
    imagesc(max(image(:, :, :, 2), [], 3));
    title('Channel 2');
    axis equal; axis off;
    subplot(1, 3, 3);
    imagesc(max(image(:, :, :, 3), [], 3));
    title('Channel 3');
    axis equal; axis off;
    disp(' ');
    actinChannel = input('Which is the actin channel? ');
    disp(' ');
    close all;
    if (actinChannel ~= 1) && (actinChannel ~= 2)
        error('Unexpected channel!');
    end
else
    error('Unexpected numChannels!');
end
OriginalImage.Image = uint16(image);
OriginalImage.NumChannels = numChannels;
OriginalImage.NumFrames = numFrames;
OriginalImage.ActinChannel = actinChannel;
try
    save([exportFolder, 'OriginalImage.mat'], 'OriginalImage');
catch
    save([exportFolder, 'OriginalImage.mat'], 'OriginalImage', '-v7.3');
end