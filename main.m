% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    main.m
% Description:  Initialize panorama program from this script.

% Load target images.
I1 = imread('Images/im1_1.jpg');
I2 = imread('Images/im1_2.jpg');

% Create cell array for images.
c       = cell(1, 2);
c{1, 1} = I1;
c{1, 2} = I2;

% Run mosaic script.
[img_mosaic] = mymosaic(c);
