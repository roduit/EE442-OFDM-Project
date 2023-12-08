function [rx_bitstream] = rx(rx_signal, conf)
    % rx_signal: received signal
    % conf: configuration struct

    % For now we ignore the premable and the training sequence
    os_pream_length = conf.preamble_length*conf.os_factor_preamb + 2*conf.matched_filter_length_tx;

    os_training_length = conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length;

    % Down-conversion
    time = 0:1/conf.sampling_freq:(length(rx_signal)/conf.sampling_freq)-1/conf.sampling_freq;

    r_dc = rx_signal .* exp(-1j*2*pi*conf.carrier_freq*time');

    % Low-pass filtering
    rx_signal = 2 * ofdmlowpass(r_dc,conf,conf.sampling_freq);

    rx_signal = rx_signal(1 + os_pream_length + os_training_length:end);

    rx_symbols = zeros(conf.symb_per_packet,conf.packet_per_frame);
    data_augmented_length = conf.symb_per_packet * conf.os_factor_ofdm;
    for ii = 1:conf.packet_per_frame
        start_idx = (ii - 1) * data_augmented_length + conf.cp_length;
        rx_signal_filtered = rx_signal(1 + start_idx: start_idx + data_augmented_length);
        rx_fft = osfft(rx_signal_filtered,conf.os_factor_ofdm);
        rx_symbols(:, ii) = rx_fft;
    end
    rx_flatten = rx_symbols(:);
    rx_bitstream = qpsk2bit(rx_symbols(:));

end
    
    