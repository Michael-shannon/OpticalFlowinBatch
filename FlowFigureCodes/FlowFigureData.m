%% Make Flow Figure Data
function FlowFigureData(fileParams)
%% Start FlowFigureData Script
fprintf('\n\n- - - Starting FlowFigureData - - -\n\n');

%% File Parameters
exportFolder = fileParams.exportFolder;
thetaInDegrees = fileParams.thetaInDegrees;
thetaInRadians = fileParams.thetaInRadians;
fileExportFolder = [exportFolder, ...
    filesep, 'FlowFigure', ...
    filesep];

%% Create Folder
if exist(fileExportFolder, 'dir')
else
    mkdir(fileExportFolder);
end

%% Full Image
if exist([fileExportFolder, 'ImageA.mat'], 'file')
    fprintf('- Figure Image Located\n');
else
    fprintf('- Creating First Figure Image\n');
    fprintf('  Loading Original Image\n');
    load([exportFolder, 'OriginalImage.mat'], 'OriginalImage');
    actinImage = OriginalImage.Image(:, :, :, OriginalImage.ActinChannel);
    imageA = imrotate(double(actinImage), thetaInDegrees);
    imageA = uint16(imageA);
    fprintf('  Saving First Figure Image\n');
    save([fileExportFolder, 'ImageA.mat'], 'imageA');
end

%% "Image A" (first mask)
if exist([fileExportFolder, 'FigureAImages.mat'], 'file')
    %% Params and Images
    fprintf('- Figure A Images and Parameters Located\n');
elseif exist([fileExportFolder, 'FigureAParams.mat'], 'file')
    %% Load Params
    fprintf('- Figure A Parameters Located\n');
    fprintf('  Loading Figure A Parameters\n');
    load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
    fprintf('  Loading First Figure Image\n');
    load([fileExportFolder, 'ImageA.mat'], 'imageA');
    fprintf('  Loading Optical Flow Vector Images\n');
    load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');
    vxMat = OpticalFlow.vxMat;
    vyMat = OpticalFlow.vyMat;
    relMat = OpticalFlow.relMat;
    %% Create and Load Images
    fprintf('  Creating Figure A Images\n');
    FigureA_NoImages(fileExportFolder, FigureAParams, imageA, vxMat, vyMat, relMat, thetaInDegrees, thetaInRadians)
else
    %% Create and Load Params and Images
    fprintf('- Loading First Figure Image\n');
    load([fileExportFolder, 'ImageA.mat'], 'imageA');
    fprintf('  Loading Optical Flow Vector Images\n');
    load([exportFolder, 'OpticalFlow.mat'], 'OpticalFlow');
    vxMat = OpticalFlow.vxMat;
    vyMat = OpticalFlow.vyMat;
    relMat = OpticalFlow.relMat;
    fprintf('  Creating Figure A Images and Parameters\n');
    FigureA_NoParams(fileExportFolder, imageA, vxMat, vyMat, relMat, thetaInDegrees, thetaInRadians)
end

%% Image B (second masks)
if exist([fileExportFolder, 'FigureBImages.mat'], 'file')
    %% Load Params and Images
    fprintf('- Figure B Images and Parameters Located\n');
elseif exist([fileExportFolder, 'FigureBParams.mat'], 'file')
    %% Load Params
    fprintf('- Figure B Parameters Located\n');
    fprintf('  Loading Figure B Parameters\n');
    load([fileExportFolder, 'FigureBParams.mat'], 'FigureBParams');
    fprintf('  Loading Figure A Images and Parameters\n');
    load([fileExportFolder, 'FigureAImages.mat'], 'FigureAImages');
    load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
    imageAshow = FigureAImages.ImageA;
    vxMatShowA = FigureAImages.vxMatA;
    vyMatShowA = FigureAImages.vyMatA;
    relMatShowA = FigureAImages.relMatA;
    fprintf('  Creating Figure B Images\n');
    FigureB_NoImages(fileExportFolder, FigureBParams, imageAshow, vxMatShowA, vyMatShowA, relMatShowA);
else
    %% Create and Load Params and Images
    fprintf('- Loading Figure A Images and Parameters\n');
    load([fileExportFolder, 'FigureAImages.mat'], 'FigureAImages');
    load([fileExportFolder, 'FigureAParams.mat'], 'FigureAParams');
    imageAshow = FigureAImages.ImageA;
    vxMatShowA = FigureAImages.vxMatA;
    vyMatShowA = FigureAImages.vyMatA;
    relMatShowA = FigureAImages.relMatA;
    numA = length(FigureAParams.xIdx);
    fprintf('  Creating Figure A Images and Parameters\n');
    FigureB_NoParams(fileExportFolder, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA);
end
end
