% QPSK Modulated System with Adaptive LMS-Based Equalizer
% This code implements a complete QPSK communication system with channel
% impairments and adaptive equalization using the LMS algorithm

clear all;
close all;
clc;

%% System Parameters
N = 10000;              % Number of data symbols
M = 4;                  % QPSK modulation order (4 symbols)
EbN0_dB = 10;          % Energy per bit to noise power ratio (dB)
numTaps = 15;          % Number of equalizer taps (odd for symmetry)
mu = 0.01;             % LMS step size (learning rate)
trainingSyms = 1500;   % Number of training symbols
phaseOffset = pi/4;    % QPSK phase offset (Gray coding)

%% Data Generation
% Generate random binary data and convert to symbols
data = randi([0 M-1], N, 1);
fprintf('Generated %d random QPSK symbols\n', N);

%% QPSK Modulation
% Modulate data using QPSK with Gray coding
qpskSyms = pskmod(data, M, phaseOffset);
fprintf('QPSK modulation completed\n');

%% Channel Model
% Simulate multipath fading channel with ISI
% Channel impulse response with multiple taps
h = [0.8; 0.5*exp(1i*pi/6); 0.3*exp(-1i*pi/3); 0.1*exp(1i*pi/4)];
chanOut = conv(qpskSyms, h, 'same');
fprintf('Channel convolution completed (Channel length: %d taps)\n', length(h));

%% Add AWGN Noise
% Calculate noise parameters
EbN0_linear = 10^(EbN0_dB/10);
Es = mean(abs(qpskSyms).^2);           % Average symbol energy
Eb = Es / log2(M);                     % Energy per bit
N0 = Eb / EbN0_linear;                 % Noise power spectral density
sigma = sqrt(N0/2);                    % Noise standard deviation

% Generate complex AWGN
noise = sigma * (randn(size(chanOut)) + 1i*randn(size(chanOut)));
rxSignal = chanOut + noise;
fprintf('AWGN added (SNR = %.1f dB)\n', EbN0_dB);

%% LMS Adaptive Equalizer Implementation
% Initialize equalizer parameters
w = zeros(numTaps, 1);                 % Equalizer tap weights
w(ceil(numTaps/2)) = 1;               % Initialize center tap to 1
eqOut = zeros(N, 1);                  % Equalizer output buffer
mse_history = zeros(trainingSyms, 1); % MSE history for learning curve
weight_history = zeros(numTaps, trainingSyms); % Weight evolution

fprintf('Starting LMS equalization...\n');

% Main LMS adaptation loop
for n = numTaps:N
    % Create input vector (tapped delay line)
    x_n = rxSignal(n:-1:n-numTaps+1);
    
    % Compute equalizer output
    y_n = w' * x_n;
    eqOut(n) = y_n;
    
    if n <= trainingSyms + numTaps - 1
        % Training phase: use known transmitted symbols
        desired = qpskSyms(n);
        error = desired - y_n;
        
        % Store MSE and weights for analysis
        idx = n - numTaps + 1;
        if idx > 0 && idx <= trainingSyms
            mse_history(idx) = abs(error)^2;
            weight_history(:, idx) = w;
        end
    else
        % Decision-directed phase: use decisions as reference
        % Hard decision on equalized symbol
        decision = pskmod(pskdemod(y_n, M, phaseOffset), M, phaseOffset);
        error = decision - y_n;
    end
    
    % LMS weight update
    w = w + mu * conj(error) * x_n;
end

fprintf('LMS equalization completed\n');

%% Performance Evaluation
% Demodulate equalized symbols
demodData = pskdemod(eqOut, M, phaseOffset);

% Calculate Bit Error Rate (BER)
[numErrors, ber] = biterr(data, demodData);
fprintf('\nPerformance Results:\n');
fprintf('Total bit errors: %d out of %d\n', numErrors, N*log2(M));
fprintf('Bit Error Rate (BER): %.6f\n', ber);

% Calculate Symbol Error Rate (SER)
symErrors = sum(data ~= demodData);
ser = symErrors / N;
fprintf('Symbol Error Rate (SER): %.6f\n', ser);

%% Advanced Analysis and Plotting

% Figure 1: Constellation Diagrams
figure('Position', [100, 100, 1200, 800]);

subplot(2,3,1);
plot(real(qpskSyms), imag(qpskSyms), 'bo', 'MarkerSize', 6);
title('Transmitted QPSK Constellation');
xlabel('In-Phase'); ylabel('Quadrature');
grid on; axis equal;

subplot(2,3,2);
plot(real(rxSignal), imag(rxSignal), 'r.', 'MarkerSize', 4);
title('Received Signal (After Channel + Noise)');
xlabel('In-Phase'); ylabel('Quadrature');
grid on; axis equal;

subplot(2,3,3);
plot(real(eqOut), imag(eqOut), 'g.', 'MarkerSize', 4);
title('Equalized Signal Constellation');
xlabel('In-Phase'); ylabel('Quadrature');
grid on; axis equal;

% Channel frequency response
subplot(2,3,4);
[H, f] = freqz(h, 1, 512);
plot(f/pi, 20*log10(abs(H)));
title('Channel Frequency Response');
xlabel('Normalized Frequency (\times\pi rad/sample)');
ylabel('Magnitude (dB)');
grid on;

% Learning curve
subplot(2,3,5);
plot(1:trainingSyms, 10*log10(mse_history));
title('LMS Learning Curve');
xlabel('Training Symbol Index');
ylabel('MSE (dB)');
grid on;

% Weight convergence
subplot(2,3,6);
plot(1:trainingSyms, real(weight_history'));
title('Equalizer Weight Convergence (Real Part)');
xlabel('Training Symbol Index');
ylabel('Weight Value');
grid on;
legend(arrayfun(@(x) sprintf('Tap %d', x), 1:min(5,numTaps), 'UniformOutput', false));

% Figure 2: Error Analysis
figure('Position', [150, 150, 1000, 600]);

subplot(2,2,1);
semilogy(1:trainingSyms, mse_history);
title('Mean Squared Error vs Training Symbols');
xlabel('Training Symbol Index');
ylabel('MSE');
grid on;

subplot(2,2,2);
stem(1:length(h), abs(h));
title('Channel Impulse Response Magnitude');
xlabel('Tap Index');
ylabel('|h[n]|');
grid on;

subplot(2,2,3);
stem(1:numTaps, abs(w));
title('Final Equalizer Weights Magnitude');
xlabel('Tap Index');
ylabel('|w[n]|');
grid on;

subplot(2,2,4);
errorPattern = abs(data - demodData) > 0;
stem(find(errorPattern), ones(sum(errorPattern), 1), 'r');
title('Error Pattern (Symbol Errors)');
xlabel('Symbol Index');
ylabel('Error Indicator');
grid on;
xlim([1, min(1000, N)]);

%% Display Final Results
fprintf('\n=== SIMULATION SUMMARY ===\n');
fprintf('System Parameters:\n');
fprintf('  - Number of symbols: %d\n', N);
fprintf('  - Modulation: QPSK\n');
fprintf('  - SNR: %.1f dB\n', EbN0_dB);
fprintf('  - Equalizer taps: %d\n', numTaps);
fprintf('  - LMS step size: %.4f\n', mu);
fprintf('  - Training symbols: %d\n', trainingSyms);
fprintf('\nChannel Characteristics:\n');
fprintf('  - Channel length: %d taps\n', length(h));
fprintf('  - Channel type: Multipath fading\n');
fprintf('\nPerformance Metrics:\n');
fprintf('  - Bit Error Rate: %.6f (%.2e)\n', ber, ber);
fprintf('  - Symbol Error Rate: %.6f\n', ser);
fprintf('  - Final MSE: %.6f dB\n', 10*log10(mse_history(end)));

%% Optional: Save results
% Uncomment the following lines to save results to file
% save('qpsk_lms_results.mat', 'ber', 'ser', 'mse_history', 'w', 'eqOut');
% fprintf('\nResults saved to qpsk_lms_results.mat\n');