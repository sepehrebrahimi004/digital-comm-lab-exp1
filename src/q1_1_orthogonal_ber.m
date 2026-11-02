%Q1_1  Binary orthogonal signaling: Monte-Carlo BER vs. theory.
%   bit 0 -> (y0, y1) = (sqrt(Eb) + n0, n1),  bit 1 -> (n0, sqrt(Eb) + n1),
%   n0, n1 ~ N(0, N0/2). Two receivers are compared:
%     * comparison  y1 > y0             (this IS the ML detector for equal priors)
%     * single branch  y1 > sqrt(Eb)/2  (ignores y0; 3 dB worse)

N_bits  = 2e6;
Eb      = 1;
EbN0_dB = 0:1:13;

ber_cmp = zeros(size(EbN0_dB));
ber_one = zeros(size(EbN0_dB));
for k = 1:numel(EbN0_dB)
    N0    = Eb / 10^(EbN0_dB(k)/10);
    sigma = sqrt(N0/2);
    bits  = rand(1, N_bits) > 0.5;
    y0 = sqrt(Eb)*(~bits) + sigma*randn(1, N_bits);
    y1 = sqrt(Eb)*bits    + sigma*randn(1, N_bits);
    ber_cmp(k) = mean((y1 > y0) ~= bits);
    ber_one(k) = mean((y1 > sqrt(Eb)/2) ~= bits);
end

EbN0 = 10.^(EbN0_dB/10);
f = figure('Visible', 'off', 'Position', [100 100 700 450]);
semilogy(EbN0_dB, qfunc(sqrt(EbN0)), 'k-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_dB, ber_cmp, 'o', 'MarkerSize', 7, 'LineWidth', 1.5);
semilogy(EbN0_dB, qfunc(sqrt(EbN0/2)), 'k--', 'LineWidth', 1.2);
semilogy(EbN0_dB, ber_one, 's', 'MarkerSize', 7, 'LineWidth', 1.5);
grid on; ylim([1e-6 1]);
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate');
legend('theory  Q(\surd(E_b/N_0))', 'simulation: compare y_1 > y_0 (ML)', ...
       'theory  Q(\surd(E_b/2N_0))', 'simulation: y_1 > \surdE_b/2 only', 'Location', 'southwest');
title(sprintf('Binary orthogonal signaling (%g bits per point)', N_bits));
save_figure(f, 'q1_1_orthogonal_ber');
fprintf('Q1.1  BER at 10 dB: sim %.2e, theory %.2e\n', ber_cmp(EbN0_dB == 10), qfunc(sqrt(10)));
