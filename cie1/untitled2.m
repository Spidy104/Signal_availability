fs = 5000;   
t = 0:1/fs:1; 
f_sig = 50;  
f_noise = 60; 
signal = sin(2*pi*f_sig*t); 
noise = 0.5 * sin(2*pi*f_noise*t); 
noisy_signal = signal + noise;
reference_noise = 0.5 * sin(2*pi*f_noise*t + pi/4); 
N = 32;  
mu = 0.01;
w = zeros(N,1); 
x = zeros(N,1); 
filtered_signal = zeros(size(noisy_signal));
for i = 1:length(t)
    
    
    x = [reference_noise(i); x(1:end-1)];
    
    y = w' * x;
    
    
    e = noisy_signal(i) - y;
    
    
    w = w + mu * e * x;
    
   
    filtered_signal(i) = e;
end
figure;
 subplot(3,1,1);
plot(t, noisy_signal, 'r'); grid on;
title('Noisy Signal');
xlabel('Time (s)'); ylabel('Amplitude');
subplot(3,1,2);
plot(t, filtered_signal, 'b'); grid on;
title('Filtered Signal (Adaptive Noise Cancellation)');
xlabel('Time (s)'); ylabel('Amplitude');
subplot(3,1,3);
plot(t, signal, 'g'); grid on;
title('Original Signal (Reference)');
xlabel('Time (s)'); ylabel('Amplitude');
