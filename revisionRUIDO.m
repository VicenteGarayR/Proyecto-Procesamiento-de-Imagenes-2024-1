% SCRIPT DEL PROYECTO
% REVISIÓN DEL RUIDO PRESENTE EN LA IMAGEN
% normalizacion de la imagen: al final de todo!!
% (X - min(X(:)))/(max(X(:))-min(X(:)))

clear 
close all
clc
addpath(genpath("imagine-master"));
load('project_data_v2.mat')         % carga de los datos

%% FORMACION DE MATRICES PARA SEGMENTACION
% SEGMENTACION CON THRESHOLD
IMAGE = patient1_sys_blackblood;    % imagen a analizar
IMAGE = mat2gray(IMAGE);            % transformacion a escala [0 1]
[m,n,p] = size(IMAGE);              % tamano de la imagen 
thmax = max(IMAGE,[],'all');
thmin = min(IMAGE,[],'all');
th = (thmax - thmin)/2;             % thresholding en valor medio
mask_front = zeros(m,n,p);          % mascara para el Thr coronal.
mask_lateral = zeros(m,n,p);        % mascara para el Thr sagital
mask_superior = zeros(m,n,p);       % mascara para el Thr superior
mask3d = zeros(m,n,p);              % mascara general


% Segmentacion frontal
% figure()
for i = 1:p
    seg_front  = zeros(m,n); 
    seg_front(IMAGE(:,:,i) < 0.05*th) = 1;
    seg_front = medfilt2(seg_front,[5 5]);
    mask_front(:,:,i) = seg_front;     
end

% Segmentacion lateral
% figure()
IMAGE = permute(IMAGE, [1, 3, 2]);
mask_lateral = permute(mask_lateral, [1, 3, 2]);
for i = 1:n
    seg_lateral  = zeros(m,p); 
    seg_lateral(IMAGE(:,:,i) < 0.05*th) = 1;
    seg_lateral = medfilt2(seg_lateral,[10 10]);
    mask_lateral(:,:,i) = seg_lateral;
end
IMAGE = permute(IMAGE, [1, 3, 2]);
mask_lateral = permute(mask_lateral, [1, 3, 2]);

% Segmentacion superior
IMAGE = permute(IMAGE, [3, 2, 1]);
mask_superior = permute(mask_superior, [3, 2, 1]);
for i = 1:m
    seg_superior  = zeros(p,n); 
    seg_superior(IMAGE(:,:,i) < th) = 1;
    seg_superior = medfilt2(seg_superior,[5 5]);
    mask_superior(:,:,i) = seg_superior;
end
mask_superior = permute(mask_superior, [3, 2, 1]);
IMAGE = permute(IMAGE, [3, 2, 1]);


%
for i = 1:p
    mask3d(:,:,i) = mask_lateral(:,:,i).*mask_front(:,:,i).*mask_superior(:,:,i);
%     mask3d(:,:,i) = mask3d(:,:,i).*IMAGE(:,:,i).*10;
end
% imagine(mask3d,IMAGE)






% function [msk] = segmentador(I, cara , th)
% 
% end