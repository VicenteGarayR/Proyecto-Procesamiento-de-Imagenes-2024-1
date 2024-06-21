%%
clc
clear
close all
addpath(genpath("imagine-master"));
%%
load('patient1_dia.mat')
load('patient2_dia.mat')
load('patient1_sys.mat')
load('patient2_sys.mat')
%%
imagine(ao_maskp1_dia,ao_maskp1_sys,ao_maskp2_dia,ao_maskp2_sys)
%%
imagine(aop1_dia,aop1_sys,aop2_dia,aop2_sys)
%%
imagine(aop1_dia_black,aop1_sys_black,aop2_dia_black,aop2_sys_black)