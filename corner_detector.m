% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    corner_detector.m
% Input:        img:    H x W matrix representing the gray scale input
%                       image.
% Output:       cimg:   H x W matrix representing corner metric matrix.

function [cimg] = corner_detector(img)
    % Compute corner metric matrix using built-in MATLAB function.
    cimg = cornermetric(img, 'HARRIS');
end