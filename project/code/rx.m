function [rx_bitstream] = rx(rx_signal, conf)
    % rx_signal: received signal
    % conf: configuration struct

    % For now we ignore the premable and the training sequence
    % os_pream_length = conf.preamble_length*conf.os_factor_preamb + 2*conf.matched_filter_length_tx;

    os_training_length = conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length;

    % Down-conversion
    time = 0:1/conf.sampling_freq:(length(rx_signal)/conf.sampling_freq)-1/conf.sampling_freq;

    r_dc = rx_signal .* exp(-1j*2*pi*conf.carrier_freq*time');

    % Low-pass filtering
    rx_signal = 2 * ofdmlowpass(r_dc,conf,conf.sampling_freq);

    % Apply MF
    rx_signal_MF = matched_filter(rx_signal, conf.os_factor_preamb, conf.matched_filter_length_rx, conf);
    rx_signal_MF = rx_signal_MF(1 + conf.matched_filter_length_rx: end - conf.matched_filter_length_rx);

    beginning_of_data = frame_sync(rx_signal_MF, conf)

    rx_signal_MF = rx_signal_MF(beginning_of_data + os_training_length : beginning_of_data + os_training_length + conf.packet_per_frame * (conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length) - 1);

    rx_symbols = zeros(conf.symb_per_packet,conf.packet_per_frame);

    rx_signal_ofdm = series2parallel(rx_signal_MF, conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length);
    rx_signal_ofdm = rx_signal_ofdm(1 + conf.cp_length:end, :);

    for ii = 1:conf.packet_per_frame
        rx_fft = osfft(rx_signal_ofdm(:, ii), conf.os_factor_ofdm);
        rx_symbols(:, ii) = rx_fft;

    end

    rx_bitstream = qpsk2bit(rx_symbols(:));

end
    
    