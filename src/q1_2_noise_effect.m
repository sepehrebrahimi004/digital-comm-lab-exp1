%Q1_2  Effect of the noise variance on binary orthogonal signaling (Eb = 1).

N_bits   = 100;
variance = [0.1 0.3 0.5];
bits = rand(1, N_bits) > 0.5;
m0 = double(~bits);                    % sqrt(Eb) on branch 0 when bit = 0
m1 = double(bits);                     % sqrt(Eb) on branch 1 when bit = 1

f1 = figure('Visible', 'off', 'Position', [100 100 900 700]);
f2 = figure('Visible', 'off', 'Position', [100 100 1100 360]);
for k = 1:numel(variance)
    s  = sqrt(variance(k));
    y0 = m0 + s*randn(1, N_bits);
    y1 = m1 + s*randn(1, N_bits);
    errors = sum((y1 > y0) ~= bits);
    pe = qfunc(1/sqrt(2*variance(k)));          % y1 - y0 ~ N(+-1, 2 sigma^2)

    figure(f1); subplot(3, 1, k);
    stem(find(~bits), y0(~bits), 'filled', 'MarkerSize', 3); hold on;
    stem(find(bits),  y1(bits),  'filled', 'MarkerSize', 3);
    plot(find(~bits), y1(~bits), 'x', 'Color', [0.5 0.5 0.5]);
    plot(find(bits),  y0(bits),  'x', 'Color', [0.5 0.5 0.5]);
    yline(0.5, ':k');
    title(sprintf('\\sigma^2 = %.1f: %d / %d bit errors (theory P_e = %.3f)', ...
          variance(k), errors, N_bits, pe));
    ylabel('output'); grid on;
    if k == 1
        legend('y_0 (bit 0 sent)', 'y_1 (bit 1 sent)', 'other branch', 'Location', 'eastoutside');
    end

    figure(f2); subplot(1, 3, k);
    scatter(y0(~bits), y1(~bits), 14, 'filled'); hold on;
    scatter(y0(bits),  y1(bits),  14, 'filled');
    plot([-2 3], [-2 3], 'k--');
    axis equal; xlim([-1.5 2.5]); ylim([-1.5 2.5]); grid on;
    xlabel('y_0'); ylabel('y_1');
    title(sprintf('\\sigma^2 = %.1f', variance(k)));
end
figure(f1); xlabel('bit index');
figure(f2); legend('bit 0', 'bit 1', 'decision line y_1 = y_0', 'Location', 'southeast');
save_figure(f1, 'q1_2_outputs');
save_figure(f2, 'q1_2_signal_space');
