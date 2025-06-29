clc;
clear all;
close all;
addpath("/MATLAB Drive/ASP_LAB/helper_plots/")
import plotting.*
fs = 1000;
T = 1/fs;
L = input("Enter the length of the signal");
t = (0:L-1).* T;
a1 = 2.45;
a2 = -sqrt(2);
signal = 0.54 + a1*cos(2*pi*50*t) + a2*sin(2*pi*120*t);
s = signal + 2*randn(size(t));
figure(1);
stem(1000*t, s);
title("Amplitude s(t)")
xlabel("Time(milliseconds)")
ylabel("Amplitude")
grid;
y = fft(s, L);
z = fftshift(y);
theta = unwrap(angle(z));
figure(2);
plotting(L, fs, y, theta);
save('s.mat', 's');