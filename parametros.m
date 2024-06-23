%%
clc
clear
close all
%%
load("patient1_dia.mat")
load("patient2_dia.mat")
load("patient1_sys.mat")
load("patient2_sys.mat")
%%
%imagen a utilizar
img = ao_mask_p2;

%% Volumen
volumen_p1_dia= Volumenp1_dia * 0.0033750; %ml
volumen_p2_dia= Volumenp2_dia * 0.0033750; %ml
volumen_p1_sys= Volumenp1_sys * 0.0033750; %ml
volumen_p2_sys= Volumenp2_sys * 0.0033750; %ml
%% Diametro union sinotubular

[rows, cols, depth] = size(img);
circularityThreshold = 0.8;

zPos = 0;

for z = rows:-1:1
    % Extraer el plano XZ
    XZ = squeeze(img(z,:,:));

    BW = imbinarize(XZ);
     
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
        if circularity >= circularityThreshold
            circularRegions = circularRegions + 1;
        end
    end
    
    % Si hay dos areas circulares hacemos break
    if circularRegions >= 2
        zPos = z;
        break;
    end
end


%Encontrar el diametro maximo de los 4 pixeles más abajo de z

maxDiameter = 0;
maxZ = zPos;
for z = max(1, zPos-4):zPos
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
                maxZ = z;
                maxCenters = stats(k).Centroid;
                maxAreas = area;
            end
        end
    end
end

if maxDiameter > 0
    figure(1);
    imshow(squeeze(img(maxZ,:,:)), []);
    xlabel('X');
    ylabel('Z');
    title('Diametro union sinotubular');

    % Dibujar el círculo
    hold on;
    viscircles(maxCenters, maxDiameter / 2, 'EdgeColor', 'r');
    
    
    % Añadir anotaciones a la imagen con área y diámetro
    textString = sprintf('Area: %.2f mm²\nDiam: %.2f mm', maxAreas * (1.5^2), maxDiameter * 1.5);
    text(maxCenters(1), maxCenters(2), textString, 'Color', ...
        'red', 'FontSize', 8, 'HorizontalAlignment', 'center');
    
    hold off;
    fprintf('Diametro unión sinotubular: %.2f mm\n', maxDiameter * 1.5); 
else
    fprintf('No se detectaron suficientes formas circulares.\n');
end


%% Diametro aorta ascendente y descendente

figure(2)

XZ = squeeze(img(zPos - 10,:,:));
BW = imbinarize(XZ);
stats = regionprops("table", BW, "Centroid", "MajorAxisLength", "MinorAxisLength", "Area");

numAreas = numel(stats);

% Obtener los centros y diámetros de las regiones
centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength], 2);
radii = diameters / 2;
areas = stats.Area;

imshow(XZ, []);
hold on;

viscircles(centers, radii);

% Añadir anotaciones de área y diámetro
for k = 1:length(centers)
    center = centers(k, :);
    
    % Formatear el texto con área y diámetro
    textString = sprintf('Area: %.2f mm²\nDiam: %.2f mm', areas(k)*(1.5^2), diameters(k)*1.5);
    
    text(center(1), center(2), textString, 'Color', ...
        'red', 'FontSize', 8, 'HorizontalAlignment', 'center');
end

[maxDiametro, mId] = max(diameters);
[minDiametro, minId] = min(diameters);


fprintf('Diametro aorta ascendente: %.2f mm\n', maxDiametro * 1.5); 
fprintf('Diametro aorta descendente: %.2f mm\n', minDiametro * 1.5); 

xlabel('X');
ylabel('Z');
title('Diametro aorta ascendente y descendente');

%% Diametro arco aortico

circularityThreshold = 1;

circularDiameters = [];
centers = [];
areas = [];

% Contador de imágenes consecutivas con círculos
consecutiveCircularImages = 0;

% Variables para almacenar los datos del último círculo detectado
lastImage = [];
lastCenter = [];
lastArea = [];
lastDiameter = [];

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
        if circularity >= circularityThreshold && area > 10 

            diameter = mean([stats(k).MajorAxisLength, stats(k).MinorAxisLength]);

            lastImage = YZ;
            lastCenter = stats(k).Centroid;
            lastArea = area;
            lastDiameter = diameter;

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
    figure;
    imshow(lastImage, []);
    hold on;
    plot(lastCenter(1), lastCenter(2), 'ro', 'MarkerSize', 10); % Marcar el centro con un círculo rojo
    textString = sprintf('Area: %.2f mm^2\nDiametro: %.2f mm', ...
        lastArea * (1.5^2), lastDiameter * 1.5);
    text(lastCenter(1) + 10, lastCenter(2), textString, 'Color', 'red', 'FontSize', 10); % Mostrar el texto
    title('Diametro arco aortico');
    xlabel('Z');
    ylabel('Y');
    hold off;

    fprintf('Diametro arco aórtico: %.2f mm\n', lastDiameter * 1.5); 
else
    disp('No se encontraron suficientes imágenes consecutivas con áreas circulares.');
end