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
    
    % Extract the training sequence
    rx_training_sequence = rx_symbols(:, 1);

    % Extract the data symbol sequence
    rx_data = rx_symbols(:, 2:end);
    
    % Estimate the channel
    channel = rx_training_sequence ./ training_seq;
    channel_phase_est = zeros(size(rx_symbols));
    channel_phase_est(:, 1) = mod(angle(channel), 2*pi);
    channel_mag_est = abs(channel);

    for k = 1:conf.nb_packets
        deltaTheta = 1/4.*angle(-rx_data(:, k).^4) + pi/2*(-1:4);
        [~, ind] = min(abs(deltaTheta - channel_phase_est(:, k)));
        theta = deltaTheta(ind);
        channel_phase_est(:, k+1) = mod(0.01*theta + 0.99*channel_phase_est(:, k), 2*pi);
    end
    
    
    rx_bitstream = qpsk2bit(rx_data(:));

end
    
    