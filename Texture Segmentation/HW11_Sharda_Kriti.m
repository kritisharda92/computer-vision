function HW11_Sharda_Kriti()
    %
    % Here is a driving routine that runs the function on all the given
    % images
    %
    
    close all;
    
    % Add path of the image folder
    addpath('./HW_TEXTURE_Images');
    addpath('../HW_TEXTURE_Images');
    addpath('../../HW_TEXTURE_Images');
    
    file_a = ('./HW_TEXTURE_Images/IMG_A_FOUR_BALLS_RGBY.jpg');
    file_b = ('./HW_TEXTURE_Images/IMG_B_ANPR_RIT_BAJA__LICENSE_PLATE.jpg');
    file_c = ('./HW_TEXTURE_Images/IMG_C_NERF_DARTS.JPG');
    
    % The processing of the images takes time because the images have not
    % been sub sampled. The function can be commented or uncommented
    
%     HW11_part_a(file_a);
%     HW11_part_b(file_b);
    HW11_part_c(file_c);
    
end
