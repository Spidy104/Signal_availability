close all;
clear all;
clc;
fs = 8e3;
N = 2e3;
mu = 0.01;
filter_order = 5;
SNR = 20;
t = (0:N-1)*1/fs;
s = sqrt(2.45)*sin(2*pi*120*t) + randn(1, N);
channel_resp = [0.5, 0.3, -0.9, -0.2, 0.7, -0.1];
received_signal = filter(channel_resp, 1, s);
noise_pwr = 10^(-SNR/10);
noise = sqrt(noise_pwr) * randn(1, N);
noisy_received_signal = received_signal + noise;

equalizer_weights = zeros(1, filter_order);
output_signal = zeros(1, N);

for i = filter_order+1:N
    x = noisy_received_signal(i-filter_order:i-1);
    y_hat = equalizer_weights * x';
    desired_signal = s(i);
    error = desired_signal - y_hat;
    equalizer_weights = equalizer_weights + 2* mu * error * x;
    output_signal(i) = y_hat;
end
% plot the transmitted, received and the equalized and the error signal
% also
error_signal = desired_signal - output_signal(filter_order+1:N);
figure;
subplot(2,2,1), plot(t, s), title('Transmitted Signal'), xlabel('Time (s)'), ylabel('Amplitude');
subplot(2,2,2), plot(t, noisy_received_signal), title('Noisy Received Signal'), xlabel('Time (s)'), ylabel('Amplitude');
subplot(2,2,3), plot(output_signal), title('Equalized Signal'), xlabel('Time (s)'), ylabel('Amplitude');
error = s - output_signal  ;
subplot(2, 2, 4), plot(error_signal), title('Error Signal'), xlabel('Time (s)'), ylabel('Amplitude');