function corrPeaks = GetCorrPeaks(image,thresh)
num_samples = 25;
if (thresh < 0)||(thresh > 1)
    error('Inappropriate Threshold');
end
rand_array = randi([1, size(image, 3)], num_samples);
corrPeaks = zeros(length(rand_array),1);
for i = 1:length(rand_array)
    im1_top = image(:,:,rand_array(i)) - nanmean(nanmean(image(:,:,rand_array(i))));
    im1_bot = sqrt(nansum(nansum(im1_top.^2))); 
    for j = 1:max(30,round(0.1*size(image,3)))
        im2_top = image(:,:,rand_array(i) + j) - nanmean(nanmean(image(:,:,rand_array(i) + j)));
        im2_bot = sqrt(nansum(nansum(im2_top.^2))); 
        imCorr = nansum(nansum(im1_top.*im2_top))/im1_bot/im2_bot;
        if imCorr < thresh
            corrPeaks(i) = j;
            break
        else
            corrPeaks(i) = nan;
        end
    end
end
corrPeaks(isnan(corrPeaks)) = [];
if isempty(corrPeaks)
    corrPeaks = 1; 
end
end