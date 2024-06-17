%---------
clear;
clc;
close all;

Imagen = load("project_data.mat");
Pat1_dia = Imagen.patient1_dia;
Pat1_dia = mat2gray(Pat1_dia);

Dim=size(Pat1_dia);

for i=1:Dim(1)
Image_pat1_dia = squeeze(Pat1_dia(i,:,:));

% figure,imshow(Image_pat1_dia);

Imagen_f(i,:,:)=Segmentar(Image_pat1_dia);
%imwrite(Imagen_f{i}, "Imagenes.gif", 'gif', 'WriteMode');
end

for i=1:Dim(2)
Image_pat1_dia = squeeze(Pat1_dia(:,i,:));

% figure,imshow(Image_pat1_dia);

Imagen_f(:,i,:)=Segmentar(Image_pat1_dia);
% Imagen_f=Segmentar(Image_pat1_dia);
% imshow(Imagen_f);

end

for i=1:Dim(3)
Image_pat1_dia = squeeze(Pat1_dia(:,:,i));

% figure,imshow(Image_pat1_dia);

Imagen_f(:,:,i)=Segmentar(Image_pat1_dia);

end

Imagen_f = bwareaopen(Imagen_f, 50000);


%figure,imshow(Imagen_f);
%figure,imhist(Imagen_f);

% Paso 2: Etiquetar las regiones conectadas
labeledVolume = bwlabeln(Imagen_f);

A=labeledVolume==1;

% Paso 3: Obtener las propiedades de las regiones conectadas
stats = regionprops3(labeledVolume, 'Volume', 'BoundingBox', 'Centroid');

disp("Succes");
%disp(labeledVolume);
disp(stats);
%%
image=Image_pat1_dia;

%figure, imhist(image);

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



%%
function Imagen_f = Segmentar(Im)

[count,bin]=histcounts(Im);
otsu=otsuthresh(count);
A = Im>otsu;
disp(ceil(sum(A(:))/20));
A = bwareaopen(A, 100);
Imagen_f=A;

end