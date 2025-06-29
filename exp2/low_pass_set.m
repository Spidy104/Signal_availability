clc;
close all;
clear all;
s = load('exp2/s.mat');
s_new = cell2mat(struct2cell(s));
fs = 1e3;
T = 1/fs;
a = size(s_new);
L = a(2);
t = (0:L-1).* T;
subplot(3, 2, 1);
stem(1000*t, s_new);
title("Amplitude s(t)")
xlabel("Time(milliseconds)")
ylabel("Amplitude of the noisy signal")
grid;
[y_prime, d] = lowpass(s_new, 250, fs);
subplot(3, 2, 2);
stem(1000*t, y_prime);
title("Amplitude of the filtered signal")
xlabel("Time(milliseconds)")
ylabel("Amplitude")
grid;
s_fft = fft(s_new, L);
y_new_fft = fft(y_prime, L);
subplot(3, 2, 3);
plot(fs/L*(-L/2:L/2-1),abs(fftshift(s_fft)),"LineWidth",3)
title("fft Spectrum in the Positive and Negative Frequencies of the noisy signal")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid;
subplot(3, 2, 4);
plot(fs/L*(-L/2:L/2-1),abs(y_new_fft),"LineWidth",3)
title("fft Spectrum in the Positive and Negative Frequencies of the filtered signal")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid;
subplot(3, 2, 5);
plot(fs/L*(-L/2:L/2-1),abs(s_fft),"LineWidth",3)
title("FFT magnitude spectrum of the noisy signal")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid;
subplot(3, 2, 6);
plot(fs/L*(0:L-1),abs(y_new_fft),"LineWidth",3)
title("fft Magnitude of the Filtered signal")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid;