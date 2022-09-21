function tracks_out = ApplyMaxAngleDeviation(tracks_in,max_angle_dev)
    tracks_out = tracks_in; 
    a = unique(tracks_in(:,4));    
    for i = 1:length(a)
        b = tracks_in(tracks_in(:,4) == a(i),[1,2]); 
        c = nan;
        for j = 2:size(b,1)-1
            p1 = b(j - 1,:); 
            p2 = b(j,:); 
            p3 = b(j + 1,:); 
            v1 = p1 - p2; 
            v2 = p3 - p2; 
            c = [c,(180/pi)*acos(dot(v1,v2)/(norm(v1)*norm(v2)))];  %#ok<AGROW>
        end
        c = [c,nan];  %#ok<AGROW>
        if sum(abs(180 - c) > max_angle_dev) > 0
            tracks_out(tracks_out(:,4) == a(i),:) = []; 
        end
    end
end