% DPCM Transmitter and Receiver for 10 Hz Sinusoidal Input
clear all;
close all;
clc;

% Parameters
f = 10;                 % Sinusoid frequency (Hz)
fs = 1000;              % Sampling frequency (Hz)
T = 1;                  % Signal duration (seconds)
t = 0:1/fs:T-1/fs;      % Time vector
A = 1;                  % Sinusoid amplitude
nBits = 4;              % Number of quantization bits
SNR_dB = 20;            % Channel SNR (dB) for AWGN
N = length(t);          % Number of samples

% Generate sinusoidal input signal
x = A * sin(2*pi*f*t);
fprintf('Generated %d samples of %d Hz sinusoid\n', N, f);

% DPCM Transmitter
% Initialize variables
e = zeros(1, N);        % Prediction error
eq = zeros(1, N);       % Quantized prediction error
x_pred = zeros(1, N);   % Predicted signal
x_quant = zeros(1, N);  % Reconstructed signal at transmitter
x_quant(1) = x(1);      % Initialize first sample to input

% Calculate quantization step size based on max prediction error
max_error = 2*A;        % Conservative estimate for error range
L = 2^nBits;            % Number of quantization levels
delta = 2*max_error/(L-1); % Quantization step size

% Transmitter loop
for n = 2:N
    % Predict current sample using previous reconstructed sample
    x_pred(n) = x_quant(n-1);
    
    % Prediction error
    e(n) = x(n) - x_pred(n);
    
    % Quantize prediction error
    eq(n) = round(e(n)/delta) * delta;
    
    % Clip to prevent quantization overflow
    eq(n) = max(min(eq(n), max_error), -max_error);
    
    % Reconstruct signal at transmitter
    x_quant(n) = x_pred(n) + eq(n);
end

% Simulate Channel with AWGN
SNR_linear = 10^(SNR_dB/10);
signal_power = mean(eq.^2);
noise_power = signal_power / SNR_linear;
sigma = sqrt(noise_power);
noise = sigma * randn(1, N);
eq_rx = eq + noise;     % Received quantized error with noise
fprintf('Added AWGN with SNR = %.1f dB\n', SNR_dB);

% DPCM Receiver
x_rec = zeros(1, N);    % Reconstructed signal at receiver
x_rec(1) = x(1);        % Initialize first sample to input
x_pred_rx = zeros(1, N);% Predicted signal at receiver

% Receiver loop
for n = 2:N
    % Predict current sample (same predictor as transmitter)
    x_pred_rx(n) = x_rec(n-1);
    
    % Reconstruct signal
    x_rec(n) = x_pred_rx(n) + eq_rx(n);
end

% Performance Metrics
mse = mean((x - x_rec).^2); % Mean Squared Error
snr = 10*log10(mean(x.^2)/mse); % Signal-to-Noise Ratio
max_error = max(abs(x - x_rec)); % Maximum reconstruction error
fprintf('Performance Metrics:\n');
fprintf('  Mean Squared Error: %.6f\n', mse);
fprintf('  SNR: %.2f dB\n', snr);
fprintf('  Maximum Reconstruction Error: %.6f\n', max_error);

% Plotting
figure('Position', [100, 100, 1200, 800]);

% Original vs Reconstructed Signal
subplot(2,2,1);
plot(t, x, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Original Signal');
hold on;
plot(t, x_rec, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Reconstructed Signal');
title('Original vs Reconstructed Signal');
xlabel('Time (s)'); ylabel('Amplitude');
legend; grid on; axis tight;

% Prediction Error
subplot(2,2,2);
plot(t, e, 'b-', 'LineWidth', 1.5);
title('Prediction Error');
xlabel('Time (s)'); ylabel('Error');
grid on; axis tight;

% Quantized Prediction Error
subplot(2,2,3);
stairs(t, eq, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Quantized Error');
hold on;
plot(t([1 end]), delta*[-L/2 L/2; -L/2 L/2], 'k--', 'DisplayName', 'Quantization Levels');
title('Quantized Prediction Error');
xlabel('Time (s)'); ylabel('Quantized Error');
legend; grid on; axis tight;

% Reconstruction Error
subplot(2,2,4);
plot(t, x - x_rec, 'b-', 'LineWidth', 1.5);
title('Reconstruction Error');
xlabel('Time (s)'); ylabel('Error');
grid on; axis tight;

% Optional: Parameter Sweep for Quantization Bits
nBits_range = [2, 4, 8];
mse_results = zeros(1, length(nBits_range));
for idx = 1:length(nBits_range)
    nBits = nBits_range(idx);
    L = 2^nBits;
    delta = 2*max_error/(L-1);
    
    % Transmitter
    x_quant = zeros(1, N); x_quant(1) = x(1);
    eq = zeros(1, N);
    for n = 2:N
        x_pred(n) = x_quant(n-1);
        e(n) = x(n) - x_pred(n);
        eq(n) = round(e(n)/delta) * delta;
        eq(n) = max(min(eq(n), max_error), -max_error);
        x_quant(n) = x_pred(n) + eq(n);
    end
    
    % Receiver (no noise for simplicity in sweep)
    x_rec = zeros(1, N); x_rec(1) = x(1);
    for n = 2:N
        x_rec(n) = x_rec(n-1) + eq(n);
    end
    
    % Store MSE
    mse_results(idx) = mean((x - x_rec).^2);
end

% Plot MSE vs. Quantization Bits
figure;
semilogy(nBits_range, mse_results, 'b-o', 'LineWidth', 1.5);
title('MSE vs. Quantization Bits');
xlabel('Number of Quantization Bits'); ylabel('Mean Squared Error');
grid on;
fprintf('MSE for %d, %d, %d bits: %s\n', nBits_range, sprintf('%.6f ', mse_results));