img = imread('final_experiments/real/mask_cc_DT_raw.png');
% imagesc(img(:,500:1100,:)); axis image;
% return
imwrite(img(:,500:1100,:), 'figs/mask_cc_DT.png');
