function [rx_bitstream] = rx(rx_signal, conf)
    % rx_signal: received signal
    % conf: configuration struct

    % Training sequence generation
    training_seq_bpsk = preamble_gen(conf.symb_per_packet);

    % For now we ignore the preamble and the training sequence
    os_training_length = conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length;

    % Down-conversion
    time = 0:1/conf.sampling_freq:(length(rx_signal)/conf.sampling_freq)-1/conf.sampling_freq;
    r_dc = rx_signal .* exp(-1j*2*pi*conf.carrier_freq*time');

    % Low-pass filtering
    rx_signal = 2 * ofdmlowpass(r_dc,conf,conf.BW * 1.5);

    % Apply MF to find the preamble
    rx_signal_MF = matched_filter(rx_signal, conf.os_factor_preamb, conf.matched_filter_length_rx, conf);

    % Find the first data sample
    beginning_of_data = frame_sync(rx_signal_MF, conf)
    

    % Data extraction and process
    rx_data = rx_signal(beginning_of_data + os_training_length : beginning_of_data + os_training_length + conf.packet_per_frame * (conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length) - 1);

    rx_symbols = zeros(conf.symb_per_packet,conf.packet_per_frame);

    rx_signal_ofdm = series2parallel(rx_data, conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length);
    rx_signal_ofdm = rx_signal_ofdm(1 + conf.cp_length:end, :);

    for ii = 1:conf.packet_per_frame
        rx_fft = osfft(rx_signal_ofdm(:, ii), conf.os_factor_ofdm);
        rx_symbols(:, ii) = rx_fft;

    end

    % Training sequence extraction and process
    % rx_training_symbols = rx_symbols(:, 1);
    % rx_training_bit = bpsk2bit(rx_training_symbols);
    

    rx_bitstream = qpsk2bit(rx_symbols(:));

end
    
    