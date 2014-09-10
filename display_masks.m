function display_masks( mask, color, line_width )
%
% display_masks( mask, line_spec, line_width )
%
% Puts mask contours on current figure
%
% REQUIRED INPUTS:  mask = 2D binary mask.  To display multiple masks, this
%                          should be a 3D array where the third dimension
%                          is the mask number. 
%
% OPTIONAL INPUTS:  color = Array of mask colors, defaut cycles the following six colors
%                           [ 'r','g','b','m','c','y' ];
%
%                   line_width = Array of mask line widths, default = ones.
%                 
% OUTPUTS:          None
%
% FUNCTIONS CALLED: contour.m
%
% AUTHOR:  Russell C. Hardie, Ph.D.


% Hold on current axes so we can add mask contours
hold on;

% Determine the number of masks
num_masks = size( mask, 3 );

% Set the line colors
if ~exist( 'color', 'var' ) | isempty( color )
    
    color = [ 'r','g','b','m','c','y' ];
    color = repmat( color, [ 1, ceil( num_masks / 6 )  ] );
    color = color( 1 : num_masks );
    
end

% Set the line widths
if ~exist( 'line_width', 'var' ) | isempty( line_width )
    
    line_width = ones( num_masks, 1); 
    
end

% Display masks
for mask_idx = 1 : num_masks
    
    % Put on contour
    [ C, h ] = contour( mask( :, :, mask_idx ), 1, color(mask_idx) );
    
    % Set line properties
    set( h, 'linewidth', line_width(mask_idx) );
    
end

% Turn off hold
hold off;