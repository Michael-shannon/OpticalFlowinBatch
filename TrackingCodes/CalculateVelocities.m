function vels = CalculateVelocities(tracks_in, pxPerMicron, timeBtwFrames)
    a = unique(tracks_in(:,4));
    b = cell(size(a));
    e1 = zeros(size(a));
    e2 = zeros(size(a));
    for i = 1:length(a)
        c = tracks_in(tracks_in(:,4) == a(i),[1,2]); 
        d = nan; 
        for j = 1:size(c,1)-1
            p1 = c(j,:); 
            p2 = c(j + 1,:); 
            d = [d,norm(p2 - p1)];  %#ok<AGROW>
        end
        b{i} = d/pxPerMicron/timeBtwFrames; 
        p1 = c(1,:); 
        p2 = c(end,:); 
        e1(i) = norm(p2 - p1)/pxPerMicron/timeBtwFrames/size(c, 1);
        e2(i) = mean(d(2:end))/pxPerMicron/timeBtwFrames;
    end
    vels.IDs = a; 
    vels.Velocities = b; 
    vels.AvgVelocity = e1';
    vels.AvgInstVelocity = e2';
end