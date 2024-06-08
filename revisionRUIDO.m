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
% SEGMENTACION CON THRESHOLD patient1_sys_blackblood
IMAGE = patient1_sys_blackblood;    % imagen a analizar
IMAGE = mat2gray(IMAGE);            % transformacion a escala [0 1]
thmax = max(IMAGE,[],'all');
thmin = min(IMAGE,[],'all');
th = (thmax - thmin)/2;             % thresholding en valor medio

bl_msk_frontal  = MASK(IMAGE, [1 2 3], 0.1*th, 'black');
bl_msk_lateral  = MASK(IMAGE, [1 3 2], 0.1*th, 'black');
bl_msk_superior = MASK(IMAGE, [3 2 1], 0.1*th, 'black');
bl_amask3d      = bl_msk_frontal.*bl_msk_lateral.*bl_msk_superior;

% SEGMENTACION CON THRESHOLD patient1_sys_brightblood
IMAGE = patient1_sys_brightblood;    % imagen a analizar
IMAGE = mat2gray(IMAGE);            % transformacion a escala [0 1]
thmax = max(IMAGE,[],'all');
thmin = min(IMAGE,[],'all');
th = (thmax - thmin)/2;             % thresholding en valor medio

br_msk_frontal  = MASK(IMAGE, [1 2 3], 0.98*th, 'bright');
br_msk_lateral  = MASK(IMAGE, [1 3 2], 0.98*th, 'bright');
br_msk_superior = MASK(IMAGE, [3 2 1], 0.98*th, 'bright');
br_amask3d      = br_msk_frontal.*br_msk_lateral.*br_msk_superior;


%% FUNCIONES
function msk = MASK(I, perm , th, type)
    I       = permute(I,perm);          % imagen permutada
    [m,n,p] = size(I);                  % tamano de la imagen 
    msk     = zeros(size(I));           % mascara general
    for i = 1:p
        seg = zeros(m,n);               % mascara para umbral
        if type ==  "black"
            seg(I(:,:,i) < th) = 1;     % aplicacion de umbral
        else
            seg(I(:,:,i) > th) = 1;     % aplicacion de umbral
        end
        seg = medfilt2(seg,[2 2]);            % filtro
        msk(:,:,i) = seg;               % volumen de la mascara
    end
    msk = permute(msk, perm);
end