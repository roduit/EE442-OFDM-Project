function [txsignal_rf] = tx(tx_bitstream, conf)
% tx_bitstream: bitstream to be transmitted
% tx_signal: signal to be transmitted

    % Generate preamble
    preamble = preamble_gen(conf.preamble_length);

    % Convert preamble to BPSK
    preamble_bpsk = bit2bpsk(preamble);

    % Upsample preamble
    preamble_up = upsample(preamble_bpsk, conf.os_factor_preamb);

    % Pulse shape for preamble
    preamble_shaped = matched_filter(preamble_up, conf.os_factor_preamb, conf.matched_filter_length_tx, conf);
    
    %Normalize the preamble
    preamble_shaped = preamble_shaped / rms(preamble_shaped);
  
    % Generate training sequence
    training_seq = preamble_gen(conf.symb_per_packet);

    % Convert training sequence to BPSK
    training_seq_bpsk = bit2bpsk(training_seq);

    % Convert bitstream to QPSK
    bitstream_qpsk = bit2qpsk(tx_bitstream);

    % Concatenate training sequence and bitstream
    tx_qpsk = vertcat(training_seq_bpsk, bitstream_qpsk);

    % Serial to parallel conversion
    tx_parallel_qpsk = series2parallel(tx_qpsk, conf.symb_per_packet);

    % for -> ifft, cp, parallel2series
    % concatenate the series signals
    tx_signal = zeros(conf.cp_length+conf.symb_per_packet*conf.os_factor_ofdm,conf.nb_packets+1);
    for ii=1:conf.nb_packets+1
        frame = tx_parallel_qpsk(:,ii);
        frame_ifft = osifft(frame, conf.os_factor_ofdm);
        frame_cp = cyclic_prefix(frame_ifft, conf.cp_length);
        tx_signal(:,ii) = frame_cp;
    end

    % Parallel to serial conversion
    
    %tx_serial_qpsk = parallel2series(tx_signal);
    tx_serial_qpsk = tx_signal(:);
    % Normalize the signal
    tx_serial_qpsk = tx_serial_qpsk / rms(tx_serial_qpsk);

    tx_signal_down = vertcat(preamble_shaped, tx_serial_qpsk);

    %Up conversion
    time = 0:1/conf.sampling_freq:(length(tx_signal_down)/conf.sampling_freq)-1/conf.sampling_freq;
    txsignal = real(tx_signal_down) .* cos(2*pi*conf.carrier_freq*time)' - imag(tx_signal_down) .* sin(2*pi*conf.carrier_freq*time)';
    % Calculate the RMS value
    rms_value = rms(txsignal);

    % Normalize the signal
    txsignal_rf = txsignal / rms_value;

end

