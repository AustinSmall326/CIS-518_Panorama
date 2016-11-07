% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    ransac_est_homography.m
% Description:  Use a robust method (RANSAC) to compute a homography.  Use
%               4-point RANSAC as described in class to compute a robust 
%               homography estimate.
% Input:        x1, y1, x2, y2: N x 1 vectors representing the 
%                               correspondences feature coordinates in the 
%                               first and second image.  It means the point
%                               (x1_i, y1_i) in the first image are matched
%                               to (x2_i, y2_i) in the second image.
%               thresh:         the threshold on distance used to determine
%                               if transformed points agree.
% Output:       H:              3 x 3 matrix representing the homograph
%                               matrix computed in final step of RANSAC.
%               inlier_ind:     N x 1 vector representing if the 
%                               correspondence is inlier or not.  1 means
%                               inlier, 0 means outlier.

% TODO:     Speed up this algorithm.
%           How to set number of iterations.
%           Threshold??

function [H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, thresh)    
    % Number of iterations.
    N = 10000;

    % Record best homography / number of inliers encountered thus far.
    HBest       = [];
    InliersBest = 0;
    
    for i = 1 : N
        disp(i / N)
        
        % Randomly sample four feature pairs.
        idx = randperm(size(x1, 1));
        idx = idx(1:4);
        
        xPointsSource = x1(idx);
        yPointsSource = y1(idx);
        
        xPointsDestination = x2(idx);
        yPointsDestination = y2(idx);
        
        HTemp = est_homography(xPointsDestination, yPointsDestination, xPointsSource, yPointsSource);

        [X1, Y1] = apply_homography(HTemp, xPointsSource, yPointsSource);

%         figure;
%         plot(X1, Y1,'bx')
%         figure;
%         plot(xPointsDestination, yPointsDestination, 'rx');
% 


        % Apply homography to all point correspondences and count number
        % of inliers.
        [xDestTemp, yDestTemp] = apply_homography(HTemp, x1, y1);   
        inlier_ind_temp = ((xDestTemp - x2).^2 + (yDestTemp - y2).^2 < thresh);
        InliersTemp = sum(inlier_ind_temp);

        if (InliersTemp > InliersBest)
            InliersBest = InliersTemp;
            HBest = HTemp;   
        end
    end
    
    H = HBest;
    
    % Compute indices of inliers.    
    [xDestTemp, yDestTemp] = apply_homography(H, x1, y1);
    inlier_ind = ((xDestTemp - x2).^2 + (yDestTemp - y2).^2 < thresh);
end