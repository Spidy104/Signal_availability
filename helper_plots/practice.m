clc;
clear all;
close all;

n = -2:10;
x = [1:7, 6:-1:1];
e1 = signal_plotting(x, n);
[x11, n11] = e1.sigshift(5);
[x12, n12] = e1.sigshift(-4);
e2 = signal_plotting(3*x11, n11);
[x1, n1] = e2.sigadd(-2*x12, n12);
stem(n1, x1);