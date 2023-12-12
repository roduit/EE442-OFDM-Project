function [txsignal_rf] = tx(tx_bitstream, conf)
% tx_bitstream: bitstream to be transmitted
% tx_signal: signal to be transmitted
    row_dimension = conf.preamble_length * conf.os_factor_preamb + (conf.symb_per_packet * conf.os_factor_ofdm + conf.cp_length) * (conf.packet_per_frame + 1) + conf.frame_gap;
    tot_signal = zeros(row_dimension,conf.nb_frames);
    % Generate preamble
    for ii=1:conf.nb_frames
        preamble = preamble_gen(conf.preamble_length);
    
        % Convert preamble to BPSK
        preamble_bpsk = bit2bpsk(preamble);
    
        % Upsample preamble
        preamble_up = upsample(preamble_bpsk, conf.os_factor_preamb);
    
        % Pulse shape for preamble
        preamble_shaped = matched_filter(preamble_up, conf.os_factor_preamb, conf.matched_filter_length_tx, conf);
    
        %preamble_shaped = preamble_shaped(1 + conf.matched_filter_length_tx : end - conf.matched_filter_length_tx);
        
        %Normalize the preamble
        preamble_shaped = preamble_shaped / rms(preamble_shaped);
      
        % Generate training sequence
        training_seq = preamble_gen(conf.symb_per_packet);
    
        % Convert training sequence to BPSK
        training_seq_bpsk = bit2bpsk(training_seq);

        % Convert bitstream to QPSK
        bitstream_seq = tx_bitstream(:,ii);
        bitstream_qpsk = bit2qpsk(bitstream_seq);

        % Concatenate training sequence and bitstream
        tx_qpsk = vertcat(training_seq_bpsk, bitstream_qpsk);

        % Serial to parallel conversion
        tx_parallel_qpsk = series2parallel(tx_qpsk, conf.symb_per_packet);

        % Concatenate the series signals
        tx_signal = zeros(conf.cp_length + conf.symb_per_packet * conf.os_factor_ofdm, conf.nb_packets + 1);
        for jj=1:conf.nb_packets+1
            frame = tx_parallel_qpsk(:,jj);
            frame_ifft = osifft(frame, conf.os_factor_ofdm);
            frame_cp = cyclic_prefix(frame_ifft, conf.cp_length);
            tx_signal(:,jj) = frame_cp;
        end

        % Parallel to serial conversion
        
        %tx_serial_qpsk = parallel2series(tx_signal);
        tx_serial_qpsk = tx_signal(:);
        % Normalize the signal
        tx_serial_qpsk = tx_serial_qpsk / rms(tx_serial_qpsk);
    
        tx_signal_down = vertcat(preamble_shaped, tx_serial_qpsk, zeros(conf.frame_gap,1));
        tot_signal(:,ii) = tx_signal_down;
    end

    %Up conversion
    tx_signal = tot_signal(:);
    time = 0:1/conf.sampling_freq:(length(tx_signal)/conf.sampling_freq)-1/conf.sampling_freq;
    txsignal = real(tx_signal) .* cos(2*pi*conf.carrier_freq*time)' - imag(tx_signal) .* sin(2*pi*conf.carrier_freq*time)';
    
    % Calculate the RMS value
    rms_value = rms(txsignal);

    % Normalize the signal
    txsignal_rf = txsignal / rms_value;
    %txsignal_rf = tx_signal_down;

end