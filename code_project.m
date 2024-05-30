%%
clc
clear
close all
%% read and view data
load("project_data.mat")
figure;
subplot(2,2,1)
imshow(patient1_sys(:,:,30),[])
title('patient 1 systole')
subplot(2,2,2)
imshow(patient2_sys(:,:,30),[])
title('patient 2 systole')
subplot(2,2,3)
imshow(patient1_dia(:,:,30),[])
title('patient 1 diastole')
subplot(2,2,4)
imshow(patient2_dia(:,:,30),[])
title('patient 2 diastole')
%%