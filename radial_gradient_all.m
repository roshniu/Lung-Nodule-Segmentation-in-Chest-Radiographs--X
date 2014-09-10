function [ out_mean, out_std ] = radial_gradient_all( gradx, grady, mask, cue )
%
% [ out_mean, out_std ] = radial_gradient_all( gradx, grady, mask, cue )
%
% Average radial gradient over entire mask
%
% REQUIRED INPUTS:
% gradx         Gradient image in x (use gradient( ))
% grady         Gradient image in y (use gradient( ))
% mask          Binary mask with segmentation of interest
% cue           [x,y] cue point coordinates associated with mask
%
% OUTPUTS:
% out_mean      Average (mean) radial gradient over mask
% out_std       Standard deviation of the radial gradient over mask
%
% Author: Dr. Russell Hardie 
% 2007

% Get size
[ sy, sx ] = size( gradx );

% Get mask pixel indices
mask_idx = find( mask );
[ mask_idx_y, mask_idx_x ] = ind2sub( [ sy, sx ], mask_idx );

% Assemble the perimter gradient vectors
grad_vectors = [ -gradx(mask_idx), -grady(mask_idx) ];

% Compute all the radial vectors
radial_vectors = [ ( mask_idx_x(:) - cue(1) ), ( mask_idx_y(:) - cue(2) ) ];
mag_radial_vectors = sqrt( sum( radial_vectors' .^ 2 ) );

% Set zero magnitude vectors to 1 (avoid divide by 0 warning)
mag_radial_vectors( mag_radial_vectors == 0 ) = 1;

% Make unit vectors
radial_unit_vectors = radial_vectors ./  repmat( mag_radial_vectors(:), 1, 2 );

% Compute inner products of grad vectors and radial unit vectors
inner_products = sum( ( grad_vectors .* radial_unit_vectors )' );

% Average radial gradient on perimter
out_mean = mean( inner_products );
out_std = std( inner_products );