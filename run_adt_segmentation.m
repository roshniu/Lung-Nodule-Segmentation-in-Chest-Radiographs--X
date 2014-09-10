%% ECE  563: Digital Image Processing : Final Paper
% Roshni Uppala
% 05/02/2013
% Lung nodule segmentation in chest radiographs (X-Rays) using the adaptive
% distance-based threshold method

%%
% Loading the data
load roi_exam; 
% Adaptive threshold parameter is the offset T_0
T_0 = -2:0.01:2;
% Range of T_0 is manually set to a maximum of 2. Beyond 2, there is no
% pixel which gets segmented
% Initializing
avg_radial_gradient = zeros(length(T_0),1);
%% Looping through each nodule image to find the best T_0

for img_num = 1:1:length(roi_exam)% loading each nodule data
   
    img = roi_exam{img_num}.cxr_contrast; % Getting the image
    cue_point = round(roi_exam{img_num}.truth_cue);% Getting the data
    lung_mask = roi_exam{img_num}.lung_mask; % Obtaining the lung_mask
   
    % Computing the gradient of the nodule image (Part of Step 6)
    [gradx,grady]=gradient(double(img)); 
    
    for k = 1:1:length(T_0)
        
        % Calling the function adt_segmentation for obtaining the img_mask
        % from adaptive threshold segmentation
        img_mask = adt_segmentation(img,lung_mask,87,87,cue_point(1),cue_point(2),T_0(k),1.7,25,0);
        
        % Using the function radial_gradient_all provided , automatically
        % finding the best T_0 - STEP 6
        [avg_radial_mean,avg_radial_std] = radial_gradient_all( gradx, grady, img_mask,cue_point );
        avg_radial_gradient(k) = avg_radial_mean; % Collecting all the avg_radial_mean per T_0
    end
    
    % display the graph
    % figure(img_num+1);plot(T_0,avg_radial_gradient);
    
    % Finding the maximum value of the average radial gradient curve which
    % will be the optimum value for T_0 for that particular image. 
    [Max,in] = max(avg_radial_gradient);
    T_0_opt = Max; % Setting the obtained optimum value for T_0
    s_mesg = sprintf('\nThe optimum value of T_0 for nodule image %d = %1.5f\n',img_num,Max); % displaying the optimum value for T_0
    disp(s_mesg);
    
    img_mask = adt_segmentation(img,lung_mask,87,87,cue_point(1),cue_point(2),T_0_opt,1.7,25,0); % obtain the final mask with the T_0 optimum value
    s_title = sprintf('Lung nodule image-%d and its segmentation using Adaptive distance based threshold method',img_num);
    im(img); hold on;
    display_masks(img_mask,'b',1);
    title(s_title);
    hold on;
    plot(cue_point(1),cue_point(2),'xr'); % Plotting the cue point used
    for r = 10:5:50 % plotting contour plots around the cue point
        hold on;
        rectangle('Position',[cue_point(1)-r,cue_point(2)-r,2*r,2*r],'Curvature',1,'EdgeColor','r');
    end
    hold off;
end


   
