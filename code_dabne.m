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
imagine(patient1_dia_blackblood,patient1_dia_brightblood)
%%
corte = patient1_dia_brightblood(:,:,118);
thres = corte > 0.3;
figure;
subplot(1,3,1)
imshow(corte)
subplot(1,3,2)
imhist(corte)
subplot(1,3,3)
imshow(thres)

[counts,x] = imhist(corte);
T = otsuthresh(counts);
BW = imbinarize(corte,T);
figure;
imshow(BW)
%%
[counts,x] = imhist(patient1_dia_brightblood);
T = otsuthresh(counts);
BW = imbinarize(patient1_dia_brightblood,T);
%imagine(BW)
thres = patient1_dia_brightblood > 0.3;
%imagine(thres)
%%
clean = bwareaopen(BW,40,4);
element = strel('sphere',2);
seg = imerode(clean,element);
%%
clean_seg = bwareaopen(seg,100,4);

comp = bwconncomp(clean_seg,26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 20000;

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
cora_ao = patient1_dia_brightblood .* mask;
%%
% Permutar el volumen para verlo en el plano transversal
transversal_volume = permute(mask, [2, 3, 1]);
%%
[tamano_x, tamano_y, tamano_z] = size(transversal_volume);
vol= transversal_volume;
for i = 1:tamano_z
    corte = transversal_volume(:,:,i);
    stats = regionprops(corte, 'Area', 'PixelIdxList');
    % Establecer un umbral para el área mínima
    area = 1000;
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
comp_vol = bwconncomp(vol,26);
stats = regionprops(comp_vol, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 30000;

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
sin_cora= vol - cora;
comp_arco = bwconncomp(sin_cora,26);
stats = regionprops(comp_arco, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 25000;

% Crear una copia de la imagen binaria para modificar
arco = sin_cora;

% Recorrer todos los componentes conectados
for i = 1:comp_arco.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        arco(comp_arco.PixelIdxList{i}) = 0;
    end
end
volshow(arco)
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
vol_new = sin_cora - noise;
comp_ao = bwconncomp(vol_new,26);
stats = regionprops(comp_ao, 'Centroid', 'PixelIdxList');
% Establecer un umbral para el área mínima
centr = 50;
% Crear una copia de la imagen binaria para modificar
ao_t = vol_new;

% Recorrer todos los componentes conectados
for i = 1:comp_ao.NumObjects
    % Si el área del componente es mayor que el umbral, eliminarlo
    if stats(i).Centroid > centr
        ao_t(comp_ao.PixelIdxList{i}) = 0;
    end
end
volshow(ao_t)
%%
element = strel('sphere',3);
arco_separate = imerode(arco,element);
%%
comp_arc = bwconncomp(arco_separate,26);
stats = regionprops(comp_arc, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 2800;

% Crear una copia de la imagen binaria para modificar
arc = arco_separate;

% Recorrer todos los componentes conectados
for i = 1:comp_arc.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        arc(comp_arc.PixelIdxList{i}) = 0;
    end
end
volshow(arc)
%%
arco_ao = imdilate(arc,element);
%%
ao_mask = vol_new - ao_t + arco_ao;
element = strel('sphere',6);
ao_mask = imdilate(ao_mask,element);
ao_mask = imerode(ao_mask,element);
%%
ao_p1 = cora_ao .*ao_mask;
volshow(ao_p1)