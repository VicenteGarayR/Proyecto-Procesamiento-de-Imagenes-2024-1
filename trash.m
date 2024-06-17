%% water sheeds
[tamano_x, tamano_y, tamano_z] = size(cora_ao);
for i = 1:tamano_z
    corte = mask(:,:,i);
    % Transformada de distancia
    distanceTransform = bwdist(~corte);
    distanceTransform = 1 - distanceTransform;

    % Encontrar los mínimos extendidos (marcadores)
    markers = imextendedmin(distanceTransform, 0.6);

    % Modificar la transformación de distancia para forzar los mínimos
    modifiedDistance = imimposemin(distanceTransform, markers);

    % Aplicar la segmentación por watershed
    L = watershed(modifiedDistance, 4);

    % Visualizar los resultados
    subplot(1, 3, 1);
    imshow(corte, []);
    title('Imagen en escala de grises');

    subplot(1, 3, 2);
    imshow(distanceTransform, []);
    title('Transformada de distancia');

    subplot(1, 3, 3);
    imshow(label2rgb(L, 'jet', 'k', 'shuffle'));
    title('Segmentación por Watershed');

    pause(0.5); % Pausa de 0.5 segundos entre cortes para visualizar la animación
end
%% k-means

[dimX, dimY, dimZ] = size(cora_ao);
[X, Y, Z] = ndgrid(1:dimX, 1:dimY, 1:dimZ);
features = [cora_ao(:), X(:) / dimX, Y(:) / dimY, Z(:) / dimZ];
numClusters = 4;
[idx, C] = kmeans(features, numClusters);
seg = reshape(idx, [dimX, dimY, dimZ]);
volshow(seg);
%%
% Visualizar el resultado
volumen= cora_ao - seg;
volshow(volumen);
%%
% Visualize the clustered volume to identify the aorta cluster
figure;
for i = 1:numClusters
    subplot(1, numClusters, i);
    imagesc(seg(:,:,round(end/2)) == i);
    title(['Cluster ' num2str(i)]);
end
%%
% Assuming you identified that the aorta belongs to cluster 'aortaCluster'
aortaCluster = 3; % Replace this with the actual cluster number for the aorta

% Create a binary mask for the aorta
aortaMask = (seg == aortaCluster);
% Apply the mask to the original volume
volshow(aortaMask)
%%
isolatedAorta = cora_ao .* aortaMask;
volshow(isolatedAorta)