function out = RenormalizeImage(input, varargin)
input = double(input);
if isempty(varargin)
    out = (input - min(input(:)))/(max(input(:)) - min(input(:)));
else
    out = (input - prctile(input(:), varargin{1}))/(prctile(input(:), 100 - varargin{1}) - prctile(input(:), varargin{1}));
    out(out(:) > 1) = 1;
    out(out(:) < 0) = 0;
end
end