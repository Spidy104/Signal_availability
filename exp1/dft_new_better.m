clc;
clear all;
close all;
addpath("/MATLAB Drive/ASP_LAB/helper_plots/");
fs = 1000;
T = 1/fs;
nums = 2:9;
fun = @(t)(power(2, t));
a1 = 2.45;
a2 = -sqrt(2);
figure(1);
xlabel("Time(milliseconds)")
ylabel("Amplitude")
grid;
for i = fun(nums)
    figure(log2(i)-1);
    subplot(2, 1, 1);
    t = (0:i-1).*T;
    s = a1*cos(2*pi*50*t) + power(1.897, a2)*sin(2*pi*120*t);
    xlabel("Time values");
    ylabel('Amplitude');
    y = fft(s, i);
    z = fftshift(y);
    subplot(2, 1, 2)
    plotting(i, fs, y, unwrap(angle(z)));
end