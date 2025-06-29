clc;
clear all;
close all;
addpath("../helper_plots/")
import plotting.*;
fs = 1000;
T = 1/fs;
L = input("Enter the length of the signal: ");
t = (0:L).*T;
a1 = 2.45;
a2 = -sqrt(2);
s = 0.54 + a1*cos(2*pi*50*t) + a2*sin(2*pi*120*t);
s = [s, zeros(1, 1024-L)];
figure(1);
stem(1000*(0:1024).*T, s);
xlabel("Time(milliseconds)")
ylabel("Amplitude")
grid;
y = fft(s, L);
z = fftshift(y);
plotting(L, fs, y, unwrap(angle(z)));