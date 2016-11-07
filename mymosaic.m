% Author:       Austin Small
% Class:        CIS-581
% Project:      3
% File Name:    mymosaic.m
% Input:        img_input:  M element cell array, each element is an input
%                           image.
% Output:       img_mosaic: H x W x 3 matrix representing the final mosaic
%                           image.

function [img_mosaic] = mymosaic(img_input)
    numImages = size(img_input, 2);
    
    % Convert all images to grayscale.
    grayImCell = cell(1, numImages);
    
    for i = 1 : numImages
        tempImage = img_input{1, i};
        grayImCell{1, i} = rgb2gray(tempImage);;
    end

    % Perform HARRIS corner detection.
    cornerCell = cell(1, numImages);
    
    for i = 1 : numImages
        cornerCell{1, i} = corner_detector(grayImCell{1, i});
    end
    
    % Perform adaptive non-maximal suppression.
    xPointsCell    = cell(1, numImages);
    yPointsCell    = cell(1, numImages);
    rMaxPointsCell = cell(1, numImages);
    
    for i = 1 : numImages
        [xTemp, yTemp, rMaxTemp] = anms(cornerCell{1, i}, 500);
        xPointsCell{1, i}    = xTemp;
        yPointsCell{1, i}    = yTemp;
        rMaxPointsCell{1, i} = rMaxTemp;
    end
    
   % Make sure descriptor points are within threshold from image border.
   for i = 1 : numImages
        [xTemp, yTemp] = check_borders(grayImCell{1, i}, xPointsCell{1, i}, yPointsCell{1, i});
        xPointsCell{1, i} = xTemp;
        yPointsCell{1, i} = yTemp;
   end

    % Identify feature descriptors for each image.
    descsCell = cell(1, numImages);
    
    for i = 1 : numImages
        [descsTemp] = feat_desc(grayImCell{1, i}, xPointsCell{1, i}, yPointsCell{1, i});
        descsCell{1, i} = descsTemp;
    end

    % Determine feature matches.
    matchesCell = cell(1, numImages - 1);
    
    for i = 1 : (numImages - 1)
        [matchesTemp] = feat_match(descsCell{1, i}, descsCell{1, i + 1});
        matchesCell{1, i} = matchesTemp;
    end
    
    % Filter correspondences between image pairs.
    corrCell = cell(1, numImages - 1, 4);
    
    for i = 1 : (numImages - 1)
        matches = matchesCell{1, i};
       
        x1 = xPointsCell{1, i}(matches > 0);
        y1 = yPointsCell{1, i}(matches > 0);
        
        x2 = xPointsCell{1, i + 1}(matches > 0);
        y2 = yPointsCell{1, i + 1}(matches > 0);
        
        corrCell{1, i, 1} = x1;
        corrCell{1, i, 2} = y1;
        corrCell{1, i, 3} = x2;
        corrCell{1, i, 4} = y2;
    end

    % Filter feature matches using RANSAC.
    HCell = cell(1, numImages);
    
    HCell{1, 1}     = eye(3);
    inlier_ind_cell = cell(1, numImages - 1);
    
    for i = 1 : (numImages - 1)
        xPointsSource = corrCell{1, i, 3};
        yPointsSource = corrCell{1, i, 4};
        
        xPointsDest = corrCell{1, i, 1};
        yPointsDest = corrCell{1, i, 2};
        
        [H, inlier_ind] = ransac_est_homography(xPointsSource, yPointsSource, xPointsDest, yPointsDest, 100);

        HCell{1, (i + 1)}     = H;
        inlier_ind_cell{1, i} = inlier_ind;
    end
    
    %% Construct MOSAIC (DOPE DOPE DOPE).
    % Generate transforms.
    TFormCell = cell(1, numImages);
    
    for i = 1 : numImages
        tformtemp = projective2d(transpose(HCell{1, i}));
        TFormCell{1, i} = tformtemp;
    end
    
    % Determine world limits for each homography transform.
    xlim = [];
    ylim = [];
    
    for i = 1 : numImages
        I = img_input{1, i};
        [xlim(1, :), ylim(1, :)] = outputLimits(TFormCell{1, i}, [1 size(I, 2)], [1 size(I, 1)]);
    end

    xMin = min(xlim(:));
    xMax = max(xlim(:));

    yMin = min(ylim(:));
    yMax = max(ylim(:));

    % Generate panorama.
    I = img_input{1, i};
    panorama = imref2d(size(I), [xMin xMax], [yMin yMax]);

    outputImageCell = cell(1, numImages);
    
    for i = 1 : numImages
        outputImageCell{1, i} = imwarp(img_input{1, i}, TFormCell{1, i}, 'OutputView', panorama);
    end

    C = outputImageCell{1, i};
    
    for i = 2 : numImages
        C = imadd(C, outputImageCell{1, i});
    end

    figure;
    image(flipud(C));

    % dummy output
    img_mosaic = zeros(2, 2);

end