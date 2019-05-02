function t = linearInterpolation(y0, yh, yt, h)
% Uses linear interpolation of form y = (yh-y0)/h * t +y0 to calculate
% time t at which yt is reached.

t = zeros(size(y0));

t(:) = h*(y0 - yt) ./ (y0 - yh);
%roots([(yh-y0)/h y0-yt])