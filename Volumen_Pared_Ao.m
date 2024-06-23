clear;
clc;
close all;
load patient1_dia.mat
load patient1_sys.mat
load patient2_dia.mat
load patient2_sys.mat

volshow(aop1_sys_black);
Vol_Pared_Ao(aop1_sys_black);


function totalVolume=Vol_Pared_Ao(Vol)
    
    element=strel('cube',1);
    % Definir un elemento estructurante adecuado (por ejemplo, un disco pequeño)
    se = strel('disk', 10);
    
    [counts , bin]=imhist(Vol);
    
    otsu=0.5*otsuthresh(counts);
    N=imbinarize(Vol,otsu);
    
    distanceTransform = bwdist(~N);
    filteredImage = medfilt3(distanceTransform);

    N=imopen(N,element);
    
    % Aplicar el filtro de Sobel 3D para detectar bordes
    sobelX = [-1 0 1; -2 0 2; -1 0 1]; % Filtro Sobel en dirección X
    sobelY = sobelX'; % Filtro Sobel en dirección Y
    sobelZ = cat(3, [-1 -2 -1; 0 0 0; 1 2 1]); % Filtro Sobel en dirección Z
    
    % Aplicar convolución con los filtros Sobel
    gradX = convn(filteredImage, sobelX, 'same');
    gradY = convn(filteredImage, sobelY, 'same');
    gradZ = convn(filteredImage, sobelZ, 'same');
    
    % Calcular la magnitud del gradiente
    magnitudeGrad = sqrt(gradX.^2 + gradY.^2 + gradZ.^2);

    % Umbralizar para obtener bordes
    edges3D=imbinarize(magnitudeGrad,0.4);

    % Definir el tamaño de voxel (por ejemplo, cada voxel es de 1x1x1 mm)
    voxelSize = [1, 1, 1]; % en mm
    
    % Calcular el volumen del voxel
    voxelVolume = prod(voxelSize); % volumen del voxel en mm^3  
    
    % Calcular el número de voxeles en la región de interés
    numVoxels = sum(N(:));
    
    % Calcular el volumen total de la región de interés
    totalVolume = numVoxels * voxelVolume;

%     volshow(N);
%     volshow(distanceTransform);
%     volshow(filteredImage);
    volshow(edges3D);
    
    save('aop1_sys_black_Filtrado.mat','edges3D','filteredImage');

end


% Función para rellenar NaNs basada en la media de los vecinos
% function matrix = inpaint_nans(matrix)
%     [m, n] = size(matrix);
%     [i, j] = find(isnan(matrix));
%     for k = 1:length(i)
%         neighbors = [];
%         if i(k) > 1
%             neighbors = [neighbors, matrix(i(k)-1, j(k))];
%         end
%         if i(k) < m
%             neighbors = [neighbors, matrix(i(k)+1, j(k))];
%         end
%         if j(k) > 1
%             neighbors = [neighbors, matrix(i(k), j(k)-1)];
%         end
%         if j(k) < n
%             neighbors = [neighbors, matrix(i(k), j(k)+1)];
%         end
%         matrix(i(k), j(k)) = mean(neighbors(~isnan(neighbors)));
%     end
% end
