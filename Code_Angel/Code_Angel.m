%---------
clear;
clc;
close all;

Imagen = load("project_data.mat");
Pat1_dia = Imagen.patient1_dia;
Pat1_dia = mat2gray(Pat1_dia);
Image_pat1_dia = squeeze(Pat1_dia(:,117,:));

% figure,imshow(Image_pat1_dia);

Imagen_f=Segmentar(Image_pat1_dia);

figure,imshow(Imagen_f);

figure,imhist(Imagen_f);


%%
image=Image_pat1_dia;

figure, imhist(image);

% Compute the histogram
counts = imhist(image);

% Determine the number of thresholds (classes - 1)
num_classes = 3; % For example, segmenting into 3 classes, we need 2 thresholds

% Apply multi-level Otsu's thresholding
thresholds = multithresh(image, num_classes - 1);

% Segment the image using the thresholds
segmented_image = imquantize(image, thresholds);

% Display the original and segmented images
figure;
subplot(1, 2, 1);
imshow(image);
title('Original Image');

subplot(1, 2, 2);
imshow(segmented_image, []);
title('Segmented Image');

% Assign class colors for better visualization
segmented_image_rgb = label2rgb(segmented_image);

figure;
imshow(segmented_image_rgb);
title('Segmented Image with Class Colors');

BW = bwareaopen(A, 500);

%%
function Imagen_f = Segmentar(Im)

[count,bin]=histcounts(Im);
otsu=otsuthresh(count);
A = Im>otsu;
A = bwareaopen(A, 500);
Imagen_f=A;

end