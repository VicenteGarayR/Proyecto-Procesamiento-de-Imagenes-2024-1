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
[counts,x] = imhist(patient1_sys_brightblood);

T = otsuthresh(counts);
BW = imbinarize(patient1_sys_brightblood,T);
thres = patient1_sys_brightblood > 1000;
%imagine(BW,thres)
%%
clean = bwareaopen(thres,40,4);
element = strel('sphere',3);
seg = imerode(clean,element);
clean_seg = bwareaopen(seg,100,4);
clean_seg = imdilate(clean_seg,element);
%%
comp = bwconncomp(clean_seg,26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 50000;

% Crear una copia de la imagen binaria para modificar
new_image = clean_seg;

% Recorrer todos los componentes conectados
for i = 1:comp.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        new_image(comp.PixelIdxList{i}) = 0;
    end
end
cora_ao = patient1_sys_brightblood .* new_image;
%%
% Permutar el volumen para verlo en el plano transversal
transversal_volume = permute(new_image, [2, 3, 1]);
[tamano_x, tamano_y, tamano_z] = size(transversal_volume);
vol= transversal_volume;
for i = 1:tamano_z
    corte = transversal_volume(:,:,i);
    stats = regionprops(corte, 'Area', 'PixelIdxList');
    % Establecer un umbral para el área mínima
    area = 1600;
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
%%
comp_arco = bwconncomp(cora,26);
stats = regionprops(comp_arco, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 40000;

% Crear una copia de la imagen binaria para modificar
arco = cora;

% Recorrer todos los componentes conectados
for i = 1:comp_arco.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        arco(comp_arco.PixelIdxList{i}) = 0;
    end
end
%%
sin_cora= vol - cora;
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
%%
vol_new = sin_cora - noise;
element = strel('sphere',4);
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
%%
comp_arc = bwconncomp(arco_separate,26);
stats = regionprops(comp_arc, 'Area', 'PixelIdxList');
% Establecer un umbral para el área mínima
area = 3000;

% Crear una copia de la imagen binaria para modificar
arc2 = arco_separate;

% Recorrer todos los componentes conectados
for i = 1:comp_arc.NumObjects
    % Si el área del componente es menor que el umbral, eliminarlo
    if stats(i).Area < area
        arc2(comp_arc.PixelIdxList{i}) = 0;
    end
end
%%
arco_n = arc - arc2;
%%
arco_ao = imdilate(arco_n,element);
ao_mask = vol_new + arco_ao;
volshow(ao_mask)
%%
element = strel('sphere',10);
ao_mask_sys = imdilate(ao_mask,element);
ao_mask_sys = imerode(ao_mask_sys,element);
ao_mask_sys = permute(ao_mask_sys, [2, 3, 1]);
ao_mask_sys = permute(ao_mask_sys, [2, 3, 1]);
volshow(ao_mask_sys)
%% paciente 1 en diastole
element = strel('sphere',3);
ao_p1_sys = cora_ao .*ao_mask_sys;
ao_p1_sys_black = patient1_dia_blackblood .* imdilate(ao_mask_sys,element);
volshow(ao_p1_sys_black)
%%
save('patient1_sys.mat','ao_p1_sys','ao_p1_sys_black','ao_mask_sys')