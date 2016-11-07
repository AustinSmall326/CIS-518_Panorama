% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    feat_match.m
% Input:        descs1:    64 x N_1 matrix representing the corner
%                          descriptors of first image.
%               descs2:    64 x N_2 matrix representing the corner 
%                          descriptors of second image.
% Output:       match:     N_1 x 1 vector where match_i points to the 
%                          index of the descriptor in descs2 that matches
%                          with the feature i in descriptor descs1.  If no
%                          match is found, you should put match_i = -1.

% TODO: Implement a k-d tree??
function [match] = feat_match(descs1, descs2)
    numFeat1 = size(descs1, 2);
    numFeat2 = size(descs2, 2);
    
    % Find SSD.
    descs1Rep = repmat(descs1, [numFeat2, 1]);
    descs2Rep = repmat(reshape(descs2, [64 * numFeat2, 1]), [1, numFeat1]);
    
    SD = (descs1Rep - descs2Rep) .^ 2;
    
    SSD = zeros(numFeat2, numFeat1);
    
    for i = 1 : numFeat2
        SSD(i, :) = sum(SD(64 * (i - 1) + 1 : 64 * i, :), 1);
    end
        
    % Append im2Point indices to each SSD value.
    [~, Y] = meshgrid(1 : numFeat1, 1 : numFeat2);
    SSD = cat(3, SSD, Y);
    
    % Sort each column of SSD matrix (ascending order).
    for i = 1 : numFeat1
        [~, I] = sort(SSD(:, i, 1));
        SSD(:, i, :) = cat(3, SSD(I, i, 1), SSD(I, i, 2));
    end
        
    % Compute SSD ratio.
    SSDRatio = SSD(1, :, 1) ./ SSD(2, :, 1);

    idx = find(SSDRatio < 0.6);
    
    match      = -1 * ones(numFeat1, 1);
    match(idx) = SSD(1, idx, 2);
end