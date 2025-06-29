% QPSK Modulated System with Adaptive LMS Equalizer

% Clear workspace and command window
clear all;
close all;
clc;

% Parameters
N = 10000;              % Number of symbols
M = 4;                  % QPSK modulation (4 symbols)
EbN0_dB = 10;           % Signal-to-noise ratio (dB)
numTaps = 11;           % Number of equalizer taps (odd for symmetry)
mu = 0.01;              % LMS step size
trainingSyms = 1000;    % Number of training symbols

% Generate random data (0 to M-1)
data = randi([0 M-1], N, 1);

% QPSK Modulation
qpskSyms = pskmod(data, M, pi/4); % QPSK with 45-degree phase offset

% Channel Model (Multipath with ISI)
channel = [0.8; 0.4*exp(1i*pi/6); 0.2*exp(-1i*pi/3)]; % Example channel impulse response
chanOut = conv(qpskSyms, channel, 'same'); % Convolve signal with channel

% Add AWGN
EbN0 = 10^(EbN0_dB/10); % Convert dB to linear
Es = mean(abs(qpskSyms).^2); % Symbol energy
sigma = sqrt(Es/(2*EbN0)); % Noise standard deviation (QPSK has 2 bits/symbol)
noise = sigma * (randn(size(chanOut)) + 1i*randn(size(chanOut)));
rxSignal = chanOut + noise; % Received signal

% LMS Equalizer
% Initialize equalizer taps (zero except center tap)
w = zeros(numTaps, 1); 
w(ceil(numTaps/2)) = 1; % Center tap initialized to 1
eqOut = zeros(N, 1); % Equalizer output
errors = zeros(trainingSyms, 1); % Store errors for plotting

% LMS Algorithm
for n = numTaps:N
    % Extract input vector (sliding window)
    x_n = rxSignal(n:-1:n-numTaps+1);
    % Equalizer output
    y_n = w' * x_n;
    eqOut(n) = y_n;
    
    % Error calculation (training phase for first trainingSyms)
    if n <= trainingSyms
        e_n = qpskSyms(n) - y_n; % Error = desired - output
        errors(n) = abs(e_n)^2; % Store squared error
        % Update weights using LMS
        w = w + mu * conj(e_n) * x_n;
    else
        % Decision-directed mode
        % Demodulate to nearest QPSK symbol
        demodSym = pskdemod(y_n, M, pi/4);
        desired = pskmod(demodSym, M, pi/4);
        e_n = desired - y_n;
        % Update weights
        w = w + 2 * mu * conj(e_n) * x_n;
    end
end

% Demodulate equalized signal
demodData = pskdemod(eqOut, M, pi/4);

% Calculate BER
[~, ber] = biterr(data, demodData);

% Plotting
% Constellation Diagrams
figure;
subplot(2,1,1);
plot(real(rxSignal), imag(rxSignal), 'b.', 'MarkerSize', 10);
title('Received Signal Constellation (Before Equalization)');
xlabel('In-Phase'); ylabel('Quadrature'); grid on;

subplot(2,1,2);
plot(real(eqOut), imag(eqOut), 'r.', 'MarkerSize', 10);
title('Equalized Signal Constellation');
xlabel('In-Phase'); ylabel('Quadrature'); grid on;

% Learning Curve (MSE during training)
figure;
plot(1:trainingSyms, errors);
title('LMS Equalizer Learning Curve');
xlabel('Symbol Index'); ylabel('Mean Squared Error');
grid on;

% Display BER
fprintf('Bit Error Rate: %.4f\n', ber);