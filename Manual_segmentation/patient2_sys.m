%%
clc
clear
close all
%%
addpath(genpath("imagine-master"));
%% read and view data
load("project_data_v2.mat")
%% preprocessing
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
%%
imagine(patient2_sys_blackblood,patient2_sys_brightblood)
%%
[counts,x] = imhist(patient2_sys_brightblood);
T = otsuthresh(counts);
BW = imbinarize(patient2_sys_brightblood,T);
%imagine(BW)
%%
clean = bwareaopen(BW,100,4);
element = strel('sphere',2);
seg = imerode(clean,element);
%%
clean_seg = bwareaopen(seg,100,4);

comp = bwconncomp(clean_seg,26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 70000;

% Crear una copia de la imagen binaria para modificar
new_image = clean_seg;

% Recorrer todos los componentes conectados
for i = 1:comp.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        new_image(comp.PixelIdxList{i}) = 0;
    end
end
%% tamaño real
mask = imdilate(new_image,element);
cora_ao = patient2_sys_brightblood .* mask;
%%
% Permutar el volumen para verlo en el plano transversal
transversal_volume = permute(mask, [2, 3, 1]);
[tamano_x, tamano_y, tamano_z] = size(transversal_volume);
vol= transversal_volume;
for i = 1:tamano_z
    corte = transversal_volume(:,:,i);
    stats = regionprops(corte, 'Area', 'PixelIdxList');
    % Establecer un umbral para el área mínima
    area = 2000;
    % Crear una copia de la imagen binaria para modificar
    new_image = corte;
    % Recorrer todos los componentes conectados
    for j = 1: length(stats)
        % Si el área del componente es mayor que el umbral, eliminarlo
        if stats(j).Area > area
            new_image(stats(j).PixelIdxList) = 0;
        end
    end
    vol(:,:,i) = new_image;
end
volshow(vol)
%%
vol = imerode(vol,element);
%%
comp_vol = bwconncomp(vol,26);
stats = regionprops(comp_vol, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 10000;

% Crear una copia de la imagen binaria para modificar
cora = vol;

% Recorrer todos los componentes conectados
for i = 1:comp_vol.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        cora(comp_vol.PixelIdxList{i}) = 0;
    end
end
volshow(cora)
%%
cora = imdilate(cora,element);
vol = imdilate(vol,element);
volshow(vol)
%%
comp_vol = bwconncomp(cora,26);
stats = regionprops(comp_vol, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 40000;

% Crear una copia de la imagen binaria para modificar
arco = cora;

% Recorrer todos los componentes conectados
for i = 1:comp_vol.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        arco(comp_vol.PixelIdxList{i}) = 0;
    end
end
cora_final = cora - arco;
volshow(cora_final)
%%
sin_cora= vol - cora_final;
volshow(sin_cora)
%%
comp_noise = bwconncomp(sin_cora,26);
stats = regionprops(comp_noise, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 5000;
% Crear una copia de la imagen binaria para modificar
noise = sin_cora;

% Recorrer todos los componentes conectados
for i = 1:comp_noise.NumObjects
    % Si el área del componente es mayor que el umbral, eliminarlo
    if stats(i).Area > area
        noise(comp_noise.PixelIdxList{i}) = 0;
    end
end
volshow(noise)
%%
vol_new = sin_cora - noise - arco;
volshow(vol_new)
%%
element = strel('sphere',6);
arco_separate = imerode(arco,element);
%%
comp_arc = bwconncomp(arco_separate,26);
stats = regionprops(comp_arc, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 1000;

% Crear una copia de la imagen binaria para modificar
arc = arco_separate;

% Recorrer todos los componentes conectados
for i = 1:comp_arc.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        arc(comp_arc.PixelIdxList{i}) = 0;
    end
end
%%
arco_ao = imdilate(arc,element);
%%
ao_mask_p2_sys = vol_new + arco_ao;
element = strel('sphere',6);
ao_mask_p2_sys = imdilate(ao_mask_p2_sys,element);
ao_mask_p2_sys = imerode(ao_mask_p2_sys,element);
ao_mask_p2_sys = permute(ao_mask_p2_sys, [2, 3, 1]);
ao_mask_p2_sys = permute(ao_mask_p2_sys, [2, 3, 1]);
%%
volshow(ao_mask_p2_sys)
%% paciente 1 en diastole
element = strel('sphere',2);
ao_p2_sys = cora_ao .*ao_mask_p2_sys;
ao_p2_sys_black = patient2_sys_blackblood .* imdilate(ao_mask_p2_sys,element);
imagine(ao_p2_sys)
%%
save('patient2_sys.mat','ao_p2_sys','ao_p2_sys_black','ao_mask_p2_sys')