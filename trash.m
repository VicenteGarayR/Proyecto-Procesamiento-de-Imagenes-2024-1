%%
clc
clear
close all
addpath(genpath("imagine-master"));
%%
load('patient1_dia.mat')
load('patient2_dia.mat')
load('patient1_sys.mat')
load('patient2_sys.mat')
%%
% Paso 1: Leer los volúmenes binarios
vol1 =aop2_dia;  % Cambia esto por la forma correcta de leer tu volumen
vol2 =aop2_sys;  % Cambia esto por la forma correcta de leer tu volumen

% Paso 2: Preprocesar los datos
vol1 = double(vol1);
vol2 = double(vol2);

% Inicializar matrices para el flujo óptico
flowVx = zeros(size(vol1));
flowVy = zeros(size(vol1));
flowMagnitude = zeros(size(vol1));

% Paso 3: Calcular el flujo óptico plano a plano
opticFlow = opticalFlowHS;  % Usa el método de Horn-Schunck

for z = 1:size(vol1, 3)
    % Estimar el flujo óptico para cada plano 2D
    flow = estimateFlow(opticFlow, vol1(:,:,z));
    flow = estimateFlow(opticFlow, vol2(:,:,z));
    
    % Guardar los resultados en las matrices 3D
    flowVx(:,:,z) = flow.Vx;
    flowVy(:,:,z) = flow.Vy;
    flowMagnitude(:,:,z) = sqrt(flow.Vx.^2 + flow.Vy.^2);  % Magnitud del flujo
end

% Paso 4: Visualizar el resultado para un plano central
midZ = round(size(vol1, 3) / 2);
figure;
subplot(1,3,1);
imshow(vol1(:,:,midZ), []);
title('Volumen 1 - Plano Central');
subplot(1,3,2);
imshow(vol2(:,:,midZ), []);
title('Volumen 2 - Plano Central');
subplot(1,3,3);
imshow(flowMagnitude(:,:,midZ), []);
title('Magnitud del Flujo Óptico - Plano Central');
hold on;
quiver(flowVx(:,:,midZ), flowVy(:,:,midZ), 'r');
hold off;
%%
% Visualización del flujo óptico en 3D (opcional)
figure;
[X, Y, Z] = meshgrid(1:size(vol1,2), 1:size(vol1,1), 1:size(vol1,3));
quiver3(X, Y, Z, flowVx, flowVy, zeros(size(flowVx)));
title('Flujo Óptico 3D');
xlabel('X');
ylabel('Y');
zlabel('Z');