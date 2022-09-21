function out = GetFactorArray(polyTime,frameTime,numMeans)
    mu = polyTime/frameTime; 
    sig = numMeans*mu;    
    pt = floor(mu + 4*sig); 
    out = zeros(1,pt); 
    for i = pt:-1:1
        out(i) = min(normcdf(i,mu,sig),1 - normcdf(i,mu,sig)); 
    end
    out = out/sum(out(:));     
    if isempty(out)
        out = 1; 
    elseif sum(isnan(out)) == length(out)
        out = 1; 
    end    
end
