clc;
clear all;
close all;
fs = 1000;
T = 1/fs;
L = input("Enter the length of the signal: ");
t = (0:L-1).*T;
a1 = 2.45;
a2 = -sqrt(2);
s = 0.54 + a1*cos(2*pi*50*t) + a2*sin(2*pi*120*t);
subplot(4, 1, 1);
stem(1000*t, s);
xlabel("Time(milliseconds)")
ylabel("Amplitude")
grid;
y = fft(s, L);
subplot(4, 1, 2);
plot(fs/L*(-L/2:L/2-1),abs(fftshift(y)),"LineWidth",3)
title("fft Spectrum in the Positive and Negative Frequencies")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid;
subplot(4, 1, 3);
plot(fs/L*(0:L-1),abs(y),"LineWidth",3)
title("Complex Magnitude of fft Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid;
subplot(4, 1, 4);
z = fftshift(y);
f = (-L/2:L/2-1)/L*fs;
theta = angle(z);
stem(f,theta/pi)
title("Phase Spectrum of s(t)")
xlabel("Frequency (Hz)")
ylabel("Phase/\pi")
grid;