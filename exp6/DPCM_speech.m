% Clear all variables from the workspace to ensure a clean environment
clear all;
% Close all open figure windows to avoid clutter
close all;
% Clear the command window for a fresh output display
clc;
% Read the audio file 'Recording.wav' into variable x (samples) and fs (sampling frequency)
[x, fs] = audioread("Recording.wav");

% Check if the audio is stereo (more than one channel)
if size(x, 2) > 1
    % Convert stereo to mono by averaging the channels
    x = mean(x, 2);
end
% Transpose the signal to row vector for easier processing
x = x';
% Normalize the signal to have a maximum amplitude of 1 to prevent clipping
x = x/max(abs(x));
% Define the number of quantization bits for DPCM
nbits = 4;
% Get the length of the signal (number of samples)
N = length(x);
% Create a time vector for plotting (t = 0 to N-1 samples divided by sampling frequency)
t = (0:N-1)/fs;
% Initialize arrays for DPCM encoding
x_pred = zeros(1, N); % Predicted signal
e = zeros(1, N);      % Prediction error
eq = zeros(1, N);     % Quantized prediction error
x_recon = zeros(1, N); % Reconstructed signal at encoder
% Calculate the quantization step size based on the signal's dynamic range and number of bits
% Step size = (2 * max amplitude) / (2^nbits)
step_size = 2*max(abs(x))/(2^nbits);
% Initialize first sample for encoding
x_pred(1) = 0;                  % First prediction is 0 (no prior sample)
e(1) = x(1) - x_pred(1);        % Prediction error = actual sample - predicted sample
eq(1) = step_size * round(e(1)/step_size); % Quantize the error by rounding to nearest step
x_recon(1) = x_pred(1) + eq(1); % Reconstruct first sample by adding quantized error
% DPCM encoding loop for remaining samples
for n = 2:N
    x_pred(n) = x_recon(n-1);              % Predict current sample as previous reconstructed sample
    e(n) = x(n) - x_pred(n);               % Calculate prediction error
    eq(n) = step_size * round(e(n)/step_size); % Quantize the prediction error
    x_recon(n) = x_pred(n) + eq(n);        % Reconstruct current sample
end
% Plot original vs decoded speech signal
subplot(2,1,1); % Create first subplot (2 rows, 1 column, position 1)
plot(t, x, 'b', 'LineWidth', 1); % Plot original signal in blue
xlabel("Time series"); % Label x-axis
ylabel("Amplitude plot"); % Label y-axis
title("Original signal"); % Title of the plot
% Plot quantized error
subplot(2,1,2); % Create third subplot (3 rows, 1 column, position 3)
plot(t, eq, 'g', 'LineWidth', 1); % Plot quantized error in green
title('Quantized Prediction Error (Transmitted Values)'); % Title of the plot
xlabel('Time (s)'); % Label x-axis
ylabel('Error Amplitude'); % Label y-axis
grid on; % Enable grid for better readability
% In a real system, only the quantized errors (eq) are transmitted
% The decoder reconstructs the signal using the same prediction method as the encoder
% Initialize arrays for decoding
x_decoded = zeros(1, N); % Decoded signal at the receiver
x_dec_pred = zeros(1, N); % Decoder's prediction signal
% Decode first sample
x_dec_pred(1) = 0;                 % First prediction is 0 (same as encoder)
x_decoded(1) = x_dec_pred(1) + eq(1); % Reconstruct first sample using quantized error
% Decoding loop for remaining samples
for n = 2:N
    x_dec_pred(n) = x_decoded(n-1);    % Predict current sample as previous decoded sample
    x_decoded(n) = x_dec_pred(n) + eq(n); % Add quantized error to get decoded sample
end
% Mean Square Error (MSE) between original and decoded signals
mse = mean((x - x_decoded).^2);
% Signal-to-Noise Ratio (SNR) in decibels
% SNR = 10 * log10(signal power / noise power)
snr_val = 10*log10(mean(x.^2)/mse);
% Compression ratio calculation
original_bit_rate = 16 * fs; % Original bit rate assuming 16-bit PCM encoding
dpcm_bit_rate = nbits * fs; % DPCM bit rate using nbits per sample
compression_ratio = original_bit_rate / dpcm_bit_rate; % Ratio of original to compressed bit rate
% Plot original and decoded signals for comparison
figure; % Create a new figure window
plot(t, x_decoded, 'r--', 'LineWidth', 1); % Plot decoded signal in red (dashed line)
title('Speech Signal: Original vs DPCM Decoded'); % Title of the plot
xlabel('Time (s)'); % Label x-axis
ylabel('Amplitude'); % Label y-axis
legend('Original', 'DPCM Decoded'); % Add legend to distinguish signals
grid on; % Enable grid for better readability
% Display performance metrics in the command window
fprintf('DPCM Speech Coding Results:\n');
fprintf('Quantization bits: %d\n', nbits); % Number of bits used for quantization
fprintf('Mean Square Error: %.6f\n', mse); % MSE value
fprintf('Signal-to-Noise Ratio: %.2f dB\n', snr_val); % SNR value in dB
fprintf('Original bit rate (16-bit PCM): %d bits/second\n', original_bit_rate); % Original bit rate
fprintf('DPCM bit rate: %d bits/second\n', dpcm_bit_rate); % DPCM bit rate
fprintf('Compression ratio: %.2f:1\n', compression_ratio); % Compression ratio
% Uncomment these lines to hear the signals
sound(x, fs); % Play original signal
pause(length(x)/fs + 0.5); % Wait for playback to complete plus a 0.5-second gap
sound(x_decoded, fs); % Play decoded signal