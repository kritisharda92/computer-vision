function HW07_Sharda_Kriti_MAIN()
    %
    % Here is a driving routine that runs the function on a bunch of images:
    %
    
    close all;
    addpath('./TEST_IMAGES');
    addpath('../TEST_IMAGES');
    addpath('../../TEST_IMAGES');

    % All of the images are in one directory:
    IMAGE_DIR='../TEST_IMAGES 2';

    % This con-catentates the IMAGE DIR STRING, to form a pattern to match:
    file_pattern    = [ IMAGE_DIR '/' '*.jpg' ];

    file_name_list = dir( file_pattern );

    for file_index = 1:length( file_name_list )

        file_name = file_name_list(file_index).name;
        full_name = [ IMAGE_DIR '/' file_name ];

        count = countMelons(full_name);
        cutMellons(full_name, count);
     pause(1);
    end
end

function count = countMelons(filename)
    
    % Reading the image and converting it to double precision
    im_in = im2double(imread(filename));
    imshow(im_in);
    pause(5);
    
    %
    % Converting the image to lab and choosing the a-channel to count the
    % number of melons in the image
    im_lab = rgb2lab(im_in);
    im_a = im_lab(:,:,2);
    
    %
    % Using the process of histogram projection on the a-channel and
    % selecting the projection horizontally across the image. This will
    % give us peaks in places where the slice of melons have been placed.
	data_hist = sum(im_a, 2);
    
    %
    % Smoothing the histogram projection so that there are no sharp and
    % pointy peaks that can give us a wrong count of the mellons. We smooth
    % the image twice because then the smoothening is more accurate.
    data_hist_smooth = smoothdata(smoothdata(data_hist));
    
    % count the number of peaks 
    data_peaks = findpeaks(data_hist_smooth);
    
    % Setting a threshold for peaks, this removes any noise that has been 
    % detected as a peak by mistake  
    count = sum(data_peaks > 1500);
    
    disp("There are " + count + " pieces of melon");
%     bar(data_hist_smooth);
%     pause(5);
    
end

function cutMellons(filename, melons_count)

    % The image is read and converted to double precision.
    im_in = im2double(imread(filename));
    
    % The image is converted into lab color space and the a-channel is 
    % selected for this function because it gives the maximum separation 
    % between the green and red color, i.e. the skin and the flesh color.
    im_lab = rgb2lab(im_in);
    im_a = im_lab(:,:,2);

    
    % To adjust the contrast and exposure of the image, adaptive histogram 
    % is used on the a-channel
    im_a = adapthisteq(im_a);

    % Detecting the gradient along the vertical directing in order to get 
    % the horizontal edges in the a-channel image
    fltr_edge   = [ -1 -2 -1 ;
                     0  0  0 ;
                     1  2  1 ] / 8;
    % fltr_hz         = fltr.';
                
    im_edge         = imfilter( im_a, fltr_edge, 'same', 'repl' );
    % im_edge_hz         = imfilter( im_a, fltr_hz, 'same', 'repl' );
    % im_edge = (im_edge_vt.^(2) + im_edge_hz.^(2)).^(1/2);

    %
    % gaussian filter has been used on the edges that have been detected. 
    % This helps us get ride of unwanted noise in the background.
    fltr_gauss = fspecial( 'gauss', [13 13], 4 );
    im_blur = imfilter(im_edge, fltr_gauss, 'same', 'repl');

    %
    % Otsu threshold is calculated here.
    thresh = graythresh(im_blur);
    % The above threshold is used to binarize the pre-processed image.
    im_binary = imbinarize(im_blur, thresh);

    % Bwlabel is used to get the total number of regions in the image
    [region_map, N] = bwlabel(im_binary);

    % Initializing vector to store the area of each region and the area
    % of the melons in the image.
    region_area = zeros(N, 1);
    mellon_areas = zeros(melons_count,1);
    
    % New region is defined that will store only the regions that detect
    % the melons
    new_region = zeros(size(region_map));
    
    % Calculate the total number of pixels in each region or the area of
    % each region and store it in a vector.
    for id = 1:N
        im_temp = (region_map == id);
        region_area(id) = sum(im_temp(:));
    end

    %
    % Set all the other regions, that are not the melon regions, to zero. 
    % this will give us the regions that contains the melons
    for num = 1 : melons_count
        [~, index] = max(region_area);
        mellon_areas(num) = index;
        region_area(index) = 0;
    end
    
    %
    % Plotting a new region map for the regions that contain the melons.
    for id = mellon_areas.'
        tempMatrix = (region_map == id);
        new_region = new_region | tempMatrix;
    end
    
    
    % imshow(new_region);
    
    % 
    % Erosion is done to remove small salt and pepper noise from the final
    % image
    %
    se = strel('disk',3);
    im_ero = imerode(new_region,se);

    % imshow(im_ero);

    [x, y] = find(im_ero);
    
    %
    % Setting the corresponding x and y pixels of each color channel to the
    % given values. Basically making those pixels blue in color.
    for pixel = 1:length(x)
        im_in(x(pixel),y(pixel),1) = 0;
        im_in(x(pixel),y(pixel),2) = 0;
        im_in(x(pixel),y(pixel),3) = 255;
    end

    imshow(im_in);
    pause(3);

end





