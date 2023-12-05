function [rx_bitstream] = rx(rx_signal, conf)
    % rx_signal: received signal
    % conf: configuration struct

    % For now we ignore the premable and the training sequence
    os_pream_length = conf.preamble_length*conf.os_factor_preamb + 2*conf.matched_filter_length_tx;

    os_training_length = conf.bit_per_packet * conf.os_factor_ofdm + conf.cp_length;

    time = 0:1/conf.sampling_freq:(length(rx_signal)/conf.sampling_freq)-1/conf.sampling_freq;

    r_dc = rx_signal .* exp(-1j*2*pi*conf.carrier_freq*time');

    rx_signal = 2 * ofdmlowpass(r_dc,conf,conf.sampling_freq);

    rx_signal = rx_signal(1 + os_pream_length + os_training_length + conf.cp_length:end);
    
    rx_fft = osfft(rx_signal,conf.os_factor_ofdm);

    rx_bitstream = qpsk2bit(rx_fft);

    
    end
    
    