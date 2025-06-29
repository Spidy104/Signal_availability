function [y, ny] = conv_m(x, nx, h, nh)
    %conv_m, convolution modified
    %   Detailed explanation goes here
    
    nyb = min(nx) + min(nh);
    nyh = max(nx) + max(nh);
    ny = nyb:nyh;
    y = conv(x, h);
end