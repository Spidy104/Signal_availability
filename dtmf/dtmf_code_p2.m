function x = dtmf_dial(number, FS)
    % DTMF frequency map using containers.Map
    keys = {'1','2','3','4','5','6','7','8','9','*','0','#'};
    freqs = {
        [697, 1209], [697, 1336], [697, 1477], ...
        [770, 1209], [770, 1336], [770, 1477], ...
        [852, 1209], [852, 1336], [852, 1477], ...
        [941, 1209], [941, 1336], [941, 1477]
    };
    DTMF = containers.Map(keys, freqs);
    
    MARK = 0.1;   % tone duration in seconds
    SPACE = 0.1;  % silence duration in seconds

    n = 0:(1/FS):(MARK - 1/FS);  % time vector for one tone
    x = [];  % initialize output signal

    for i = 1:length(number)
        d = number(i);
        f = DTMF(d);  % get frequency pair
        s = sin(2*pi*f(1)*n) + sin(2*pi*f(2)*n);  % DTMF tone
        silence = zeros(1, round(SPACE * FS));   % silence between tones
        x = [x, s, silence];  % concatenate tone and silence
    end
end

dtmf_signal = dtmf_dial('7483295067', 24e3);
sound(dtmf_signal, 24e3);
figure;
plot(dtmf_signal)
xlabel("Time(s)");
ylabel("Amplitude of the signal");
title("Time domain range of the DTMF plot");

