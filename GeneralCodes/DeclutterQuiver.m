function [vx, vy] = DeclutterQuiver(vx, vy, s)
vx(mod(1:size(vx, 1), s) ~= 0, :, :) = 0;
vx(:, mod(1:size(vx, 2), s) ~= 0, :) = 0;
vy(mod(1:size(vy, 1), s) ~= 0, :, :) = 0;
vy(:, mod(1:size(vy, 2), s) ~= 0, :) = 0;
