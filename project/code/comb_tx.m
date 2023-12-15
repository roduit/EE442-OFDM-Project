% tx - Transmits the given bitstream using the specified configuration parameters.
%
% Syntax:
%   [txsignal_rf] = tx(tx_bitstream, conf)
%
% Inputs:
%   - tx_bitstream: Bitstream to be transmitted.
%   - conf: Structure containing configuration parameters.
%
% Outputs:
%   - txsignal_rf: RF signal to be transmitted.
%
% Description:
%   This function generates the RF signal to be transmitted based on the given bitstream and configuration parameters.
%   It performs the following steps:
%   1. Generates the preamble and converts it to BPSK.
%   2. Upsamples the preamble and applies pulse shaping.
%   3. Generates the training sequence and converts it to BPSK.
%   4. Converts the bitstream to QPSK.
%   5. Concatenates the training sequence and bitstream.
%   6. Performs serial to parallel conversion.
%   7. Applies IFFT, cyclic prefix, and parallel to serial conversion to each frame.
%   8. Performs up conversion to RF frequency.
%   9. Normalizes the signal and calculates the RMS value.
%   10. Normalizes the signal by dividing it by the RMS value.
%
% Example:
%   conf.preamble_length = 64;
%   conf.os_factor_preamb = 4;
%   conf.nb_carriers = 10;
%   conf.os_factor_ofdm = 8;
%   conf.cp_length = 16;
%   conf.nb_frames = 5;
%   conf.ofdm_sym_per_frame = 4;
%   conf.frame_gap = 100;
%   conf.sampling_freq = 1e6;
%   conf.carrier_freq = 2e6;
%   tx_bitstream = randi([0, 1], conf.nb_carriers * conf.ofdm_sym_per_frame, conf.nb_frames);
%   txsignal_rf = tx(tx_bitstream, conf);
%
% See also: preamble_gen, bit2bpsk, upsample, matched_filter, bit2qpsk, series2parallel,
%           osifft, cyclic_prefix, parallel2series

function [txsignal_rf] = comb_tx(tx_bitstream, conf)
    row_dimension = conf.preamble_length * conf.os_factor_preamb + (conf.nb_carriers * conf.os_factor_ofdm + conf.cp_length) * (conf.ofdm_sym_per_frame + 1) + conf.frame_gap;
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
        training_seq = preamble_gen(conf.nb_carriers);
    
        % Convert training sequence to BPSK
        training_seq_bpsk = bit2bpsk(training_seq);

        % Convert bitstream to QPSK
        bitstream_seq = tx_bitstream(:,ii);
        bitstream_bpsk = bit2bpsk(bitstream_seq);

        % Concatenate training sequence and bitstream
        tx_bpsk = vertcat(training_seq_bpsk, bitstream_bpsk);

        % Serial to parallel conversion
        tx_parallel_qpsk = series2parallel(tx_bpsk, conf.nb_carriers);

        % Concatenate the series signals
        tx_signal = zeros(conf.cp_length + conf.nb_carriers * conf.os_factor_ofdm, conf.ofdm_sym_per_frame + 1);
        for jj=1:conf.ofdm_sym_per_frame+1
            frame = tx_parallel_qpsk(:,jj);
            frame_ifft = osifft(frame, conf.os_factor_ofdm);
            frame_cp = cyclic_prefix(frame_ifft, conf.cp_length);
            tx_signal(:,jj) = frame_cp;
        end

        % Parallel to serial conversion
        
        %tx_serial_qpsk = parallel2series(tx_signal);
        tx_serial_bpsk = tx_signal(:);
        % Normalize the signal
        tx_serial_bpsk = tx_serial_bpsk / rms(tx_serial_bpsk);
    
        tx_signal_down = vertcat(preamble_shaped, tx_serial_bpsk, zeros(conf.frame_gap,1));
        tot_signal(:,ii) = tx_signal_down;
    end

    %Up conversion
    tx_signal = tot_signal(:);
    time = 0:1/conf.sampling_freq:(length(tx_signal)/conf.sampling_freq)-1/conf.sampling_freq;
    txsignal = real(tx_signal) .* cos(2*pi*conf.carrier_freq*time)' - imag(tx_signal) .* sin(2*pi*conf.carrier_freq*time)';
    
    % Calculate the RMS value
    max_value = max(abs(txsignal));

    % Normalize the signal
    txsignal_rf = txsignal / max_value;
    %txsignal_rf = tx_signal_down;

end