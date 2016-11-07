% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    anms.m
% Description:  Implement adaptive non-maximal suppression. 
% Input:        cimg:    H x W matrix representing the corner metric
%                        matrix.
%               max_pts: The number of corners desired.
% Output:       x:       N x 1 vector representing the column coordinates
%                        of corners.
%               y:       N x 1 vector representing the row coordinates of 
%                        corners.
%               rmax:    Suppression radius used to get max_pts corners.
% Note:         I chose not to vectorize this method, because that would
%               require limiting the number of points evaluated.  This
%               significantly diminishes the results.
% TODO:  -Vectorize remaining for loop

function [x, y, rMax] = anms(cimg, max_pts)    
    % First, organize corner metric matrix into an (H * W) x 3 matrix,
    % where columns represent corner strength, x position, y position 
    % respectively.
    [X, Y]       = meshgrid(1:size(cimg, 2), 1:size(cimg, 1));
    cimgComposed = cat(3, cimg, X, Y);
    cornerVect   = reshape(cimgComposed, size(cimg, 1) * size(cimg, 2), 3);
    
    % Sort cornerVect by corner strength (descending order).
    cornerVect = sortrows(cornerVect, 1);
    cornerVect = flipud(cornerVect);
    cornerVect = horzcat(cornerVect, -1 * ones(size(cornerVect, 1), 1));
    
    % Only keep up to 10% of corners (this is the corner threshold).
    cornerVect = cornerVect(1:round(.05 * size(cornerVect, 1)), :);
    numPoints = size(cornerVect, 1);
    
    % Now I need to compare each point against points of greater corner
    % strength, and compute the smallest radius in this comparison.
    cornerVect(1, 4) = numPoints * numPoints + 1;
    
    for i = 2 : numPoints   
        disp(i / numPoints);
        xComparisonMatrix = cornerVect(1:(i - 1), 2);
        xComparisonMatrix = xComparisonMatrix - cornerVect(i, 2) * ones(1, size(xComparisonMatrix, 2));
        
        yComparisonMatrix = cornerVect(1:(i - 1), 3);
        yComparisonMatrix = yComparisonMatrix - cornerVect(i, 3) * ones(1, size(yComparisonMatrix, 2));
        
        rComparisonMatrix = (xComparisonMatrix.^2 + yComparisonMatrix.^2).^(0.5);
        
        minElement = min(rComparisonMatrix);
        
        cornerVect(i, 4) = minElement;
    end

    % Sort points in order to identify points with greatest max radius.
    cornerVect = sortrows(cornerVect, 4);
    cornerVect = flipud(cornerVect);
    
    % Identify desired number of points.
    x    = cornerVect(1:max_pts, 2);
    y    = cornerVect(1:max_pts, 3);
    rMax = cornerVect(max_pts, 4);
end