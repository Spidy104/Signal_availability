clc;
close all;
clear all;
fs = 2000;
specs = abs(input("Enter the filter passband and stopband attenuation:"));
freqs = input("Enter the filter passband and stopband frequencies: ")/(fs/2);
[N, wc] = buttord(freqs(1), freqs(2), specs(1), specs(2));
[b, a] = butter(N, wc, 'high');
freqz(b, a);
L = input("Enter the length of the signal:");
t = (0:L-1).*(1/fs);
s = 2*sin(2*150*pi*t);
figure(2);
subplot(2, 2, 1);
stem(1000*t, s);
xlabel("Time(milliseconds)")
ylabel("Amplitude of noisy signal");
y_new = filter(b, a, s);
subplot(2, 2, 2);
stem(1000*t, y_new);
xlabel("Time(milliseconds)")
ylabel("Amplitude of filtered signal");
s_fft = fft(s, L);
y_new_fft = fft(y_new, L);
subplot(2, 2, 3);
stem(fs/L*(0:L-1), abs(s_fft));
xlabel("f (Hz)")
ylabel("|FFT(Hz)| of the noisy signal");
subplot(2, 2, 4);
stem(fs/L*(0:L-1), abs(y_new_fft));
xlabel("f (Hz)")
ylabel("|FFT(Hz)| of the filtered signal");

