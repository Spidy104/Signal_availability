fs = 1000; 
f0 = 50;   
Q = 30;    


wo = f0/(fs/2); 
[b, a] = iirnotch(wo, wo/Q);

t = 0:1/fs:1; 
x = sin(2*pi*5*t)+ sin(2*pi*f0*t); 

y = filter(b, a, x);



figure;
subplot(2,1,1);
plot(t, x); title('Original Signal with 50Hz Noise'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(2,1,2);
plot(t, y,'r'); title('Filtered Signal (Notch Applied)'); xlabel('Time (s)'); ylabel('Amplitude');




figure;
freqz(b, a, fs, fs);
title('Frequency Response of the Notch Filter');