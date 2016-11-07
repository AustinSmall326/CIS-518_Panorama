% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    mymosaic.m
% Input:        img_input:  M element cell array, each element is an input
%                           image.
% Output:       img_mosaic: H x W x 3 matrix representing the final mosaic
%                           image.

function [img_mosaic] = mymosaic(img_input)
    
    % Load target images.
I1 = imread('Images/im1_1.jpg');
I2 = imread('Images/im1_2.jpg');

% Convert images to grayscale.
I1Gray = rgb2gray(I1);
I2Gray = rgb2gray(I2);

% Perform HARRIS corner detection.
[C1] = corner_detector(I1Gray);
[C2] = corner_detector(I2Gray);

% Perform adaptive non-maximal suppression.
[x1, y1, rMax1] = anms(C1, 500);
[x2, y2, rMax2] = anms(C2, 500);

% figure;
% hold on;
% image(I1)
% plot(x1, y1, 'y.', 'MarkerSize', 20);
% 
% figure;
% hold on;
% image(I2)
% plot(x2, y2, 'y.', 'MarkerSize', 20);

% Make sure descriptor points are within threshold from image border.
[x1, y1] = check_borders(I1Gray, x1, y1);
[x2, y2] = check_borders(I2Gray, x2, y2);

% Identify feature descriptors for each image.
[descs1] = feat_desc(I1Gray, x1, y1);
[descs2] = feat_desc(I2Gray, x2, y2);

% Determine feature matches.
[matches] = feat_match(descs1, descs2);

% Filter correspondences.
x1 = x1(matches > 0);
y1 = y1(matches > 0);

x2 = x2(matches((matches > 0)));
y2 = y2(matches((matches > 0)));

% Filter feature matches using RANSAC.
[H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, 100);

x1 = x1(inlier_ind == 1);
y1 = y1(inlier_ind == 1);

x2 = x2(inlier_ind == 1);
y2 = y2(inlier_ind == 1);

% figure;
% hold on;
% 
% 
% 
% hold on;
% image(I1);
% plot(x1, y1, 'b.', 'MarkerSize', 20);
%     
% figure
% hold on
% image(I2)
% plot(x2, y2, 'b.', 'MarkerSize', 20);
% 
% 
% 
% [X1, Y1] = apply_homography(H, x1, y1);
% 
% figure;
% plot(X1, Y1,'bx', x2, y2, 'rx')




%% Construct mosaic.


HEye = eye(3);
tformEye = projective2d(HEye');

tform = projective2d(H');


% Determine world limits for each homography.
xlim = [];
ylim = [];

[xlim(1, :), ylim(1, :)] = outputLimits(tformEye, [1 size(I2, 2)], [1 size(I2, 1)]);
[xlim(2, :), ylim(2, :)] = outputLimits(tform, [1 size(I1, 2)], [1 size(I1, 1)]);

xMin = min(xlim(:));
xMax = max(xlim(:));


yMin = min(ylim(:));
yMax = max(ylim(:));



panorama = imref2d(size(I1), [xMin xMax], [yMin yMax]);
outputimage2 = imwarp(I2, tformEye, 'OutputView', panorama);
outputimage = imwarp(I1, tform, 'OutputView', panorama);

C = imadd(outputimage, outputimage2);

figure;
image(flipud(C));











end