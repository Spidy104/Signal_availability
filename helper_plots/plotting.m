function plotting(L, fs, mag, phase)
    subplot(3, 1, 1);
    plot(fs/L * (0:L-1), abs(mag));
    xlabel("F(Hz)")
    ylabel("|FFT(X)|")
    grid;
    subplot(3, 1, 2);
    plot(fs/L * (-L/2:L/2 - 1), abs(fftshift(mag)));
    xlabel("F(Hz)")
    ylabel("|FFT(X)|")
    grid;
    subplot(3, 1, 3);
    f = (-L/2:L/2-1)/L*fs;
    plot(f,phase/pi)
    title("Phase Spectrum of s(t)")
    xlabel("Frequency (Hz)")
    ylabel("Phase/\pi")
    grid;
end