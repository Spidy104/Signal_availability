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

dtmf_signal = dtmf_dial('9073065898', 24e3);
%sound(dtmf_signal, 8000); % Play the generated DTMF tones
figure;
subplot(2, 1, 1);
plot(dtmf_signal)

x = dtmf_signal;

function edges = dtmf_split(x, win, th)
    if nargin < 2
        win = 80;
    end
    if nargin < 3
        th = 200;
    end

    % Reshape the signal into chunks of 'win' samples
    x_trunc = x(1 : floor(length(x)/win) * win);
    w = reshape(x_trunc, win, []).';  % each row is one chunk

    % Compute energy of each chunk
    we = sum(w.^2, 2);
    L = length(we);
    
    edges = [];  % initialize result
    ix = 1;
    
    while ix <= L
        % Skip silence
        while ix <= L && we(ix) < th
            ix = ix + 1;
        end
        if ix > L
            break;  % ended in silence
        end
        iy = ix;
        % Scan through active region
        while iy <= L && we(iy) > th
            iy = iy + 1;
        end
        % Store detected edge (convert chunk index to sample index)
        edges = [edges; (ix-1)*win+1, (iy-1)*win+1];
        ix = iy;
    end
end
subplot(2, 1, 2);
X = abs(fft(x(1:2400)));
plot(X(1:500));
function number = dtmf_decode(x, FS)
    % DTMF standard frequencies
    LO_FREQS = [697, 770, 852, 941];
    HI_FREQS = [1209, 1336, 1477];
    
    % DTMF key map
    KEYS = ['1', '2', '3';
            '4', '5', '6';
            '7', '8', '9';
            '*', '0', '#'];
    
    % Frequency search ranges
    LO_RANGE = [680, 960];   % Low frequency range
    HI_RANGE = [1180, 1500]; % High frequency range
    
    number = '';  % Initialize output

    % If edges are not provided, detect them
    if nargin < 3
        edges = dtmf_split(x, 240, 200);  % Assuming win=240 and th=200
    end

    for k = 1:size(edges, 1)
        segment = x(edges(k, 1)+1 : edges(k, 2));  % MATLAB uses 1-based indexing

        % Compute FFT and magnitude spectrum
        X = abs(fft(segment));
        N = length(X);
        res = FS / N;  % Frequency resolution in Hz per bin

        % Find low-frequency peak
        a = floor(LO_RANGE(1) / res);
        b = ceil(LO_RANGE(2) / res);
        [~, idx] = max(X(a:b));
        lo_bin = a + idx - 1;
        lo_freq = lo_bin * res;

        % Find high-frequency peak
        a = floor(HI_RANGE(1) / res);
        b = ceil(HI_RANGE(2) / res);
        [~, idx] = max(X(a:b));
        hi_bin = a + idx - 1;
        hi_freq = hi_bin * res;

        % Match to closest standard frequencies
        [~, row] = min(abs(LO_FREQS - lo_freq));
        [~, col] = min(abs(HI_FREQS - hi_freq));

        % Map to keypad character
        number(end+1) = KEYS(row, col);
    end
end
dtmf_decode(x, 24e3)