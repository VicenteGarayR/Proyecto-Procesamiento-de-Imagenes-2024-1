%%
clear;
close all;
clc;

Imagen = load("project_data.mat");
Pat1_dia = Imagen.patient1_dia;
Pat1_dia = mat2gray(Pat1_dia);
Image_pat1_dia = squeeze(Pat1_dia(:,117,:));

A=Segmentar(Image_pat1_dia);

distanceTransform = bwdist(~A);
distanceTransform=1-distanceTransform;
%distanceTransform =1-distanceTransform;
figure,imshow(distanceTransform,[]);

[X, Y] = meshgrid(1:size(distanceTransform, 2), 1:size(distanceTransform, 1));
Z = double(distanceTransform);

figure;
mesh(X, Y, Z);
% Encontrar los mínimos extendidos (marcadores)
markers = imextendedmin(distanceTransform,0.6);

% Modificar la transformación de distancia para forzar los mínimos
modifiedDistance = imimposemin(distanceTransform, markers);

% Aplicar la segmentación por watershed
L = watershed(modifiedDistance,4);

% Superponer los resultados de watershed sobre la imagen original
segmentedImg = L;

% Mostrar las imágenes
figure;

subplot(2, 2, 1);
imshow(A);
title('Imagen en escala de grises');

subplot(2, 2, 2);
imshow(A);
title('Imagen binarizada');

subplot(2, 2, 3);
imshow(distanceTransform, []);
title('Transformada de distancia');
%colormap jet; % Aplicar un mapa de colores
%colorbar; % Mostrar la barra de colores

subplot(2, 2, 4);
imshow(segmentedImg,[]);
title('Segmentación por Watershed');

Imagen=load("project_data.mat");
Imagen=Imagen.patient1_dia;

figure;
for i=1:208
    
Imagen_1=squeeze(mat2gray(Imagen(:,i,:)));
imshow(Imagen_1);


A=Imagen_1>0.5;
BW = bwareaopen(A, 500); % Ajusta el tamaño mínimo de los objetos
%B=Imagen.*A;
subplot(1,2,1);
imshow(BW);
L=bwlabel(BW,4);
numele= max(max(L));
subplot(1,2,2);
%M= L==1;
imshow(L,[]);
pause(0.01);
end


%%
function Imagen_f = Segmentar(Im)

[count,bin]=histcounts(Im);
otsu=otsuthresh(count);
A = Im>otsu;
A = bwareaopen(A, 500);
Imagen_f=A;

end

