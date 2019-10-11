%
% Name: Kriti Sharda
% Date: November 4, 2018
%

function HW08_Sharda_Kriti()
    %
    % Here is a driving routine that runs the function on a bunch of images:
    %
    
    close all;
    addpath('./TEST_IMAGES');
    addpath('../TEST_IMAGES');
    addpath('../../TEST_IMAGES');

    % All of the images are in one directory:
    IMAGE_DIR='../TEST_IMAGES';

    % This con-catentates the IMAGE DIR STRING, to form a pattern to match:
    file_pattern    = [ IMAGE_DIR '/' '*.png' ];

    file_name_list = dir( file_pattern );

    for file_index = 1:length( file_name_list )

        file_name = file_name_list(file_index).name;
        full_name = [ IMAGE_DIR '/' file_name ];
        
        fprintf('\n');fprintf('\n');
        fprintf(file_name);
        fprintf('\n');fprintf('\n');
        
        % Function that processes the tic-tac-toe image and prints out the
        % associated output tic-tac-toe image.
        Tic_Tac_Toe(full_name);
        
     pause(1);
    end
end

function Tic_Tac_Toe(filename)
    
    close all;
    
    % read and diplay the input image 
    im_in = imread(filename);
    subplot(2,3,1)
    imagesc(im_in);
    title('Original Image');
    
    % Select the red channel 
    im_red = im_in(:,:,1);
    
    % I = medfilt2(I,[4 4]);
    % Complement the image in order to make the back-ground dark and make
    % the lines in tic-tak-toe bright
    im_comp = imcomplement(im_red);
    
    % Binarizing the image to get the tic-tac-toe lines, Xs and Os from the
    % image. This also gets rid of any noise in the image.
    im_binary = imbinarize(im_comp);
    subplot(2,3,2)
    imagesc(im_binary);
    colormap(gray);
    title('Binary - Edge Image');
    
    %
    %  Performing the HOUGH TRANSFORM on the binary image to detect the 4
    %  brightest peaks in the hough transform.
    %
    [H,T,R] = hough(im_binary);
    P       = houghpeaks( H, 4, 'threshold', ceil( 0.1*max(H(:)) )  );
    
    %  Get the 4 longest lines in the tic-tak-toe image which correspond to
    %  the 4 brightest peaks in the hough transform
    lines   = houghlines( im_binary, T, R, P );
    
    %
    % Plot and display the resulting lines from the Hough Transform on the 
    % input image
    %
    subplot(2,3,3)
    imagesc(im_binary);
    colormap(gray);
    title('Lines using Hough Transform');
    
    % loop through all the lines, fetch the x-y coordinates of the ends of
    % lines and plot the lines
    for line_index = 1:length(lines)
        this_line = lines(line_index);
        xs          = [ this_line.point1(1) this_line.point2(1) ];
        ys          = [ this_line.point1(2) this_line.point2(2) ];
        hold on;
        plot( xs, ys, 'g-', 'LineWidth', 1.5 );
    end
    
    % The angles that all the lines make are fetched and stored
    lines_angles = T(P(:,2));
    % First angle is picked up and is used to rotate the image
    angle = lines_angles(1);
    
    % Get the rotated image using the angle of line obtained using the
    % hough transform
    im_rotate = Rotate_Image(angle, im_binary);
    
    %
    %  Performing the HOUGH TRANSFORM on the rotated image to detect the 4
    %  brightest peaks in the hough transform of the rotated image.
    %
    [H,T,R] = hough( im_rotate );
    P       = houghpeaks( H, 4, 'threshold', ceil( 0.1*max(H(:)) )  );
    
    lines   = houghlines( im_rotate, T, R, P );
    
    % Array to track all the x-coordinates
    x_coordinates = zeros(8, 1);
    % Array to track all the y-coordinates
    y_coordinates = zeros(8, 1);
    
    count = 1;
    
    % Looping though all the lines and storing the x-y coordinates of the
    % end points of the lines
    for line_index = 1:length(lines)
        this_line = lines(line_index);
        
        x_coordinates(count,1) = this_line.point1(1);
        x_coordinates(count+1,1) = this_line.point2(1);
        y_coordinates(count,1) = this_line.point1(2);
        y_coordinates(count+1,1) = this_line.point2(2);
      
        count = count + 2;     
    end
   
    hold off;

    % Getting the minimun and the maximum values for the x and y
    % coordinates which is used lated to crop the image
    min_x = min(x_coordinates);
    min_y = min(y_coordinates);
    max_x = max(x_coordinates);
    max_y = max(y_coordinates);
    
    % Crop the rotated image to obtain just the tic-tac-toe 
    im_crop = imcrop(im_rotate,[min_x min_y (max_x-min_x) (max_y-min_y)]);
    subplot(2,3,4)
    imagesc(im_crop);
    colormap(gray);
    title('Rotated - Cropped Image');
    
    % Extract only the horizontal and vertical lines out of the image. 
    % Assuming that the longest lines in the image are the horizontal and 
    % vertical lines of the tic-tac-toe 
    im_lines_only = bwareaopen(im_crop , 5000);
    subplot(2,3,5)
    imagesc(im_lines_only);
    colormap(gray);
    title('Lines in Tic-Tac-Toe');
    
    % Performing XOR of the lines image and cropped image to get only 
    % the Xs and the Os
    im_xo = xor(im_crop,im_lines_only);
    subplot(2,3,6)
    imagesc(im_xo);
    colormap(gray);
    title('X-O in Tic-Tac-Toe');
    
    pause(5);
    
    % function call to to detect the x and o region wise and get the final 
    % output image
   Get_X_O(im_xo);
        
end

function im_rotate = Rotate_Image(angle, im_binary)
    
    % Check the input angle and get the corresponding angle by which the 
    % image needs to be rotated.  
    if angle < 0
        if angle > -45
            rotateAngle = angle;
        else
            rotateAngle = 90 + angle;
        end
    else
        if angle > 45
            rotateAngle = angle - 90;
        else
            rotateAngle = angle;
        end
    end
        
    % Rotate the input binary image by the rotateAngle that was calculated
    im_rotate = imrotate(im_binary,rotateAngle,'bilinear','crop');
    
end

function Get_X_O(im_xo)
    
    close all; 
    
    % Get the dimension of the image
    dims = size(im_xo);
    
    % Get the 1/3rd length for both the dimensions. This is done inorder to
    % segment the image into 9 parts
    r_inc = int32(dims(1)/3);
    c_inc = int32(dims(2)/3);
    
    % Loop thorough each segement of the image
    wid = 1;
    for r_index = 1:3
        len = 1;
        wid_inc = wid+r_inc-1;
        
        for c_index = 1:3
            len_inc = len+c_inc-1;
            
            % Set the increment in length/ widhth of the image in cases
            % where the length/breadth of the segment is smaller that the
            % 1/3rd length of dimensions.
            if wid_inc>dims(1)
                wid_inc = dims(1)-1;
            end
            
            if len_inc>dims(2)
                len_inc = dims(2)-1;
            end

            % Get the image of the corresponding segement and display the
            % the image
            image = im_xo(wid:wid_inc, len:len_inc);
            subplot(2,1,1);
            imshow(image);
            
            %
            % Using the process of histogram projection on the image 
            % segment and selecting the projection vertically down the 
            % image. This will give us a histogram shape in which we can
            % count the peaks and get some insights on whether the image
            % contains an X, O or is empty.
            data_hist = sum(image, 1);
            data_hist_smooth = smoothdata(smoothdata(data_hist));
            subplot(2,1,2);
            % bar(data_hist_smooth);
            
            % Setting parameters to find appropriate peaks
            if (max(data_hist_smooth)<6.5)
                min_peak_h = max(data_hist_smooth)-0.1;
            else
                min_peak_h = 6.5;
            end
            
            % Displaying the histogram projection plot and the peaks it
            % contains. Some peaks arise due to noise, but they are getting
            % removed as I have set a threshold height of peaks.
            findpeaks(data_hist_smooth,'MinPeakHeight',min_peak_h,'MinPeakDistance',75);

            peaks = findpeaks(data_hist_smooth,'MinPeakHeight',min_peak_h,'MinPeakDistance',75);
            num_peaks = sum(peaks>6.5);
            
            % Printing the tic-tac-toe
            if (num_peaks>1)
                value = 'O';
            elseif (num_peaks==1)
                value = 'X';
            else
                value = '_';
            end
            
            if c_index == 3
                    fprintf('%s',value)
            else
                    fprintf('%s  ',value);
            end
            
            pause(1);

           len = len_inc+1;
        end
        fprintf('\n');
        wid = wid_inc+1;
    end 
end