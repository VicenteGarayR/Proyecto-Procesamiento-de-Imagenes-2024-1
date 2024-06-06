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
imagine(BW)
%%
thres = patient1_dia_brightblood > 0.3;
imagine(thres)
%%
clean = bwareaopen(BW,40,4);
imagine(clean)
%%
obj = regionprops3(clean, 'Extent','Volume');
extents = obj.Extent;
volume = obj.Volume;
idx = (volume > 20000);
filteredObjects = ismember(bwlabeln(clean), find(idx));

D = -bwdist(~filteredObjects);
mask = imextendedmin(D, 2);
D2 = imimposemin(D, mask);
L = watershed(D2);
watershedVolume = filteredObjects;
watershedVolume(L == 0) = 0;
imagine(watershedVolume)