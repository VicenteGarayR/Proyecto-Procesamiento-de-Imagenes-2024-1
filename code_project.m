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
patient= patient2_sys_brightblood;
[counts,x] = imhist(patient);
T = otsuthresh(counts);
BW = imbinarize(patient,T);
clean = bwareaopen(BW,40,4);
element = strel('sphere',3);
clean_seg = imerode(clean,element);
clean_seg = bwareaopen(clean_seg,100,4);
%%
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
%volume = imdilate(volume, element);
%%

% Permutar el volumen para verlo en el plano transversal
transversal_volume = permute(volume, [2, 3, 1]);
[tamano_x, tamano_y, tamano_z] = size(transversal_volume);
vol = false(size(transversal_volume)); % Inicializar volumen filtrado

area = 2900; % Inicializar el área en 2000
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
volshow(vol)
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
% Connecting components and removing small components
comp = bwconncomp(vol, 26);
stats = regionprops(comp, 'Area', 'PixelIdxList');
noise = zeros(size(vol));
torax = zeros(size(vol));
if comp.NumObjects > 5
    min_area = min([stats.Area]);
    for i = 1:comp.NumObjects
        if stats(i).Area == min_area
            noise(comp.PixelIdxList{i}) = 1;
        end
    end
    vol = vol - noise;
    % Connecting components and 
    comp = bwconncomp(vol, 26);
    min_area = min([stats.Area]);
    for i = 1:comp.NumObjects
        if stats(i).Area == min_area
            torax(comp.PixelIdxList{i}) = 1;
        end
    end
else
    min_area = min([stats.Area]);
    for i = 1:comp.NumObjects
        if stats(i).Area == min_area
            torax(comp.PixelIdxList{i}) = 1;
        end
    end
end
volshow(torax)
%%