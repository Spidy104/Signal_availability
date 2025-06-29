% DPCM Transmitter and Receiver for 10 Hz Sinusoidal Input

% Clear workspace and command window
clear all;
close all;
clc;

% Parameters
f = 10;                 % Sinusoid frequency (Hz)
fs = 1000;              % Sampling frequency (Hz)
T = 1;                  % Duration of signal (seconds)
t = 0:1/fs:T-1/fs;      % Time vector
A = 1;                  % Amplitude of sinusoid
nBits = 4;              % Number of bits for quantization
L = 2^nBits;            % Number of quantization levels
delta = 2*A/(L-1);      % Quantization step size

% Generate sinusoidal input signal
x = A * sin(2*pi*f*t);

% DPCM Transmitter
% Initialize variables
N = length(x);
e = zeros(1, N);        % Prediction error
eq = zeros(1, N);       % Quantized prediction error
x_pred = zeros(1, N);   % Predicted signal
x_quant = zeros(1, N);  % Quantized (reconstructed) signal at transmitter

% Transmitter loop
for n = 2:N
    % Predict current sample (using previous reconstructed sample)
    x_pred(n) = x_quant(n-1);
    
    % Prediction error
    e(n) = x(n) - x_pred(n);
    
    % Quantize prediction error
    eq(n) = round(e(n)/delta) * delta;
    
    % Reconstruct signal at transmitter
    x_quant(n) = x_pred(n) + eq(n);
end

% Simulate Channel (Noiseless, so eq is directly used at receiver)
eq_rx = eq; % Received quantized error

% DPCM Receiver
x_rec = zeros(1, N);    % Reconstructed signal at receiver
x_pred_rx = zeros(1, N);% Predicted signal at receiver

% Receiver loop
for n = 2:N
    % Predict current sample (same predictor as transmitter)
    x_pred_rx(n) = x_rec(n-1);
    
    % Reconstruct signal
    x_rec(n) = x_pred_rx(n) + eq_rx(n);
end

% Calculate Mean Squared Error
mse = mean((x - x_rec).^2);
fprintf('Mean Squared Error: %.6f\n', mse);

% Plotting
figure('Position', [100, 100, 1200, 800]);

% Original and Reconstructed Signal
subplot(2,2,1);
plot(t, x, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Original Signal');
hold on;
plot(t, x_rec, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Reconstructed Signal');
title('Original vs Reconstructed Signal');
xlabel('Time (s)'); ylabel('Amplitude');
legend; grid on;

% Prediction Error
subplot(2,2,2);
plot(t, e, 'b-', 'LineWidth', 1.5);
title('Prediction Error');
xlabel('Time (s)'); ylabel('Error');
grid on;

% Quantized Prediction Error
subplot(2,2,3);
stairs(t, eq, 'b-', 'LineWidth', 1.5);
title('Quantized Prediction Error');
xlabel('Time (s)'); ylabel('Quantized Error');
grid on;

% Error between Original and Reconstructed Signal
subplot(2,2,4);
plot(t, x - x_rec, 'b-', 'LineWidth', 1.5);
title('Reconstruction Error');
xlabel('Time (s)'); ylabel('Error');
grid on;