%%
clc
clear
close all
%%
load("patient1_dia.mat")
load("patient2_dia.mat")
load("patient1_sys.mat")
load("patient2_sys.mat")
load("aop1_sys_black_Filtrado.mat")
%%
%imagen a utilizar
img = mask_p1_dia;
walls = aop1_dia_black;

%% Volumen
volumen_p1_dia= Volumenp1_dia * 0.0033750; %ml
volumen_p2_dia= Volumenp2_dia * 0.0033750; %ml
volumen_p1_sys= Volumenp1_sys * 0.0033750; %ml
volumen_p2_sys= Volumenp2_sys * 0.0033750; %ml
%% Diametro union sinotubular

[rows, cols, depth] = size(img);
circularityThreshold = 0.8;
areaThreshold = 15;

two_areas_pos = 0;

for z = rows:-1:1
    % Extraer el plano XZ
    XZ = squeeze(img(z,:,:));

    BW = XZ > 0;
     
    stats = regionprops(BW, 'Area', 'Perimeter', ...
        'Centroid', 'MajorAxisLength', 'MinorAxisLength');

    numAreas = numel(stats);
    
    % Inicializar contadores
    circularRegions = 0;
    
    for k = 1:numAreas
        % Calcular la circularidad
        area = stats(k).Area;
        perimeter = stats(k).Perimeter;
        circularity = (4 * pi * area) / (perimeter ^ 2);
        
        % Determinar si la región es circular
        if circularity >= circularityThreshold && area > areaThreshold
            circularRegions = circularRegions + 1;
        end
    end
    
    % Si hay dos areas circulares hacemos break
    if circularRegions >= 2
        two_areas_pos = z;
        break;
    end
end


%Encontrar el diametro maximo de los 4 pixeles más abajo de z

maxDiameter = 0;
maxZ = two_areas_pos;
for z = max(1, two_areas_pos-6):two_areas_pos
    XZ = squeeze(img(z,:,:));
    BW = imbinarize(XZ);
    stats = regionprops(BW, 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Perimeter', 'Centroid');
    
    for k = 1:numel(stats)
        area = stats(k).Area;
        perimeter = stats(k).Perimeter;
        circularity = (4 * pi * area) / (perimeter ^ 2);
        
        if circularity >= circularityThreshold
            diameter = mean([stats(k).MajorAxisLength, stats(k).MinorAxisLength]);
            if diameter > maxDiameter
                maxDiameter = diameter;
                sinotubular_pos = z;
                maxCenters = stats(k).Centroid;
                maxAreas = area;
            end
        end
    end
end

if maxDiameter > 0
    figure(1);
    imshow(squeeze(img(sinotubular_pos,:,:)), []);
    xlabel('X');
    ylabel('Z');
    title('Sinotubular junction diameter');

    % Dibujar el círculo
    hold on;
    viscircles(maxCenters, maxDiameter / 2, 'EdgeColor', 'r');
    
    
    % Añadir anotaciones a la imagen con área y diámetro
    %textString = sprintf('Area: %.2f mm²\nDiam: %.2f mm', maxAreas * (1.5^2), maxDiameter * 1.5);
    %text(maxCenters(1), maxCenters(2), textString, 'Color', ...
      %  'red', 'FontSize', 8, 'HorizontalAlignment', 'center');
    
    hold off;
    fprintf('Diametro unión sinotubular: %.2f mm\n', maxDiameter * 1.5); 
else
    fprintf('No se detectaron suficientes formas circulares.\n');
end


%% Diametro aorta ascendente y descendente

figure(2)

asc_desc_pos = two_areas_pos - 20;

XZ = squeeze(img(asc_desc_pos,:,:));
BW = imbinarize(XZ);
stats = regionprops("table", BW, "Centroid", "MajorAxisLength", "MinorAxisLength", "Area");

numAreas = numel(stats);

% Obtener los centros y diámetros de las regiones
centers_asc_desc = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength], 2);
radii = diameters / 2;
areas = stats.Area;

imshow(XZ, []);
hold on;

viscircles(centers_asc_desc, radii);

% Añadir anotaciones de área y diámetro
for k = 1:length(centers_asc_desc)
    center = centers_asc_desc(k, :);
    
    % Formatear el texto con área y diámetro
   % textString = sprintf('Area: %.2f mm²\nDiam: %.2f mm', areas(k)*(1.5^2), diameters(k)*1.5);
    
   % text(center(1), center(2), textString, 'Color', ...
     %   'red', 'FontSize', 8, 'HorizontalAlignment', 'center');
end

[maxDiametro, mId] = max(diameters);
[minDiametro, minId] = min(diameters);


fprintf('Diametro aorta ascendente: %.2f mm\n', maxDiametro * 1.5); 
fprintf('Diametro aorta descendente: %.2f mm\n', minDiametro * 1.5); 

xlabel('X');
ylabel('Z');
title('Ascending and descending aorta diameter');

%% Diametro arco aortico

circularityThreshold = 1;

circularDiameters = [];
centers = [];
areas = [];
arch_pos = 0;

% Contador de imágenes consecutivas con círculos
consecutiveCircularImages = 0;

% Variables para almacenar los datos del último círculo detectado
lastImage = [];
lastCenter = [];
lastArea = [];
lastDiameter = [];
half_rows = round(rows / 2);

for y = 1:cols
    % Extraer el plano YZ
    YZ = squeeze(img(:, y, :));

    BW = imbinarize(YZ);
    stats = regionprops(BW, 'Area', 'Perimeter', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');

    % Saber si la imagen es circulo
    foundCircularRegion = false;

    % Buscar las áreas circulares
    for k = 1:numel(stats)
   
        area = stats(k).Area;
        perimeter = stats(k).Perimeter;
        circularity = (4 * pi * area) / (perimeter ^ 2);
    
        % Verificar que el área tenga más de 10 píxeles
        if circularity >= circularityThreshold && area > 10 && stats(k).Centroid(2) <= half_rows

            diameter = mean([stats(k).MajorAxisLength, stats(k).MinorAxisLength]);

            lastImage = YZ;
            lastCenter = stats(k).Centroid;
            lastArea = area;
            lastDiameter = diameter;
            arch_pos = y;

            % Indicar que se encontró un círculo en la imagen actual
            foundCircularRegion = true;
            break;
        end
    end

    % Actualizar el contador de imágenes consecutivas con círculos
    if foundCircularRegion
        consecutiveCircularImages = consecutiveCircularImages + 1;
    else
        consecutiveCircularImages = 0;
    end

    % Detener el bucle si se encontraron tres imágenes consecutivas con círculos
    if consecutiveCircularImages >= 5
        break;
    end
end

% Mostrar la última imagen con la forma circular detectada y sus propiedades
if ~isempty(lastImage)
    figure (3);
    imshow(lastImage, []);
    hold on;
    plot(lastCenter(1), lastCenter(2), 'ro', 'MarkerSize', 10); % Marcar el centro con un círculo rojo
   % textString = sprintf('Area: %.2f mm^2\nDiametro: %.2f mm', ...
    %    lastArea * (1.5^2), lastDiameter * 1.5);
    % text(lastCenter(1) + 10, lastCenter(2), textString, 'Color', 'red', 'FontSize', 10); % Mostrar el texto
    title('Aortic arch diameter');
    xlabel('Z');
    ylabel('Y');
    hold off;

    fprintf('Diametro arco aórtico: %.2f mm\n', lastDiameter * 1.5); 
else
    disp('No se encontraron suficientes imágenes consecutivas con áreas circulares.');
end

%% Sinotubular wall diameter

% Asumimos que walls_XZ es una imagen binaria
walls_XZ = squeeze(walls(sinotubular_pos,:,:)) > 0;

% Obtener las propiedades de las regiones en walls_XZ
walls_stats = regionprops(walls_XZ, 'MajorAxisLength', 'MinorAxisLength', 'Centroid', 'Area');

found_circle = false;
threshold_distance = 10; % Ajustar según sea necesario

for i = 1:length(walls_stats)
    % Encontrar la región con el área más grande que esté cerca de maxCenters
    [~, maxIdx] = max([walls_stats.Area]);
    largest_circle = walls_stats(maxIdx);

    % Calcular el diámetro y el centroide del círculo más grande
    walls_diameter = min([largest_circle.MajorAxisLength, largest_circle.MinorAxisLength]);
    walls_centroid = largest_circle.Centroid;

    % Calcular la distancia entre los centroides
    distance = sqrt((walls_centroid(1) - maxCenters(1))^2 + (walls_centroid(2) - maxCenters(2))^2);

    % Verificar si la distancia está dentro del umbral
    if distance <= threshold_distance
        found_circle = true;
        break;
    else
        % Eliminar el círculo considerado y continuar con el siguiente
        walls_stats(maxIdx) = [];
    end
end

if found_circle
    figure(4);
    imshow(squeeze(walls(sinotubular_pos,:,:)), []);
    xlabel('X');
    ylabel('Z');
    title('Sinotubular junction diameter');

    % Dibujar el círculo para sinotubular junction
    hold on;
    viscircles(maxCenters, maxDiameter / 2, 'EdgeColor', 'r');
    
    % Dibujar el círculo para walls
    viscircles(walls_centroid, walls_diameter / 2, 'EdgeColor', 'b'); % Círculo azul para walls
    
    hold off;
    fprintf('Diametro pared aortica union sinotubular: %.2f mm\n', walls_diameter * 1.5); 
else
    fprintf('No se detectó un círculo adecuado en walls.\n');
end

%% Diametro pared aortica ascendente y descendente

walls_XZ = squeeze(walls(asc_desc_pos,:,:)) > 0;
walls_stats = regionprops("table", walls_XZ, "Centroid", "MajorAxisLength", "MinorAxisLength", "Area");

found_circle1 = false;
found_circle2 = false;
threshold_distance = 10; % Ajustar según sea necesario

% Inicializar variables para los círculos encontrados en walls
walls_diameter1 = 0;
walls_centroid1 = [];
walls_diameter2 = 0;
walls_centroid2 = [];

for i = 1:height(walls_stats)
    % Calcular la distancia entre los centroides
    distance1 = sqrt((walls_stats.Centroid(i,1) - centers_asc_desc(mId,1))^2 + ...
                     (walls_stats.Centroid(i,2) - centers_asc_desc(mId,2))^2);
    distance2 = sqrt((walls_stats.Centroid(i,1) - centers_asc_desc(minId,1))^2 + ...
                     (walls_stats.Centroid(i,2) - centers_asc_desc(minId,2))^2);

    % Verificar si la distancia está dentro del umbral y si el área es mayor
    if distance1 <= threshold_distance && walls_stats.Area(i) > walls_diameter1
        walls_diameter1 = min([walls_stats.MajorAxisLength(i), walls_stats.MinorAxisLength(i)]);
        walls_centroid1 = walls_stats.Centroid(i, :);
        found_circle1 = true;
    end

    if distance2 <= threshold_distance && walls_stats.Area(i) > walls_diameter2
        walls_diameter2 = min([walls_stats.MajorAxisLength(i), walls_stats.MinorAxisLength(i)]);
        walls_centroid2 = walls_stats.Centroid(i, :);
        found_circle2 = true;
    end
end

if found_circle1 && found_circle2
    figure(5);
    imshow(squeeze(walls(asc_desc_pos,:,:)), []);
    xlabel('X');
    ylabel('Z');
    title('Aorta walls diameter');

    % Dibujar el círculo para la aorta ascendente
    hold on;
    viscircles(walls_centroid1, walls_diameter1 / 2, 'EdgeColor', 'r'); % Círculo rojo para walls ascendente
    
    % Dibujar el círculo para la aorta descendente
    viscircles(walls_centroid2, walls_diameter2 / 2, 'EdgeColor', 'b'); % Círculo azul para walls descendente
    
    hold off;
    fprintf('Diametro pared aortica ascendente: %.2f mm\n', walls_diameter1 * 1.5); 
    fprintf('Diametro pared aortica descendente: %.2f mm\n', walls_diameter2 * 1.5); 
else
    fprintf('No se detectaron círculos adecuados en walls.\n');
end

%% Diametro pared aortica arco

walls_XZ = squeeze(walls(:,arch_pos,:)) > 0;

% Obtener las propiedades de las regiones en walls_XZ
walls_stats = regionprops(walls_XZ, 'MajorAxisLength', 'MinorAxisLength', 'Centroid', 'Area');

found_circle = false;
threshold_distance = 15; % Ajustar según sea necesario

for i = 1:length(walls_stats)
    % Encontrar la región con el área más grande que esté cerca de maxCenters
    [~, maxIdx] = max([walls_stats.Area]);
    largest_circle = walls_stats(maxIdx);

    % Calcular el diámetro y el centroide del círculo más grande
    walls_diameter = min([largest_circle.MajorAxisLength, largest_circle.MinorAxisLength]);
    walls_centroid = largest_circle.Centroid;

    % Calcular la distancia entre los centroides
    distance = sqrt((walls_centroid(1) - lastCenter(1))^2 + (walls_centroid(2) - lastCenter(2))^2);

    % Verificar si la distancia está dentro del umbral
    if distance <= threshold_distance
        found_circle = true;
        break;
    else
        % Eliminar el círculo considerado y continuar con el siguiente
        walls_stats(maxIdx) = [];
    end
end

if found_circle
    figure(6);
    imshow(squeeze(walls(:,arch_pos,:)), []);
    xlabel('X');
    ylabel('Z');
    title('Sinotubular junction diameter');

    % Dibujar el círculo para sinotubular junction
    hold on;
    viscircles(lastCenter, lastDiameter / 2, 'EdgeColor', 'r');
    
    % Dibujar el círculo para walls
    viscircles(walls_centroid, walls_diameter / 2, 'EdgeColor', 'b'); % Círculo azul para walls
    
    hold off;
    fprintf('Diametro pared aortica arco aortico: %.2f mm\n', walls_diameter * 1.5); 
else
    fprintf('No se detectó un círculo adecuado en walls.\n');
end
