%Q1_4  4-QAM (QPSK) under Gaussian phase noise and AWGN at Eb/N0 = 10 dB.

EbN0_dB   = 10;
sigma_deg = [0 5 10 20];
k = 2;                                          % bits per symbol
snr_dB = EbN0_dB + 10*log10(k);                 % Es/N0 for a unit-power complex signal
ref = qammod(0:3, 4, 'UnitAveragePower', true);

% Constellations with 1000 symbols (as in the assignment)
f = figure('Visible', 'off', 'Position', [100 100 1000 280]);
for i = 1:numel(sigma_deg)
    bits = randi([0 1], 2*1000, 1);
    tx = qammod(bits, 4, 'InputType', 'bit', 'UnitAveragePower', true);
    rx = awgn(tx .* exp(1j*deg2rad(sigma_deg(i))*randn(size(tx))), snr_dB, 'measured');
    subplot(1, 4, i);
    scatter(real(rx), imag(rx), 6, 'filled', 'MarkerFaceAlpha', 0.5); hold on;
    scatter(real(ref), imag(ref), 60, 'r', 'filled');
    axis equal; axis([-1.6 1.6 -1.6 1.6]); grid on;
    title(sprintf('\\sigma_\\phi = %d°', sigma_deg(i))); xlabel('I'); ylabel('Q');
end
save_figure(f, 'q1_4_constellations');

% BER vs. phase-noise level with enough symbols to resolve small error rates
sig = 0:2:30;
ber = zeros(size(sig));
for i = 1:numel(sig)
    bits = randi([0 1], 2*2e6, 1);
    tx = qammod(bits, 4, 'InputType', 'bit', 'UnitAveragePower', true);
    rx = awgn(tx .* exp(1j*deg2rad(sig(i))*randn(size(tx))), snr_dB, 'measured');
    ber(i) = mean(qamdemod(rx, 4, 'OutputType', 'bit', 'UnitAveragePower', true) ~= bits);
end
f = figure('Visible', 'off', 'Position', [100 100 650 400]);
semilogy(sig, max(ber, 1e-7), 'o-', 'LineWidth', 1.5); hold on;
yline(berawgn(EbN0_dB, 'qam', 4), 'k--', 'no phase noise (theory)');
grid on; xlabel('\sigma_\phi (degrees)'); ylabel('Bit error rate');
title('QPSK at E_b/N_0 = 10 dB: BER grows sharply once \sigma_\phi \approx 15°');
save_figure(f, 'q1_4_ber_vs_phase_noise');
fprintf('Q1.4  BER at sigma = 0/10/20 deg: %.1e / %.1e / %.1e\n', ber(sig == 0), ber(sig == 10), ber(sig == 20));
