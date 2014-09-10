function img_mask = adt_segmentation(img,lung_mask,rows,cols,m_0,n_0,T_0,T_delta,r_max,display_flag)

% Creating an adaptive distance based threshold function or array
% The threshold array is made 87 x87 so that it can be applied to all of the
% ROI's easily.
%   img is the initial nodule image
%   lung_mask is the lung mask from roi_exam
%   m_0,n_0 are the coordinates of the cue point 
%   rows,cols are the sizeof the array;
%   T_0 : minimum value ; 
%   T_delta = 1.7;
%   r_max = maximum radius
%   display_flag - to display the thresholding function

% Author:Roshni Uppala
% Date: 05/02/2013
%
% COPYRIGHT © 2013 Roshni Uppala. ALL RIGHTS RESERVED.
% This is UNPUBLISHED PROPRIETARY SOURCE CODE of Roshni Uppala; the
% contents of this file may not be disclosed to third parties, copied or
% duplicated in any form, in whole or in part, without the prior written
% permission of Roshni Uppala.
 
%% Step -2 
    % Initialization
    [M,N] = meshgrid(1:rows,1:cols);
    T = zeros(rows,cols);
    
    % Creating the threshold function with a minimum value of zero
    M_0 = m_0 * ones(rows,cols);
    N_0 = n_0 * ones(rows,cols);
    
    % The adaptive threshold is a function of the distance of a given pixel to the detection cue.
    %Computing the distance from the cue point. 
    d = (M - M_0).*(M - M_0) + (N - N_0).*(N - N_0);

    % Compute the region where d is less than r_max
    ind = find(d < r_max^2);
    T(ind) = T_0 + T_delta * ( 1 - exp( -1*d(ind)/r_max^2 ) ) / ( 1 - exp(-1) );
    ind = find(d >= r_max^2);
    T(ind) = inf;

    % Display the adaptive threshold function
    if(display_flag)
        figure(1);surf(M,N,T);
    end

    %% Step -3
    % Applying the adaptive distance based threshold to a nodule mask with relational operator
    img_mask = (img > T);
    
    %% Step-4
    % Logically ANDing with the threshold output mask and the lung mask.
    img_mask = and(img_mask,lung_mask);
    
    % Filling any holes in the mask
    img_mask = imfill(img_mask,'holes');

    % Performing morphological opening with a disk structuring element of
    % radius 1
    se = strel('disk',1);
    img_mask = imopen(img_mask,se);
    
    %% Step- 5
    % CUE point segment extraction 
    % Find various segments in the mask
    [L,num] = bwlabel(img_mask,4);
    label_cue = L(m_0,n_0);

    % Extracting the segment which has the same label as cue point
    img_mask = (L == label_cue);

end

