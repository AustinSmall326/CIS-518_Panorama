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
    numDataPoints = size(x1, 1);
    
    % Number of iterations.  We will run at least 10000 iterations.
    % However, RANSAC may choose to run more iterations, based on the 
    % quality of the results.
    N    = 10000; 
    NMax = 100000;

    % Record best homography / number of inliers encountered thus far.
    HBest       = [];
    InliersBest = 0;
    
    i = 0;
    
    while (i < N)
        disp(i / N)
        
        % Randomly sample four feature pairs.
        idx = randperm(size(x1, 1));
        idx = idx(1:4);
        
        xPointsSource = x1(idx);
        yPointsSource = y1(idx);
        
        xPointsDestination = x2(idx);
        yPointsDestination = y2(idx);
        
        HTemp = est_homography(xPointsDestination, yPointsDestination, xPointsSource, yPointsSource);

        % Apply homography to all point correspondences and count number
        % of inliers.
        [xDestTemp, yDestTemp] = apply_homography(HTemp, x1, y1);   
        inlier_ind_temp = ((xDestTemp - x2).^2 + (yDestTemp - y2).^2 < thresh);
        InliersTemp = sum(inlier_ind_temp);

        if (InliersTemp > InliersBest)
            InliersBest = InliersTemp;
            HBest = HTemp;   
            
            % Update number of iterations of RANSAC.
            e = (numDataPoints - InliersBest) / numDataPoints; % Ratio of outliers to sample size.
            p = 0.99;                                % Probability that at least one sample yields inliers.
            s = 4;                                   % Min number of points to fit model.
            
            NTemp = log(1 - p) / log(1 - (1 - e)^s);

            if (NTemp > N)
                if (NTemp > NMax)
                    N = NMax;
                else
                    N = NTemp;
                end
            end
        end
        
        i = i + 1;
    end
    
    H = HBest;
    
    % Compute indices of inliers.    
    [xDestTemp, yDestTemp] = apply_homography(H, x1, y1);
    inlier_ind = ((xDestTemp - x2).^2 + (yDestTemp - y2).^2 < thresh);
end