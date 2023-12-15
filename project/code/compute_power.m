function [signal_power] = compute_power(signal)

    signal_power = mean(abs(signal).^2);

end

