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
    midIndex  = ceil(numImages / 2);
    
    % Convert all images to grayscale.
    grayImCell = cell(1, numImages);
    
    for i = 1 : numImages
        tempImage = img_input{1, i};
        grayImCell{1, i} = rgb2gray(tempImage);
    end

    %% Perform HARRIS corner detection.
    cornerCell = cell(1, numImages);
    
    for i = 1 : numImages
        cornerCell{1, i} = corner_detector(grayImCell{1, i});
    end
    %% Perform adaptive non-maximal suppression.
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
   
   
   

        
        
        
    %% Identify feature descriptors for each image.
    descsCell = cell(1, numImages);
    
    for i = 1 : numImages
        [descsTemp] = feat_desc(grayImCell{1, i}, xPointsCell{1, i}, yPointsCell{1, i});
        descsCell{1, i} = descsTemp;
    end

    %% Determine feature matches.
    matchesCell = cell(1, numImages - 1);
    
    for i = 1 : (numImages - 1)
        [matchesTemp] = feat_match(descsCell{1, i}, descsCell{1, i + 1});
        matchesCell{1, i} = matchesTemp;
    end
    
    % Filter correspondences between image pairs.
    corrCell = cell(1, numImages - 1, 4);
    
    nonCorrCell = cell(1, numImages - 1, 4);
    
    for i = 1 : (numImages - 1)
        matches = matchesCell{1, i};
       
        x1 = xPointsCell{1, i}(matches > 0); % Destination.
        y1 = yPointsCell{1, i}(matches > 0); 
        
        x2 = xPointsCell{1, (i + 1)}(matches(matches > 0)); % Source.
        y2 = yPointsCell{1, (i + 1)}(matches(matches > 0));
        
        corrCell{1, i, 1} = x1;
        corrCell{1, i, 2} = y1;
        corrCell{1, i, 3} = x2;
        corrCell{1, i, 4} = y2;
        
        
        x1 = xPointsCell{1, i}(matches == -1); % Destination.
        y1 = yPointsCell{1, i}(matches == -1); 
        
        x2 = xPointsCell{1, (i + 1)};
        y2 = yPointsCell{1, (i + 1)};
        
        x2(matches(matches > 0)) = [];
        y2(matches(matches > 0)) = [];
        
       

%         
        nonCorrCell{1, i, 1} = x1;
        nonCorrCell{1, i, 2} = y1;
        nonCorrCell{1, i, 3} = x2;
        nonCorrCell{1, i, 4} = y2;
        
        
        
        
    end
    
    
    
    
      %% Test printing

        figure;
        subplot(1, 2, 1);
        image(img_input{1, 1});
        hold on;
        image(img_input{1, 1});
        plot(corrCell{1, 1, 1}, corrCell{1, 1, 2}, 'b.', 'MarkerSize', 20);
        plot(nonCorrCell{1, 1, 1}, nonCorrCell{1, 1, 2}, 'r.', 'MarkerSize', 15);
        
        subplot(1, 2, 2);
        image(img_input{1, 2});
        hold on;
        image(img_input{1, 2});
        plot(corrCell{1, 1, 3}, corrCell{1, 1, 4}, 'b.', 'MarkerSize', 20);
        plot(nonCorrCell{1, 1, 3}, nonCorrCell{1, 1, 4}, 'r.', 'MarkerSize', 15);

        
        set(gcf,'NextPlot','add');
axes;
h = title('Inliers (Blue) and Outliers (Red) - First Pair', 'FontSize', 13);
set(gca,'Visible','off');
set(h,'Visible','on');


        disp('jaun');
        
        
        
        

    %% Estimate homographies for each image pair.
    % Middle image.
    HCellMid = cell(1, 1);
    HCellMid{1, 1} = eye(3);

    % Images to left of middle image.
    HCellLeft = cell(1, midIndex - 1);
    
    for i = 1 : (midIndex - 1)
        xPointsSource = corrCell{1, i, 1};
        yPointsSource = corrCell{1, i, 2};
        
        xPointsDest = corrCell{1, i, 3};
        yPointsDest = corrCell{1, i, 4};
        
        [H, inlier_idx] = ransac_est_homography(xPointsSource, yPointsSource, xPointsDest, yPointsDest, 50);

        HCellLeft{1, i} = H;
        
        
        
        
       
        
        
        
        
        
        
        
    end
    
    % Image to right of middle image.
    HCellRight = cell(1, numImages - midIndex);
    
    for i = 1 : (numImages - midIndex)
        xPointsSource = corrCell{1, (midIndex + i - 1), 3};
        yPointsSource = corrCell{1, (midIndex + i - 1), 4};
        
        xPointsDest = corrCell{1, (midIndex + i - 1), 1};
        yPointsDest = corrCell{1, (midIndex + i - 1), 2};
        
        [H, inlier_idx] = ransac_est_homography(xPointsSource, yPointsSource, xPointsDest, yPointsDest, 100);

        HCellRight{1, i} = H;
        
        
        
         figure;
        subplot(1, 2, 1);
        image(img_input{1, 1});
        hold on;
                plot(xPointsDest(inlier_idx), yPointsDest(inlier_idx), 'b.', 'MarkerSize', 20);
                xPointsDest(inlier_idx) = [];
        yPointsDest(inlier_idx) = [];
        
        plot(xPointsDest, yPointsDest, 'r.', 'MarkerSize', 15);
        
        subplot(1, 2, 2);
        image(img_input{1, 2});
        hold on;

plot(xPointsSource(inlier_idx), yPointsSource(inlier_idx), 'b.', 'MarkerSize', 20);
        xPointsSource(inlier_idx) = [];
        yPointsSource(inlier_idx) = [];
        
        plot(xPointsSource, yPointsSource, 'r.', 'MarkerSize', 15);
        
        set(gcf,'NextPlot','add');
axes;
h = title('RANSAC Inliers (Blue) and Outliers (Red) - First Pair', 'FontSize', 13);
set(gca,'Visible','off');
set(h,'Visible','on');


        disp('jaun');
        
        
        
        
        
    end
    
    % Need to update left homographies (all relative to the middle image).
    for i = (midIndex - 2) : -1 : 1
        hFirst  = HCellLeft{1, i};
        hSecond = HCellLeft{1, (i + 1)};
        
        HNew = hFirst * hSecond;
        HCellLeft{1, i} = HNew;
    end
    
    % Need to update right homographies (all relative to the middle image).
    for i = 2 : (numImages - midIndex)
        hFirst  = HCellRight{1, (i - 1)};
        hSecond = HCellRight{1, i};
        
        HNew = hFirst * hSecond;
        HCellRight{1, i} = HNew;
    end
    
    %% Construct MOSAIC (DOPE DOPE DOPE).
    % Generate transforms.
    TFormCell = cell(1, numImages);
    
    for i = 1 : (midIndex - 1)
        tformtemp = projective2d(transpose(HCellLeft{1, i}));
        TFormCell{1, i} = tformtemp;
    end
    
    tformtemp = projective2d(transpose(HCellMid{1, 1}));
    TFormCell{1, midIndex} = tformtemp;
    
    for i = 1 : (numImages - midIndex)
        tformtemp = projective2d(transpose(HCellRight{1, i}));
        TFormCell{1, (midIndex + i)} = tformtemp;
    end
     
    % Determine world limits for each homography transform.
    xlim = [];
    ylim = [];
    
    for i = 1 : numImages
        I = img_input{1, i};
        [xlim(i, :), ylim(i, :)] = outputLimits(TFormCell{1, i}, [1 size(I, 2)], [1 size(I, 1)]);
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

    C = outputImageCell{1, 1};
    
    % Generate feather blended mosaic image.
    for i = 2 : numImages
        C = imadd(C, outputImageCell{1, i}); 
    end
    
    figure;
    image(C);
    title('Final Mosaic', 'FontSize', 14);
    axis off

    % dummy output
    img_mosaic = zeros(2, 2);

end