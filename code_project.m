%%
clc
clear
close all
%% read and view data
load("project_data_v2.mat")
figure;
sgtitle('bright blood')
subplot(2,2,1)
imshow(patient1_sys_brightblood(:,:,30),[])
title('patient 1 systole')
subplot(2,2,2)
imshow(patient2_sys_brightblood(:,:,30),[])
title('patient 2 systole')
subplot(2,2,3)
imshow(patient1_dia_brightblood(:,:,30),[])
title('patient 1 diastole')
subplot(2,2,4)
imshow(patient2_dia_brightblood(:,:,30),[])
title('patient 2 diastole')

figure;
sgtitle('black blood')
subplot(2,2,1)
imshow(patient1_sys_blackblood(:,:,30),[])
title('patient 1 systole')
subplot(2,2,2)
imshow(patient2_sys_blackblood(:,:,30),[])
title('patient 2 systole')
subplot(2,2,3)
imshow(patient1_dia_blackblood(:,:,30),[])
title('patient 1 diastole')
subplot(2,2,4)
imshow(patient2_dia_blackblood(:,:,30),[])
title('patient 2 diastole')
%%