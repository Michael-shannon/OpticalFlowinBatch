function cmap = Rainbow(n)

stdev = n/4;
m1 = n/4;
m2 = n/2;
m3 = 3*n/4;
x = 1:n;
y1 = exp(-(x - m1).^2/2/stdev/stdev); y1 = y1/max(y1(:));
y2 = exp(-(x - m2).^2/2/stdev/stdev); y2 = y2/max(y2(:));
y3 = exp(-(x - m3).^2/2/stdev/stdev); y3 = y3/max(y3(:));
cmap = [y1', y2', y3'];