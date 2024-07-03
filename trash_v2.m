%%
clc
clear
close all
%%
load('patient1_dia.mat')
load('patient2_dia.mat')
load('patient1_sys.mat')
load('patient2_sys.mat')

[flowVx_1, flowVy_1, flowVz_1] = MotionField(aop1_dia,aop1_sys,'Patient 1',0);
[flowVx_2, flowVy_2, flowVz_2] = MotionField(aop2_dia,aop2_sys,'Patient 2',0);

Magnitudeflow1  = sqrt(flowVx_1.^2+ flowVy_1.^2+ flowVz_1.^2);
movMax__1       = max(Magnitudeflow1, [], 'all')*1.5;
movProm_1       = mean(Magnitudeflow1,'all')*1.5;

Magnitudeflow2  = sqrt(flowVx_2.^2+ flowVy_2.^2+ flowVz_2.^2);
movMax__2       = max(Magnitudeflow2, [], 'all')*1.5;
movProm_2       = mean(Magnitudeflow2,'all')*1.5;

%% Funciones
function  [flowVx, flowVy, flowVz] = MotionField(V1,V2,noPatient,grafica)
    % Leer y Prepocesar los datos 
    vol1 = double(V1);
    vol2 = double(V2);

    % Inicializar matrices para el flujo óptico
    flowVx = zeros(size(vol1));
    flowVy = zeros(size(vol1));
    flowVz = zeros(size(vol1));

    %% Calcular el flujo óptico plano a plano
    % Estimar el flujo óptico para X e Y
    opticFlow = opticalFlowLKDoG;  % Usa el método de Lukas Kanade
    for z = 1:size(vol1, 3)
        opflow = opticalFlow(vol1(:,:,z), vol2(:,:,z));
        flowVx(:,:,z) = opflow.Vx;
        flowVy(:,:,z) = opflow.Vy;
    end

    % Estimar el flujo óptico para Z
    opticFlow = opticalFlowLKDoG;  % Usa el método de Lukas Kanade
    vol1 = permute(vol1,[1 3 2]);
    vol2 = permute(vol2,[1 3 2]);
    flowVz = permute(flowVz,[1 3 2]);
    for z = 1:size(vol1, 3)
        opflow = opticalFlow(vol1(:,:,z), vol2(:,:,z));
        flowVz(:,:,z) = opflow.Vx;
    end
    flowVz = permute(flowVz,[1 3 2]);
    vol1 = permute(vol1,[1 3 2]);

    if grafica == 1
    % Visualización del flujo óptico en 3D (opcional)
        figure;
        [X, Y, Z] = meshgrid(1:size(vol1,1), 1:size(vol1,2), 1:size(vol1,3));
        quiver3(Y, Z, X, flowVy, flowVz, flowVz);
        title(strcat('Flujo aorta 3D - ', noPatient));
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
    end
end