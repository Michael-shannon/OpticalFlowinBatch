function FigureB_NoParams(fileExportFolder, numA, imageAshow, vxMatShowA, vyMatShowA, relMatShowA)
imageBmasks = cell(1);
xIdxB = cell(1);
yIdxB = cell(1);
for i = 1:numA
    h = figure;
    dispImage = mean(imageAshow{i}, 3);
    dispImage = RenormalizeImage(dispImage, .1);
    dispImage(dispImage(:) == 0) = mean(dispImage(dispImage(:) ~= 0));
    imagesc(dispImage);
    axis equal;
    disp(' ');
    numZooms = input('How many cell zoom-ins should be created? ');
    for j = 1:numZooms
        %% get the mask
        imageBmasks{i, j} = roipoly;
        [ix, iy] = find(imageBmasks{i, j});
        maskWidth = max(max(ix) - min(ix), max(iy) - min(iy));
        ix = min(ix):(min(ix) + maskWidth);
        iy = min(iy):(min(iy) + maskWidth);
        ix = ix + min(0, size(imageBmasks{i, j}, 1) - max(ix));
        iy = iy + min(0, size(imageBmasks{i, j}, 2) - max(iy));
        %% plot the mask
        hold on;
        plot(iy, min(ix) + zeros(size(iy)), 'r', 'linewidth', 1.5);
        plot(iy, max(ix) + zeros(size(iy)), 'r', 'linewidth', 1.5);
        plot(min(iy) + zeros(size(ix)), ix, 'r', 'linewidth', 1.5);
        plot(max(iy) + zeros(size(ix)), ix, 'r', 'linewidth', 1.5);
        hold off;
        %% save the mask
        xIdxB{i, j} = ix;
        yIdxB{i, j} = iy;
    end
    close(h);
end
FigureBParams.xIdx = xIdxB;
FigureBParams.yIdx = yIdxB;
save([fileExportFolder, 'FigureBParams.mat'], 'FigureBParams');
FigureB_NoImages(fileExportFolder, FigureBParams, imageAshow, vxMatShowA, vyMatShowA, relMatShowA)
end