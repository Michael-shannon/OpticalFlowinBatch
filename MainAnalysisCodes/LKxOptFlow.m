function [vx, vy, relMat] = LKxOptFlow(I1,I2,sig,thresh)

if nargin == 2
    sig = 3; 
    thresh = 0;
elseif nargin == 3
    thresh = 0; 
end

sz = ceil(6*sig + 1) + mod(ceil(6*sig + 1) + 1, 2);
w=fspecial('gaussian', sz, sig);

I1 = double(I1);
I2 = double(I2);

% [dxI,dyI]=imgradientxy(I1,'central');
f = exp(-(-3*sig:3*sig).^2/2/sig/sig);
f = f/sum(f);
g = (-3*sig:3*sig)/sig/sig;
dxI = imfilter(I1, f.*g);
dyI = imfilter(I1, (f.*g)');
dtI=I2-I1;

wdx2=imfilter((dxI.^2),w);
wdxy=imfilter((dxI.*dyI),w);
wdy2=imfilter((dyI.^2),w);
wdtx=imfilter((dxI.*dtI),w);
wdty=imfilter((dyI.*dtI),w);

trace = wdx2 + wdy2;
determinant=(wdx2.*wdy2)-(wdxy.^2);

e1=(trace + sqrt(trace.^2 - 4*determinant))/2;
e2=(trace - sqrt(trace.^2 - 4*determinant))/2;
relMat=min(e1,e2);

vx=((determinant + eps).^-1).*((wdy2.*-wdtx)+(-wdxy.*-wdty));
vy=((determinant + eps).^-1).*((-wdxy.*-wdtx)+(wdx2.*-wdty));
vx=vx.*(relMat > thresh);
vy=vy.*(relMat > thresh);