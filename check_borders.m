% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    check_borders.m
% Input:        img:    H x W matrix representing the gray scale input
%                       image.
%               x:      N x 1 vector representing the column coordinates
%                       of corners.
%               y:      N x 1 vector representing the column coordinates
%                       of corners.
% Output:       x:      Adjusted vector to store valid x points.
%               y:      Adjusted vector to store valid y points.

function [x, y] = check_borders(img, x, y)
    xMax = size(img, 2);
    yMax = size(img, 1);

    % Check x position with respect to border.
    idx = (x < 21);
    x(idx) = [];
    y(idx) = [];

    idx = abs(xMax*ones(size(x, 1), 1) - x) < 19;
    x(idx) = [];
    y(idx) = [];

    % Check y position with respect to border.
    idx = (y < 21);
    x(idx) = [];
    y(idx) = [];

    idx = abs(yMax*ones(size(y, 1), 1) - y) < 19;
    x(idx) = [];
    y(idx) = [];
end