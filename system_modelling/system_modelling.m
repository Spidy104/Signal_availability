A = [1 -1.5 0.7];   % Denominator coefficients
B = [0 1.2 0.5];    % Numerator coefficients (starts at delay 1)
Ts = 1;             % Sampling time

true_sys = idpoly(A, B); % ARX model structure

% Step 2: Generate input data (e.g., PRBS or white noise)
N = 300;                        % Number of samples
u = idinput(N, 'rbs');          % Pseudo-random binary sequence (PRBS)
e = 0.1 * randn(N,1);           % Measurement noise
y = sim(true_sys, u) + e;       % Simulated output with noise

% Step 3: Create an iddata object
data = iddata(y, u, Ts);

% Step 4: Estimate ARX model from data
na = 2; % number of poles
nb = 2; % number of zeros + 1
nk = 1; % input-output delay (number of samples)
model_arx = arx(data, [na nb nk]);

% Step 5: Compare estimated vs actual
compare(data, model_arx);
disp('Estimated ARX model:');
present(model_arx);