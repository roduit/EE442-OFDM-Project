function [tx_signal] = tx(tx_bitstream, conf)
% tx_bitstream: bitstream to be transmitted
% tx_signal: signal to be transmitted

    % Generate preamble
    preamble = preamble_gen(conf.preamble_length);

    % Convert preamble to BPSK
    preamble_bpsk = bit2bpsk(preamble);

    % Generate training sequence
    training_seq = preamble_gen(conf.bit_per_packet);

    % Convert training sequence to BPSK
    training_seq_bpsk = bit2bpsk(training_seq);

    % Convert bitstream to QPSK
    bitstream_qpsk = bit2qpsk(tx_bitstream);

    tx_qpsk = vertcat(training_seq_bpsk, bitstream_qpsk);

    % Serial to parallel conversion
    tx_parallel_qpsk = series2parallel(tx_qpsk, conf.bit_per_packet);

    % Compute the IFFT of the parallel QPSK symbols
    tx_ifft_qpsk = osifft(tx_parallel_qpsk, conf.os_factor);

    % Add cyclic prefix
    tx_cp_qpsk = cyclic_prefix(tx_ifft_qpsk, conf.cp_length);

    % Parallel to serial conversion
    tx_serial_qpsk = parallel2series(tx_cp_qpsk);

    % TODO: - pulse shape for bpsk
    %       - convert to rf signal
    tx_signal = vertcat(preamble_bpsk, tx_serial_qpsk);



end

