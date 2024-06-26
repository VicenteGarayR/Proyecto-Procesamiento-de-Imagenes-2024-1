%%
clc
clear
close all
addpath(genpath("imagine-master"));
%% read and preprocesssing data
load("project_data_v2.mat")
% Patient 1
patient1_dia_blackblood = mat2gray(permute(patient1_dia_blackblood, [1, 3, 2]));
patient1_dia_blacktblood = mat2gray(permute(patient1_dia_blacktblood, [1, 3, 2]));
patient1_dia_brightblood = mat2gray(permute(patient1_dia_brightblood, [1, 3, 2]));
patient1_sys_blackblood = mat2gray(permute(patient1_sys_blackblood, [1, 3, 2]));
patient1_sys_brightblood = permute(patient1_sys_brightblood, [1, 3, 2]);
% Patient 2
patient2_dia_blackblood = mat2gray(permute(patient2_dia_blackblood, [1, 3, 2]));
patient2_dia_brightblood = mat2gray(permute(patient2_dia_brightblood, [1, 3, 2]));
patient2_sys_blackblood = mat2gray(permute(patient2_sys_blackblood, [1, 3, 2]));
patient2_sys_brightblood = mat2gray(permute(patient2_sys_brightblood, [1, 3, 2]));
%% first threshold
patient= patient1_sys_brightblood;
patient_black= patient1_sys_blackblood;
[counts,x] = imhist(patient);
T = otsuthresh(counts);
BW = imbinarize(patient,T);
thres = patient1_sys_brightblood > 1000;
clean = bwareaopen(thres,40,4);
element_cora = strel('sphere',1);
clean_cora = imerode(clean,element_cora);
clean_cora = bwareaopen(clean_cora,100,4);
% Connecting components and removing small components
comp = bwconncomp(clean_cora, 26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
volume_cora = zeros(size(clean_cora));

max_area = max([stats.Area]);
for i = 1:comp.NumObjects
    if stats(i).Area == max_area
        volume_cora(comp.PixelIdxList{i}) = 1;
    end
end
volume_cora = imdilate(volume_cora,element_cora);
%%
element = strel('sphere',2);
clean_seg = imerode(clean,element);
clean_seg = bwareaopen(clean_seg,100,4);
% Connecting components and removing small components
comp = bwconncomp(clean_seg, 26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
volume = zeros(size(clean_seg));

max_area = max([stats.Area]);
for i = 1:comp.NumObjects
    if stats(i).Area == max_area
        volume(comp.PixelIdxList{i}) = 1;
    end
end
%%
% Permutar el volumen para verlo en el plano transversal
transversal_volume = permute(volume, [2, 3, 1]);
[tamano_x, tamano_y, tamano_z] = size(transversal_volume);
vol = false(size(transversal_volume)); % Inicializar volumen filtrado

area = 2900; % Inicializar el área en 2900
while area > 0
    for i = 1:tamano_z
        corte = transversal_volume(:, :, i);
        stats = regionprops(corte, 'Area', 'PixelIdxList');
        
        % Crear una copia de la imagen binaria para modificar
        new_image = false(size(corte));
        
        % Conservar los componentes con área menor o igual al umbral actual
        for j = 1:length(stats)
            if stats(j).Area <= area
                new_image(stats(j).PixelIdxList) = true;
            end
        end
        
        vol(:, :, i) = new_image;
    end
    
    % Verificar el número de componentes en el volumen final
    comp_vol = bwconncomp(vol, 26);
    if comp_vol.NumObjects > 1
        break;
    end
    
    % Decrementar el área mínima
    area = area - 100;
end
%%
% Connecting components
comp = bwconncomp(vol, 26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
copa = zeros(size(vol));

max_area = max([stats.Area]);
for i = 1:comp.NumObjects
    if stats(i).Area == max_area
        copa(comp.PixelIdxList{i}) = 1;
    end
end
%%
piece = false(size(copa)); % Inicializar volumen filtrado

area = 900; % Inicializar el área en 2900
while area > 0
    for i = 1:tamano_z
        corte = copa(:, :, i);
        stats = regionprops(corte, 'Area', 'PixelIdxList');
        
        % Crear una copia de la imagen binaria para modificar
        new_image = false(size(corte));
        
        % Conservar los componentes con área menor o igual al umbral actual
        for j = 1:length(stats)
            if stats(j).Area >= area
                new_image(stats(j).PixelIdxList) = true;
            end
        end
        
        piece(:, :, i) = new_image;
    end
    
    % Verificar el número de componentes en el volumen final
    comp_vol = bwconncomp(piece, 26);
    if comp_vol.NumObjects > 1
        break;
    end
    
    % Decrementar el área mínima
    area = area - 100;
end
top = copa - piece;
%%
comp = bwconncomp(piece, 26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
piece1 =  piece;
max_area = max([stats.Area]);
for i = 1:comp.NumObjects
    if stats(i).Area == max_area
        piece1(comp.PixelIdxList{i}) = 0;
    end
end
comp = bwconncomp(piece1, 26);
% Si el número de componentes es mayor que 1, suprimir el área más pequeña
if comp.NumObjects > 1
    stats = regionprops(comp, 'Area', 'PixelIdxList');
    max_area = max([stats.Area]);
    for i = 1:comp.NumObjects
        if stats(i).Area == max_area
            piece1(comp.PixelIdxList{i}) = 0;
            break; % Romper el ciclo después de suprimir el área más pequeña
        end
    end
end
%%
comp = bwconncomp(vol, 26);
stats = regionprops(comp, 'Centroid', 'PixelIdxList');
torax = vol;
max_centroid = max([stats.Centroid]);
for i = 1:comp.NumObjects
    if stats(i).Centroid < max_centroid
        torax(comp.PixelIdxList{i}) = 0;
    end
end
torax = torax + piece1;
%%
% Connecting components
comp = bwconncomp(imerode(top,element), 26);
stats = regionprops(comp, 'Centroid', 'PixelIdxList');
arco = zeros(size(top));
max_centroid = max([stats.Centroid]);
for i = 1:comp.NumObjects
    if stats(i).Centroid < max_centroid
        arco(comp.PixelIdxList{i}) = 1;
    end
end
comp = bwconncomp(arco, 26);
arco1 = zeros(size(arco));
% Si el número de componentes es mayor que 1, conservar el área más grande
if comp.NumObjects > 1
    stats = regionprops(comp, 'Area', 'PixelIdxList');
    max_area = max([stats.Area]);
    for i = 1:comp.NumObjects
        if stats(i).Area == max_area
            arco1(comp.PixelIdxList{i}) = 1;
            break; % Romper el ciclo después de conservar el área más grande
        end
    end
end
arco1= imdilate(arco1,element);
%%
ao_maskp1_sys = arco1 + torax;
element = strel('sphere',6);
ao_maskp1_sys = imdilate(ao_maskp1_sys,element);
ao_maskp1_sys = permute(ao_maskp1_sys, [2, 3, 1]);
ao_maskp1_sys = permute(ao_maskp1_sys, [2, 3, 1]);
ao_maskp1_sys = imerode(ao_maskp1_sys,element);
element = strel('sphere',3);
ao_maskp1_sys = imdilate(ao_maskp1_sys,element);
mask_p1_sys = volume_cora .* ao_maskp1_sys;
aop1_sys = patient .*mask_p1_sys;
aop1_sys_black = patient_black .* imdilate(mask_p1_sys,element);
%% Parametro de volumen 
Volumenp1_sys = sum(ao_maskp1_sys,'all');
%%
save('patient1_sys.mat','aop1_sys','aop1_sys_black','mask_p1_sys','Volumenp1_sys')