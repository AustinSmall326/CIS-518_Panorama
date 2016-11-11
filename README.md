Overview:
------------------

This project focused on image feature detection, feature matching and image mosaic techniques.  The goal of this project was to create an image mosaic or stitching, which is a collection of small images which are aligned properly to create one larger image.  The techniques utilized in this project were referenced from the following papers.

- "Multi-image Matching using Multi-scale image patches", Brown, M.; Szeliski, R.; Winder, S. CVPR 2015
- "Shape Matching and Object Recognition Using Shape Contexts", Belongie, S., Malik, J. and Puzicha, J. PAMI 2002: http://www.eecs.berkeley.edu/Research/Projects/CS/vision/shape

Project Walk-Through and Results:
--------------------

- **Capture Images**

  On the last day of the project, I spent a few hours in downtown Philadelphia taking pictures.  I took these cityscape pictures overlooking the Schuylkill River.

![input images](https://cloud.githubusercontent.com/assets/9031637/20200008/907d6346-a77c-11e6-83ab-93d1ffd29f49.jpg)
- **Detect Corner Features**

  The first step is to detect corner featuers in an image.  This was accomplished using the HARRIS corner detection algorithm.  Note that the MATLAB built-in cornermetric function was used to accomplish this task.  The computed corner strength can be visualized below.

![cornerresults](https://cloud.githubusercontent.com/assets/9031637/20200190/b3bab2c2-a77d-11e6-976b-a57f3575ec7a.jpg)
- **Adaptive Non-Maximal Suppression**

  After detecting corner features, the goal is to select a well distribued 500 pixel subset of those points.  Adaptive Non-Maximal Suppression accomplished this goal by selecting 500 points with the largest associated radius, specifying a region over which they can be considered a corner of maximum strength.  This offers a uniform distribution of points over the image, as seen below.

  ![anms](https://cloud.githubusercontent.com/assets/9031637/20200291/65fd7fe6-a77e-11e6-869b-42029cebe6c3.jpg)
- **Extract Feature Descriptor**

  Each of the 500 points taken from ANMS may be characterized by a (41 x 41 pixel) subsample of the overall image take around that point.  Within that 41 x 41 patch, pixels were sampled at intervals of 5 pixels, resulting in an 8 x 8 pixel feature descriptor for each point.  Sampling from within the 41 x 41 patch creates a blurring effect, which improves the robustness of the algorithm in comparing feature patches across images.

- **Match Feature Descriptors Between Two Images**

  The feature descriptors are compared across pairs of images in order to determine 
  point correspondences across images.  The quality of a match between feature descriptors is determined by the Sum Squared Distance (SSD) of pixel data in each of two descriptors.  In the accompanying image, blue points represent corresponding points, while red points have been discarded.

  ![inliers 1](https://cloud.githubusercontent.com/assets/9031637/20202815/31fbe996-a790-11e6-9e46-9a59ffd36555.jpg)
- **RANSAC**

  Not all of the matches just determined will be correct.  A 4-point RANSAC algorithm is implemented in order to not only eliminate inaccurate matches but also compute a homography, which is a transformation from one 2-dimensional plane to another.  This transformation will later be used to morph one image such that its features correspond to those in another image.  

  It can be seen that RANSAC dramatically improves the accuracy of feature correspondences across two images.

![ransac 1](https://cloud.githubusercontent.com/assets/9031637/20202834/6691e84a-a790-11e6-945d-34fedab8495e.jpg)
- **Generate Image Mosaic**

  Using the homography transformations previously computed for each pair of images, the images are mapped into an overlapping mosaic.  At this point in the project, the RGB values are simply added together across images, which explains the increase in intensity where multiple images overlap.

![stitched image](https://cloud.githubusercontent.com/assets/9031637/20202916/1dc4cca8-a791-11e6-9d3d-d3ddcea40b9d.jpg)

- **Blending Images In Mosaic**

  Lastly, and beyone the scope of the project, I implemended an alpha feathered blending of the images.  In overlapping regions, this feature decreases RGB color intensity as the distance from the source image increases.  With this feature, it becomes nearly impossible to distinguish between images!

![cityscape mosaic](https://cloud.githubusercontent.com/assets/9031637/20202977/a16b13f0-a791-11e6-9fb3-1c2d3eb737bd.jpg)