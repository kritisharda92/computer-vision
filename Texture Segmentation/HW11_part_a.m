function HW11_part_a(filename)

    im_a = imread(filename);
    
    % Considering the l channel of lab because that gives the best
    % seperation between the balls and the carpet 
    
    im_lab = rgb2lab(im_a);
    im_gray = im_lab(:,:,1)/100;
    
    % Smooth the image using gaussian filter in order to reduce noise from
    % the image channel
    fltr_gauss = fspecial( 'gauss', [10 10], 4 );
    im_blur = imfilter(im_gray, fltr_gauss, 'same', 'repl');
    
    % Apply the rangefilter to get the texture features of the
    % pre-processed image. The size of the filter is set to 75.
    im_texture = rangefilt(im_blur,ones(75));
    
    % Binarize the image using binary thresholding and invert the obtained
    % binary image in order to get the balls as white and the background as
    % black
    im_binary = imbinarize(im_texture);
    im_invert = imcomplement(im_binary);
    
    % Apply the open function provided my morphology to remove noise from
    % the image.
    im_open = imopen(im_invert,strel('disk',20));
%     imagesc(im_open);
%     colormap(gray);
%     axis image;
    
    % Apply the dilate filter provided by morphology to increase the 
    % detected area of the balls.
    im_dilate = imdilate(im_open,strel('disk',10));
    
    % Fill the holes in the binary image of the balls 
    im_fill = imfill(im_dilate,'holes');
%     imagesc(im_fill);
%     colormap(gray);
%     axis image;
    
    % Background subtraction by converting the image to hsv, then selecting
    % the v channel and setting all the background values to zero, by
    % refering the binary image and finally displaying the new image.
    im_balls = rgb2hsv(im_a);
    im_ball_v = im_balls(:,:,3);
    im_ball_v(im_fill == 0) = 0;
    im_balls(:,:,3) = im_ball_v;
    imagesc(hsv2rgb(im_balls));
    axis image;
    
end
