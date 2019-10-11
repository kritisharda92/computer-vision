function HW11_part_c(filename)

    im_in = imread(filename);
    
    % Considering the r and g channel of lab because that gives the best
    % seperation between the darts and the grass 
    im_r = im_in(:,:,1);
    im_g = im_in(:,:,2);
    
    % Removing the traces of green channel from the red channel inorder to
    % detect the darts correctly
    im_rg = im_r - im_g;
    
    % Apply the rangefilter to get the texture features of the
    % pre-processed image. The size of the filter is set to 75.
    im_texture = rangefilt(im_rg,ones(75));
    
    % Binarize the image using binary thresholding in order to get the 
    % darts as white and the background as black
    im_binary = imbinarize(im_texture);
        
    % Fill the holes in the binary image of the darts if any are present 
    im_fill = imfill(im_binary,'holes');
    im_erode = imerode(im_fill,strel('disk',30));
    
    % Counting the number of darts using the bwlabel and displaying the
    % number of darts as the title of the image
    [~,num_darts] = bwlabel(im_erode);
    number = "Number of darts = " + num_darts;
    disp(number);

    % Background subtraction by converting the image to hsv, then selecting
    % the v channel and setting all the background values to zero, by
    % refering the binary image and finally displaying the new image.
    im_darts = rgb2hsv(im_in);
    im_darts_v = im_darts(:,:,3);
    im_darts_v(im_erode == 0) = 0;
    im_darts(:,:,3) = im_darts_v;
    imagesc(hsv2rgb(im_darts));
    title(number);
    axis image;
    
end
