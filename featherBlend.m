% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    featherBlend.m
% Input:        img1:   First of two images to blend.
%               img2:   Second of two images to blend.
% Output:       img_blend:  A blended image.
% Description:  This function performs feathered alpha blending of two 
%               images.

function [img_blend] = featherBlend(img1, img2)    
    % Convert images to grayscale.
    img1_gray = rgb2gray(img1);
    img2_gray = rgb2gray(img2);
    
    % Generate a binary matrix - ones where there is no color in each
    % image.
    img1_bin = (img1_gray > 0);
    img2_bin = (img2_gray > 0);
    
    img1_bin_inv = (img1_bin == 0);
    img2_bin_inv = (img2_bin == 0);
    
    % Generate a distance map.  Distances reprsent distance from border
    % of image.
    dist_map_img1 = bwdist(img1_bin_inv);
    dist_map_img2 = bwdist(img2_bin_inv);
    
    % Generate alpha map for first image.
    alpha_img1 = dist_map_img1 ./ (dist_map_img1 + dist_map_img2);
    alpha_img1(isnan(alpha_img1)) = 0;
    
    % Update first image.
    img1 = im2double(img1) .* repmat(alpha_img1, [1, 1, 3]);
    img1 = uint8(255 * img1);
    
    % Generate alpha map for second image.
    alpha_img2 = dist_map_img2 ./ (dist_map_img1 + dist_map_img2);
    alpha_img2(isnan(alpha_img2)) = 0;
    
    % Update second image.
    img2 = im2double(img2) .* repmat(alpha_img2, [1, 1, 3]);
    img2 = uint8(255 * img2);
    
    img_blend = imadd(img1, img2);
end