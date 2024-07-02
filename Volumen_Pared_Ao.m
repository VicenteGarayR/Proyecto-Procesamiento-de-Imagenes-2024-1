clear;
clc;
close all;
load project_data_v2.mat
load patient1_dia.mat
load patient1_sys.mat
load patient2_dia.mat
load patient2_sys.mat
patient1_dia_brightblood = mat2gray(permute(patient1_dia_blackblood, [1, 3, 2]));
patient1_sys_brightblood = mat2gray(permute(patient1_sys_blackblood, [1, 3, 2]));
patient2_dia_brightblood = mat2gray(permute(patient2_dia_blackblood, [1, 3, 2]));
patient2_sys_brightblood = mat2gray(permute(patient2_sys_blackblood, [1, 3, 2]));

[count, bin]=imhist(patient1_dia_brightblood);
otsu=otsuthresh(count);
patient1_dia_brightblood=imbinarize(patient1_dia_brightblood,otsu);

[count, bin]=imhist(patient1_sys_brightblood);
otsu=otsuthresh(count);
patient1_sys_brightblood=imbinarize(patient1_sys_brightblood,otsu);

[count, bin]=imhist(patient2_dia_brightblood);
otsu=otsuthresh(count);
patient2_dia_brightblood=imbinarize(patient2_dia_brightblood,otsu);

[count, bin]=imhist(patient2_sys_brightblood);
otsu=otsuthresh(count);
patient2_sys_brightblood=imbinarize(patient2_sys_brightblood,otsu);

Vol_Pared_Ao(aop1_dia_black,patient1_dia_brightblood,mask_p1_dia);
Vol_Pared_Ao(aop1_sys_black,patient1_sys_brightblood,mask_p1_sys);
Vol_Pared_Ao(aop2_dia_black,patient2_dia_brightblood,mask_p2_dia);
Vol_Pared_Ao(aop2_sys_black,patient2_sys_brightblood,mask_p2_sys);

function totalVolume=Vol_Pared_Ao(Vol,M,P)

    Se=strel("cube",4);
    
    gradientMagnitude=imdilate(P,Se)-P;
    [count, bin]=imhist(gradientMagnitude);
    otsu=otsuthresh(count);
    K=imbinarize(gradientMagnitude,otsu);

    filteredImage=Vol;
    [counts , bin]=imhist(filteredImage);

    otsu=otsuthresh(counts);

    N=imbinarize(filteredImage,otsu);
    N=N&~P;
    N=imclose(N,Se);

    Vol_Final=N|K;
%     volshow(Vol_Final);

    numVoxels = sum(Vol_Final,'all');
    totalVolume = numVoxels * 0.0033750;
    disp(totalVolume);
 
    % Crear un volumen RGB donde la máscara se superpone en rojo
    overlay = cat(4, M, M, M);  % Inicialmente, todos los canales son iguales
    overlay(:,:,:,2) = overlay(:,:,:,2) + 0.5 * Vol_Final;  % Añadir la máscara al canal rojo
    overlay(:,:,:,1) = overlay(:,:,:,1) + 0.5 * P;  % Añadir la máscara al canal rojo

    % Visualizar el volumen original con la máscara superpuesta
    volshow(overlay);

end

