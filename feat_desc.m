% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    feat_desc.m
% Input:        img:    H x W matrix representing the gray scale input
%                       image.
%               x:      N x 1 vector representing the column coordinates
%                       of corners.
%               y:      N x 1 vector representing the row coordinates of 
%                       corners.
% Output:       descs:  64 x N matrix, with column i being the 64 
%                       dimensional descriptor (8 x 8 grid linearized)
%                       computed at location (x_i, y_i) in img.

% TODO: Need to validate output - but it seems reasonable.
% TODO: Blur 40x40 patch - should provide some rotation invariance

function [descs] = feat_desc(img, x, y)  
    N      = size(x, 1);    
    output = zeros(64, N);
    
    % Iterate through N points.
    outputCount = 1;
    
    for i = 1 : N
        % We shall assume all points are at least 20 pixels from image
        % border.
        xTemp = x(i);
        yTemp = y(i);
       
        window = img((yTemp - 20):5:(yTemp + 19), (xTemp - 20):5:(xTemp + 19));

        % Perform a little smoothing.  As noted in lecture, this can help
        % account for slight rotations / translations.
        Gx = normpdf([-5:1:5], 0, 0.3);
        Gy = normpdf([-5:1:5], 0, 0.3)';
        
        % Create a 2D Gaussian filter.
        Gx_padded = padarray(Gx, [2 0]);
        G = conv2(Gx_padded, Gy, 'same');
        window = conv2(window, G, 'same');
        
        % Vectorize and append to output.
        output(:, outputCount) = reshape(window, [64, 1]);
        
        % Perform bias/gain normalization.
        meanDesc   = mean(output(:, outputCount));
        stdDevDesc = std(output(:, outputCount));
        
        output(:, outputCount) = (output(:, outputCount) - meanDesc * ones(64, 1)) / stdDevDesc;
       
        outputCount = outputCount + 1;
    end

    % Remove unused columns from output.
    output(:, outputCount : end) = [];
    descs = output;
end