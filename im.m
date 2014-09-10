function [ gain, bias, out ] = im( in, new_fig, ...
    exclude_zero, nstd, x, y )
%
% [ gain, bias, out ] = im( in, new_figure, ...
%       exclude_zero, nstd, x, y )
%
%	Image display function that can be used for displaying most binary,
%	grayscale or color image with auto-scaling
%
% gain  Effective gain applied to display data
% bias  Effective bias applied to display data
% out   Output image scaled for display 
%
% in        Input image
% new_fig   New figure flag, generates new fig if set to 1 (defualt = 1)
% exclude_zero  Exclude zero flag, if set to 1, it will ignore 0
%               pixel values when computing statistics.  This is helpful 
%               when an image has a zero border for example.
% nstd      Number of standard deviations to map to display range 
%           (default = 2).
%
% x         x axis values for display (default = [1:sx])
% y         y axis values for display (default = [1:sy])
%
% Author: Dr. Russell Hardie
% University of Dayton

% Convert to double
in = double(in);

% Get size info
[ sy, sx, sz ] = size( in );

% Is the logical (binary) pixel data?
if islogical(in) || (min(in(:))==0 && max(in(:))==1)
    binary_flag = 1;
else
    binary_flag = 0;
end

% Set up the default axes
if nargin < 6 || isempty(x) || isempty(y)
    x=[1:sx]; % default
    y=[1:sy]; % default
end

% Open new figure window if indicated
if nargin < 2 || isempty(new_fig)
    new_fig = 1;
end

if new_fig == 1;
    figure % default
end

if nargin < 3 || isempty(exclude_zero)
    exclude_zero = 0; % default
end


% number of pixels to use for statistics (mean and std)
max_num = min( [ 10000, sy*sx ] );

if binary_flag == 1

    % Treat by scaling 0 -> 0 and 1->255

    out = in(:,:,1)*255;
    gain = 255;
    bias = 0;
    image(x,y,out);
    colormap(gray(256));
    axis('image');

else

    % Treat by mapping nstd standard deviations
    % of input range into display range

    if nargin < 4 || isempty(nstd)
        nstd = 2; % default
    end

    if sz == 3 % color data

        R = in(:,:,1);
        G = in(:,:,2);
        B = in(:,:,3);

        if exclude_zero == 1

            I = find( R~=0 | G~=0 | B~=0 );
            USE = round( linspace(1,length(I),max_num ) );
            
            mR = mean(R(I(USE)));
            mG = mean(G(I(USE)));
            mB = mean(B(I(USE)));

            sR = std(R(I(USE)));
            sG = std(G(I(USE)));
            sB = std(B(I(USE)));

        else

            USE = round( linspace(1,sy*sx,max_num ) );
            
            mR = mean(R(USE));
            mG = mean(G(USE));
            mB = mean(B(USE));

            sR = std(R(USE));
            sG = std(G(USE));
            sB = std(B(USE));

        end

        gain(1) = 128/(sR*nstd);
        gain(2) = 128/(sG*nstd);
        gain(3) = 128/(sB*nstd);

        bias(1) = 128-(mR*128)/(sR*nstd);
        bias(2) = 128-(mG*128)/(sG*nstd);
        bias(3) = 128-(mB*128)/(sB*nstd);

        R = in(:,:,1)*gain(1)+bias(1);
        G = in(:,:,2)*gain(2)+bias(2);
        B = in(:,:,3)*gain(3)+bias(3);

        out(:,:,1)=uint8(clip(round(R),0,255));
        out(:,:,2)=uint8(clip(round(G),0,255));
        out(:,:,3)=uint8(clip(round(B),0,255));

        image(x,y,out);
        axis('image');

    else % assume grayscale (use first band only)

        in = in(:,:,1);

        if exclude_zero == 1

            I = find(in~=0);
            USE = round( linspace(1,length(I),max_num ) );
            
            inmn=mean(in(I(USE)));
            instd=std(in(I(USE)));

        else

            USE = round( linspace(1,sy*sx,max_num ) );
            
            inmn=mean(in(USE));
            instd=std(in(USE));

        end

        gain = 128/(instd*nstd);
        bias = 128-(inmn*128)/(instd*nstd);
        out=in*gain+bias;
        image(x,y,out);
        colormap(gray(256));
        axis('image');

    end

end

