clc;
close all;
clear all;
s = load('s.mat');
s_new = cell2mat(struct2cell(s));
addpath("/MATLAB Drive/ASP_LAB/helper_plots/")
import plotting.*
fs = 1e3;
T = 1/fs;
a = size(s_new);
L = a(2);
t = (0:L-1).* T;
figure(1);
stem(1000*t, s_new);
title("Amplitude s(t)")
xlabel("Time(milliseconds)")
ylabel("Amplitude of the noisy signal")
grid;
[y_prime, d] = lowpass(s_new, 130, fs);
figure(2);
stem(1000*t, y_prime);
title("Amplitude of the filtered signal")
xlabel("Time(milliseconds)")
ylabel("Amplitude")
grid;
s_fft = fft(s_new, L);
y_new_fft = fft(y_prime, L);
z1 = fftshift(s_fft);
z2 = fftshift(y_new_fft);
t1 = unwrap(angle(z1));
t2 = unwrap(angle(z2));
figure(3);
plotting(L, fs, s_fft, t1);
figure(4);
plotting(L, fs, y_new_fft, t2);