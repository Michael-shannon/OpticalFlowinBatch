function FigureB_NoImages(fileExportFolder, FigureBParams, imageAshow, vxMatShowA, vyMatShowA, relMatShowA)
xIdxB = FigureBParams.xIdx;
yIdxB = FigureBParams.yIdx;
imageBshow = cell(size(xIdxB));
vxMatShowB = cell(size(xIdxB));
vyMatShowB = cell(size(xIdxB));
relMatShowB = cell(size(xIdxB));
for i = 1:size(xIdxB, 1)
    for j = 1:size(xIdxB, 2)
        ix = xIdxB{i, j};
        iy = yIdxB{i, j};
        imageBshow{i, j} = imageAshow{i}(ix, iy, :);
        vxMatShow = vxMatShowA{i}(ix, iy, :);
        vyMatShow = vyMatShowA{i}(ix, iy, :);
        vxMatShowB{i, j} = vxMatShow;
        vyMatShowB{i, j} = vyMatShow;
        relMatShow = relMatShowA{i}(ix, iy, :);
        relMatShowB{i, j} = relMatShow;
    end
end
FigureBImages.ImageB = imageBshow;
FigureBImages.vxMatB = vxMatShowB;
FigureBImages.vyMatB = vyMatShowB;
FigureBImages.relMatB = relMatShowB; %#ok<STRNU>
save([fileExportFolder, 'FigureBImages.mat'], 'FigureBImages');
end