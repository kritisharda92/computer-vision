function HW11_part_b(filename)
    
    im_in = imread(filename);
    
    % Considering the r and g channel of lab because that gives the best
    % seperation between the darts and the grass 
    im_r = im_in(:,:,1);
    im_g = im_in(:,:,2);
    im_b = im_in(:,:,3);
    
    
    % Select an appropriate color channel that detects the license number
    % plate from the image.
    
%     im_rg = ((im_r + im_g) - 2 * im_b)/2 - (im_r - im_g)/2;
    im_rg = im_g - im_b;
    
    
    % Apply the rangefilter to get the texture features of the
    % pre-processed image. The size of the filter is set to 75.
    im_texture = rangefilt(im_rg,ones(75));
    
    % Binarize the image using binary thresholding in order to get the 
    % plate as white and the background as black
    im_binary = imbinarize(im_texture);
    
    % Erode and dilate the image in order to remove all the other noise
    % from the image and just leave the license plate behind
    im_erode = imerode(im_binary,strel('disk',70));
    im_dilate = imdilate(im_erode,strel('rectangle',[80 80]));

    % Background subtraction by converting the image to hsv, then selecting
    % the v channel and setting all the background values to zero, by
    % refering the binary image and finally displaying the new image.
    im_darts = rgb2hsv(im_in);
    im_darts_v = im_darts(:,:,3);
    im_darts_v(im_dilate == 0) = 0;
    im_darts(:,:,3) = im_darts_v;
    imagesc(hsv2rgb(im_darts));
    axis image;
    
end
