% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    main.m
% Description:  Initialize panorama program from this script.

% Load target images.
I1 = imread('Images/im1.jpg');
I2 = imread('Images/im2.jpg');
I3 = imread('Images/im3.jpg');
I4 = imread('Images/im4.jpg');
I5 = imread('Images/im5.jpg');
I6 = imread('Images/im6.jpg');

% Create cell array for images.
c       = cell(1, 2);
c{1, 1} = I1;
c{1, 2} = I2;
c{1, 3} = I3;
c{1, 4} = I4;
c{1, 5} = I5;
c{1, 6} = I6;

% Run mosaic script.
[img_mosaic] = mymosaic(c);

figure;
image(img_mosaic);
title('Final Mosaic', 'FontSize', 14);
axis off

