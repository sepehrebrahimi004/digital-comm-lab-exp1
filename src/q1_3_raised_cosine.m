%Q1_3  4-PAM, BPSK and 4-QAM waveforms with raised-cosine pulse shaping,
%      their spectra, and the effect of the roll-off factor.

N_bits = 100;  fs = 100;  sps = 8;  beta = 0.5;  span = 10;  fc = 10;
bits = randi([0 1], N_bits, 1);
rc   = rcosdesign(beta, span, sps, 'normal');          % raised cosine (not root)

pam = pammod(bit2int(bits, 2), 4, 0, 'gray');           % levels -3 -1 +1 +3
bpsk = 1 - 2*bits;                                      % +1 / -1
qam = qammod(bits, 4, 'InputType', 'bit');              % +-1 +-1j

shape = @(sym) upfirdn(sym, rc, sps);
x_pam  = real(shape(pam));
x_bpsk = shape(bpsk);
x_qam  = shape(qam);
t = @(x) (0:numel(x)-1)'/fs;
s_bpsk = real(x_bpsk) .* cos(2*pi*fc*t(x_bpsk));
s_qam  = real(x_qam) .* cos(2*pi*fc*t(x_qam)) - imag(x_qam) .* sin(2*pi*fc*t(x_qam));

f = figure('Visible', 'off', 'Position', [100 100 1000 750]);
sig = {x_pam, s_bpsk, s_qam};
names = {'4-PAM (baseband)', 'BPSK on a 10 Hz carrier', '4-QAM on a 10 Hz carrier'};
for k = 1:3
    subplot(3, 2, 2*k-1);
    plot(t(sig{k}), sig{k}); grid on; xlim([0 4]);
    title(names{k}); xlabel('time (s)'); ylabel('amplitude');
    subplot(3, 2, 2*k);
    [p, fr] = pwelch(sig{k}, hann(256), 128, 1024, fs, 'centered');
    plot(fr, 10*log10(p/max(p))); grid on; ylim([-60 3]); xlim([-50 50]);
    title(['Spectrum: ' names{k}]); xlabel('frequency (Hz)'); ylabel('dB');
end
save_figure(f, 'q1_3_waveforms_spectra');

% Effect of the roll-off factor
f = figure('Visible', 'off', 'Position', [100 100 1000 380]);
betas = [0 0.5 1];
for b = betas
    h = rcosdesign(max(b, 1e-3), span, sps, 'normal');
    subplot(1, 2, 1); plot((-span*sps/2:span*sps/2)/sps, h/max(h), 'LineWidth', 1.3); hold on;
    [H, w] = freqz(h, 1, 2048, fs);
    subplot(1, 2, 2); plot(w, 20*log10(abs(H)/max(abs(H))), 'LineWidth', 1.3); hold on;
end
subplot(1, 2, 1); grid on; xlabel('time (symbols)'); title('Raised-cosine pulse');
xlim([-5 5]); legend('\beta = 0', '\beta = 0.5', '\beta = 1');
subplot(1, 2, 2); grid on; xlabel('frequency (Hz)'); ylabel('dB'); ylim([-60 3]); xlim([0 25]);
xline(fs/sps/2, 'k:', 'R_s/2'); title('Spectrum: bandwidth = (1+\beta) R_s / 2');
save_figure(f, 'q1_3_rolloff');
