function [vx, vy, vz, relMat] = LKxOptFlow3(I1,I2,sig,thresh)

if nargin == 2
    sig = 3; 
    thresh = 0;
elseif nargin == 3
    thresh = 0; 
end

[a, b, c] = DecomposedGaussian3(sig, 6);

I1 = double(I1);
I2 = double(I2);

dxI = I1 - circshift(I1, [0, 1, 0]); dxI(:, 1, :) = 0;
dyI = I1 - circshift(I1, [1, 0, 0]); dyI(1, :, :) = 0;
dzI = I1 - circshift(I1, [0, 0, 1]); dzI(:, :, 1) = 0;
dtI=I2-I1;

wdx2=imfilter(imfilter(imfilter(dxI.^2, a), b), c);
wdxy=imfilter(imfilter(imfilter(dxI.*dyI, a), b), c);
wdy2=imfilter(imfilter(imfilter(dyI.^2, a), b), c);
wdtx=imfilter(imfilter(imfilter(dxI.*dtI, a), b), c);
wdty=imfilter(imfilter(imfilter(dyI.*dtI, a), b), c);

trace = wdx2 + wdy2;
determinant=(wdx2.*wdy2)-(wdxy.^2);

e1=(trace + sqrt(trace.^2 - 4*determinant))/2;
e2=(trace - sqrt(trace.^2 - 4*determinant))/2;
relMat=min(e1,e2);

vx=((determinant + eps).^-1).*((wdy2.*-wdtx)+(-wdxy.*-wdty));
vy=((determinant + eps).^-1).*((-wdxy.*-wdtx)+(wdx2.*-wdty));
vx=vx.*(relMat > thresh);
vy=vy.*(relMat > thresh);