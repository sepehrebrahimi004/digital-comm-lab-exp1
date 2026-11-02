%Q1_5  BER of M-PAM, M-PSK, M-QAM and coherent M-FSK: simulation vs. theory,
%      plus constellation diagrams at Eb/N0 = 10 dB.
%
%   awgn() adds noise of power P/SNR. For a complex signal that power is split
%   over I and Q, so SNR = Es/N0. For a real signal (PAM) all of it lands on
%   the one real dimension, so SNR must be 2*Es/N0 to get N0/2 per dimension.
%   (pammod returns a complex-typed array; it is made real explicitly here.)

EbN0_dB = 0:2:20;
N_bits  = 2e5;                                         % >= 1e5 bits per point
families = {'pam', [2 4 8 16 32]; 'psk', [2 4 8 16 32]; 'qam', [4 16 64 256]; 'fsk', [2 4 8 16 32]};

f = figure('Visible', 'off', 'Position', [100 100 1100 800]);
for fam = 1:size(families, 1)
    name = families{fam, 1};
    subplot(2, 2, fam); hold on;
    for M = families{fam, 2}
        k = log2(M);
        ber = zeros(size(EbN0_dB));
        for i = 1:numel(EbN0_dB)
            ber(i) = simulate_ber(name, M, EbN0_dB(i), N_bits);
        end
        if strcmp(name, 'psk')
            theory = berawgn(EbN0_dB, 'psk', M, 'nondiff');
        elseif strcmp(name, 'fsk')
            theory = berawgn(EbN0_dB, 'fsk', M, 'coherent');
        else
            theory = berawgn(EbN0_dB, name, M);
        end
        h = semilogy(EbN0_dB, theory, '-', 'LineWidth', 1.2);
        semilogy(EbN0_dB, ber, 'o', 'Color', h.Color, 'LineWidth', 1.2, 'HandleVisibility', 'off');
        h.DisplayName = sprintf('%d-%s', M, upper(name));
    end
    set(gca, 'YScale', 'log'); grid on; ylim([1e-5 1]);
    xlabel('E_b/N_0 (dB)'); ylabel('BER');
    title(sprintf('M-%s  (lines: theory, markers: simulation)', upper(name)));
    legend('Location', 'southwest', 'FontSize', 7);
end
save_figure(f, 'q1_5_ber_all');

% Constellations at Eb/N0 = 10 dB, 1000 symbols
f = figure('Visible', 'off', 'Position', [100 100 1300 700]);
sets = {'pam', [2 4 8 16 32]; 'psk', [2 4 8 16 32]; 'qam', [4 16 64 256]};
for r = 1:3
    Ms = sets{r, 2};
    for c = 1:numel(Ms)
        M = Ms(c);
        [rx, ideal] = noisy_symbols(sets{r, 1}, M, 10, 1000);
        subplot(3, 5, (r-1)*5 + c);
        scatter(real(rx), imag(rx), 3, 'filled', 'MarkerFaceAlpha', 0.4); hold on;
        scatter(real(ideal), imag(ideal), 12, 'r', 'filled');
        axis equal; grid on;
        lim = 1.3*max(abs([real(ideal(:)); imag(ideal(:))])) + 0.5;
        axis([-lim lim -lim lim]);
        title(sprintf('%d-%s', M, upper(sets{r, 1})), 'FontSize', 8);
    end
end
save_figure(f, 'q1_5_constellations');


function ber = simulate_ber(name, M, EbN0_dB, N_bits)
    k = log2(M);
    n_sym = floor(N_bits / k);
    bits = randi([0 1], n_sym*k, 1);
    sym = bit2int(bits, k);
    EbN0 = 10^(EbN0_dB/10);
    switch name
        case 'pam'
            tx = real(pammod(sym, M, 0, 'gray'));                % pammod returns a complex type
            rx = awgn(tx, 10*log10(2*k*EbN0), 'measured');       % real signal
            det = pamdemod(rx, M, 0, 'gray');
        case 'psk'
            tx = pskmod(sym, M, 0, 'gray');
            rx = awgn(tx, 10*log10(k*EbN0), 'measured');
            det = pskdemod(rx, M, 0, 'gray');
        case 'qam'
            tx = qammod(sym, M, 'gray', 'UnitAveragePower', true);
            rx = awgn(tx, 10*log10(k*EbN0), 'measured');
            det = qamdemod(rx, M, 'gray', 'UnitAveragePower', true);
        case 'fsk'
            % coherent orthogonal M-FSK in signal space: one dimension per tone
            Es = 1; N0 = Es/(k*EbN0);
            y = sqrt(N0/2)*randn(n_sym, M);
            idx = sub2ind([n_sym M], (1:n_sym)', sym + 1);
            y(idx) = y(idx) + sqrt(Es);
            [~, det] = max(y, [], 2);
            det = det - 1;
    end
    ber = mean(int2bit(det, k) ~= bits);
end

function [rx, ideal] = noisy_symbols(name, M, EbN0_dB, n_sym)
    k = log2(M);
    sym = randi([0 M-1], n_sym, 1);
    switch name
        case 'pam'
            tx = real(pammod(sym, M, 0, 'gray'));  ideal = pammod(0:M-1, M, 0, 'gray');
            rx = awgn(tx, EbN0_dB + 10*log10(2*k), 'measured');
        case 'psk'
            tx = pskmod(sym, M, 0, 'gray');  ideal = pskmod(0:M-1, M, 0, 'gray');
            rx = awgn(tx, EbN0_dB + 10*log10(k), 'measured');
        case 'qam'
            tx = qammod(sym, M, 'UnitAveragePower', true);
            ideal = qammod(0:M-1, M, 'UnitAveragePower', true);
            rx = awgn(tx, EbN0_dB + 10*log10(k), 'measured');
    end
end
