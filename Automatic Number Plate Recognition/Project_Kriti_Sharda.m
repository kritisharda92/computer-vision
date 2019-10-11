% Author: Kriti Sharda
% Date: December 16, 2018

function Project_Kriti_Sharda()

    % Read the input image which contained the yellow license plate to be detected
    im_in = imread('IMG_2941.JPG');    
% %     im_in = imread('IMG_2389.JPG');
% %     im_in = imread('IMG_B_ANPR_RIT_BAJA__LICENSE_PLATE.JPG');
% %     im_in = imread('ROAD_SGN_237.JPG');
% %     im_in = imread('ROAD_SGN_247.JPG');
% %     im_in = imread('VORONOI_ANPR_IMG_20151003_135604.JPG');
% %     im_in = imread('IMG_20150715_165613.JPG');
% %     im_in = imread('IMG_3231.JPG');
% %     im_in = imread('IMG_2954.JPG');
% %     im_in = imread('IMG_2388.JPG');


    % Tried using Sub-sampling the image
%     im_in = im_in(1:2:end,1:2:end,:);
    
    close all;
    
    % Extract the red, green and blue channels of the inout image in order
    % to create a new color channel to detect the number plate
    im_r = im_in(:,:,1);
    im_g = im_in(:,:,2);
    im_b = im_in(:,:,3);
    
    
    % Select and combine the color channels in order to find an appropriate 
    % color channel will help in the detection of the number plate
    
%     im_rg = ((im_r + im_g) - 2 * im_b)/2 - (im_r - im_g)/2;
    im_rg = im_g - im_b;
    
%     imshow(im_rg);
%     pause(2);
    
    
    % Using the rangeflt - range filter to perform texture segmentation on
    % the image, by detecting the texture features of the enhanced image. 
    % The size of the range filter is taken as 75.
    im_texture = rangefilt(im_rg,ones(75));
    
    % Binarizing the segmented image using binary thresholding in order to 
    % get a black and white image such that the plate is detected as the 
    % white foreground and the background as the black background
    im_binary = imbinarize(im_texture);
    
%     imshow(im_binary);
%     pause(2);
    
    % Perform Morphology by Eroding and dilating the image in order to 
    % remove some of the noise that was detected as the foreground.
    % 'Disk' structural element is used to erode the image and 'rectangle'
    % structural element is used to dilated the image.
    im_erode = imerode(im_binary,strel('disk',40));
    im_dilate = imdilate(im_erode,strel('rectangle',[50 50]));
    
%     imshow(im_dilate);
%     pause(2);
    
    % All the fore ground regions detected are extracted in a region map
    % and the count of the total regions detected is also fetched using the
    % bwlabel function in matlab
    [region_map, N] = bwlabel(im_dilate,8);
    
%     imshow(region_map);
%     pause(2);
            
    % For loop to iterate over all the regions and check some constarints
    % on the region in order to detect the region that contains the number
    % plate
    for id = 1:N
        im_temp = (region_map == id);
        area = bwarea(im_temp);
        
        % Constraint on the area of the regions
        if (area < 40000||area > 352000)
             region_map(im_temp) = 0;
        else
            stats = regionprops(im_temp,'Extrema');
            
            % Fetching all the Extrema points or coordinates of the region
            xy_matrix = stats.Extrema;
            x_min = min(xy_matrix(:,1));
            x_max = max(xy_matrix(:,1));
            y_min = min(xy_matrix(:,2));
            y_max = max(xy_matrix(:,2));
            
            x_len = x_max - x_min;
            y_len = y_max - y_min;
            
            ratio = x_len / y_len;
            
            % Constraint on the dimentions of the regions and the ratio
            % between the length and width of the region detected
            if (x_len > 950 || x_len < 300 || ratio < 1.40 || ratio > 2.50)
                region_map(im_temp) = 0;
            end
        end
    end
    
%     imshow(region_map);
%     pause(2);
    
    % Set the dilated image back to the region map, which now contains only
    % one region where the number plate is present. 
    im_dilate = region_map;


    % Subtarcting the Background from the image and just displaying the 
    % license plate by converting the image to hsv first, next selecting
    % the v channel of the hsv image and assigning all the background
    % pixels a values of zero, by refering the binary image.
    % Finally the new output image is displayed.
    im_plate = rgb2hsv(im_in);
    im_plate_v = im_plate(:,:,3);
    im_plate_v(im_dilate == 0) = 0;
    im_plate(:,:,3) = im_plate_v;
    roi = hsv2rgb(im_plate);
%     imagesc(roi);
%     axis image;
%     pause(2);

    % Fetching the properties of the region using the regionprops function
    stats=regionprops(im_dilate,'Centroid','Area','BoundingBox');
    
    % Load and hold the image so that the bounding box can be displayed on
    % top of this image
    imshow(im_in);
    hold on;
    
    % Loop through all the statistics collected using region props fucntion
    % and 
    for k = 1 : length(stats)
      % Fetch the bounding box of each of the region that gets detected.
      thisBlobsBoundingBox = stats(k).BoundingBox;  
      
      % Plot a rectangular bounding box around the number plate region that
      % gets detected. The bounding box have a dotted edge and the edge
      % color will be red.
      rectangle('Position', thisBlobsBoundingBox, ...
        'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
    end
    
    pause(2);
    hold off;
    
    % Crop the region of the number plate that got detected using the
    % coordinates of the bounding box. Store the image cropped in a new
    % image
    imCrop = imcrop(im_in, thisBlobsBoundingBox);
    
%     imshow(imCrop);
%     pause(2);
    
    % Function the pre-process the licence plate cropped image and tries to
    % perform OCR on it, in order to read the text present on the number
    % plate.
    letsDoOCR(imCrop)
    
end

function letsDoOCR(im_plate)

    % convert the input image to double precision
    im_in = im2double(im_plate);
    
    % Calculate an appropriate yellow channel by calculating the average of
    % the red channel and green channel of the input image
    im_r = im_in(:,:,1);
    im_g = im_in(:,:,2);
%     im_b = im_in(:,:,3);
    im_y = (im_r + im_g)/2;
%     im_y = im_g - im_b;
%     imshow(im_y);
%     pause(2);

    % Take the Complement of the the image in order to make all the text 
    % brighter which depicts the foreground and all the background other 
    % regions darker which depicts the back ground.
    im_comp = 1-im_y;
    
    % Binarizing the image using imbinarize and setting the treshold value
    % to 1.1 times the otsu threshold value that is calculated using the
    % graythresh fucntion
    im_binary = imbinarize(im_comp,1.1*graythresh(im_comp));
    
    % Blur and smoothen out the binary image using median filter in order 
    % to remove any noise fron the image
    im_binary = medfilt2(im_binary,[4,4]);
%     imshow(im_binary);
%     pause(2);
        
    % Performing the OCR function provided by matlab on the pre-processed 
    % license plate image in order to detect the text present on the 
    % licence plate.
    im_ocr = ocr(im_binary);
    % Fetching just the text from the ocr function
    plate_text = im_ocr.Text;  
    
    % Display the text on top of the image as well as an output on the
    % console
    figure;
    imshow(im_in);
    text(0, 0, plate_text, 'BackgroundColor', [1 1 1]);
    disp(plate_text);
    
end

