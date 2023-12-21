function [rx_bitstream, channel_across_frames, channel_across_frames_time] = rx(rx_signal, conf)
    % rx(rx_signal, conf) performs the receiver processing for a wireless communication system.
    % 
    % Inputs:
    %   - rx_signal: received signal
    %   - conf: configuration struct containing the following fields:
    %       - symb_per_packet: number of symbols per packet
    %       - os_factor_ofdm: oversampling factor for OFDM
    %       - cp_length: length of cyclic prefix
    %       - sampling_freq: sampling frequency
    %       - carrier_freq: carrier frequency
    %       - os_factor_preamb: oversampling factor for preamble
    %       - matched_filter_length_rx: length of matched filter for receiver
    %       - nb_frames: number of frames
    %       - bits_per_packet: number of bits per packet
    %       - nb_packets: number of packets
    %
    % Output:
    %   - rx_bitstream: received bitstream
    %
    % Author(s):    [Vincent Roduit, Filippo Quadri]
    % Date:         [2023-12-05]
    % Version:      [2.6]

    training_seq = preamble_gen(conf.nb_carriers);
    training_seq = bit2bpsk(training_seq);

    os_training_length = conf.nb_carriers * conf.os_factor_ofdm + conf.cp_length;

    % Down-conversion
    time = 0:1/conf.sampling_freq:(length(rx_signal)/conf.sampling_freq)-1/conf.sampling_freq;
    r_dc = rx_signal .* exp(-1j*2*pi*conf.carrier_freq*time');

    % Low-pass filtering
    rx_signal = 2 * ofdmlowpass(r_dc,conf, 1.5*conf.BW);
    
    % Apply MF
    rx_signal_MF = matched_filter(rx_signal, conf.os_factor_preamb, conf.matched_filter_length_rx, conf);
    
    start_index = 1;

    rx_bitstream = zeros(conf.bits_per_ofdm_sym * conf.ofdm_sym_per_frame, conf.nb_frames);

    % Channel over time
    channel_across_frames = zeros(conf.nb_carriers, conf.nb_frames);
    channel_across_frames_time = zeros(conf.nb_carriers, conf.nb_frames);

    for ii=1:conf.nb_frames
        rx_slice_MF = rx_signal_MF(start_index:end);
        rx_slice = rx_signal(start_index:end);

        % Frame synchronization
        beginning_of_data = frame_sync(rx_slice_MF, conf);
        
        % Add this line to have a little bit of phase shift
        beginning_of_data = beginning_of_data - 1;

        % Extract the frame from received signal
        rx_slice_MF = rx_slice(beginning_of_data : beginning_of_data + os_training_length + conf.ofdm_sym_per_frame * (conf.nb_carriers * conf.os_factor_ofdm + conf.cp_length) - 1);

        rx_symbols = zeros(conf.nb_carriers, conf.ofdm_sym_per_frame + 1);

        rx_signal_ofdm = series2parallel(rx_slice_MF, conf.nb_carriers * conf.os_factor_ofdm + conf.cp_length);
        rx_signal_ofdm = rx_signal_ofdm(1 + conf.cp_length:end, :);

        for jj = 1:conf.ofdm_sym_per_frame + 1
            rx_fft = osfft(rx_signal_ofdm(:, jj), conf.os_factor_ofdm);
            rx_symbols(:, jj) = rx_fft;
        end
        
        % figure;
        % plot(rx_symbols, '.');
        % xlabel("Real Part");
        % ylabel("Imaginary part");
        % title("OFDM Symbols before equalization");
        
        % Extract the training sequence
        rx_training_sequence = rx_symbols(:, 1);
    
        % Extract the data symbol sequence
        rx_data = rx_symbols(:, 2:end);
        
        % Estimate the channel
        channel = rx_training_sequence ./ training_seq;
        channel_phase_est = zeros(size(rx_symbols));

        channel_phase_est(:, 1) = mod(angle(channel), 2*pi);
        channel_mag_est = abs(channel);

        % Store the current channel
        channel_across_frames(:, ii) = channel;
        channel_across_frames_time(:, ii) = ifftshift(ifft(channel));
    
        % Compute Viterbi-Viterbi algorithm
        for k = 1:conf.ofdm_sym_per_frame
            deltaTheta = 1/4 * angle(-rx_data(:, k).^4) + pi/2 * (-1:4);
            [~, ind] = min(abs(deltaTheta - channel_phase_est(:, k)), [], 2);
            linearInd = sub2ind(size(deltaTheta), (1:size(deltaTheta, 1))', ind);
            theta = deltaTheta(linearInd);
            channel_phase_est(:, k+1) = mod(0.01 * theta + 0.99 * channel_phase_est(:, k), 2*pi);
            %channel_phase_est(:, k+1) = channel_phase_est(:, 1);
        end
        
        rx_data = (rx_data ./ channel_mag_est) .* exp(-1j .* channel_phase_est(:, 2:end));
        rx_bitstream(:,ii) = qpsk2bit(rx_data(:));

        start_index = start_index + beginning_of_data + (conf.nb_carriers * conf.os_factor_ofdm + conf.cp_length) * (conf.ofdm_sym_per_frame + 1);
    end


    figure;
    plot(abs(channel_across_frames_time(:, 1)).^2)
    xlabel("Time")
    ylabel("Magnitude");
    title("Fading Channel");
    
    % Plot the channel informations
    frequencies = conf.carrier_freq - conf.BW / 2 : conf.spacing_freq : conf.carrier_freq + conf.BW / 2 - conf.spacing_freq;
    figure;
    plot(frequencies, 20 * log10(abs(channel_across_frames)));
    xlabel("Frequency [Hz]");
    ylabel("Magnitude [dB]");
    title("Channel Magnitude");

    figure;
    plot(frequencies, unwrap(angle(channel_across_frames)) * 180 / pi);
    xlabel("Frequency [Hz]")
    ylabel("Phase [°]");
    title("Channel Phase");

    % Plot the constellation
    figure;
    plot(rx_data, 'o');
    title("Constellation Points at RX") 


end
    
    