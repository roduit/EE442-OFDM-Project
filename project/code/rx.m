function [rx_bitstream] = rx(rx_signal, conf)
    % rx_signal: received signal
    % conf: configuration struct

    training_seq = preamble_gen(conf.symb_per_packet);
    training_seq = bit2bpsk(training_seq);

    os_training_length = conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length;

    % Down-conversion
    time = 0:1/conf.sampling_freq:(length(rx_signal)/conf.sampling_freq)-1/conf.sampling_freq;
    r_dc = rx_signal .* exp(-1j*2*pi*conf.carrier_freq*time');

    % Low-pass filtering
    rx_signal = 2 * ofdmlowpass(r_dc,conf,conf.BW * 2);

    % Apply MF
    rx_signal_MF = matched_filter(rx_signal, conf.os_factor_preamb, conf.matched_filter_length_rx, conf);

    beginning_of_data = frame_sync(rx_signal_MF, conf);

    rx_signal_MF = rx_signal(beginning_of_data : beginning_of_data + os_training_length + conf.packet_per_frame * (conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length) - 1);

    rx_symbols = zeros(conf.symb_per_packet,conf.packet_per_frame + 1);

    rx_signal_ofdm = series2parallel(rx_signal_MF, conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length);
    rx_signal_ofdm = rx_signal_ofdm(1 + conf.cp_length:end, :);

    for ii = 1:conf.packet_per_frame + 1
        rx_fft = osfft(rx_signal_ofdm(:, ii), conf.os_factor_ofdm);
        rx_symbols(:, ii) = rx_fft;

    end
    
    % Extract the training sequence and compute the phase tracking
    rx_training_sequence = rx_symbols(:, 1);
    phase_estimation = mod(angle(rx_training_sequence ./ training_seq), 2*pi);
    magnitude_estimation = abs(rx_training_sequence ./ training_seq);

    training_seq_corrected = rx_training_sequence ./ magnitude_estimation .* exp(-1j*phase_estimation);

    
    % Extract the data symbol sequence and compute the bitstream
    rx_symbols_true = rx_symbols(:, 2:end);
    rx_bitstream = qpsk2bit(rx_symbols_true(:));

end
    
    