function [beginning_of_data] = frame_sync(rx_signal, conf)

    % Frame synchronizer.
    % rx_signal is the noisy received signal, and conf.os_factor_preamb is the oversampling factor (conf.os_factor_preamb=1 in chapter 2, conf.os_factor_preamb=4 in all later chapters).
    % The returned value is the index of the first data symbol in rx_signal.
    
    % if (rx_signal(1) == 0)
    %     warning('Signal seems to be noise-free. The frame synchronizer will not work in this case.');
    % 
    % end
    
    detection_threshold = 15;
    
    % Calculate the frame synchronization sequence and map it to BPSK: 0 -> +1, 1 -> -1
    frame_sync_sequence = bit2bpsk(preamble_gen(conf.preamble_length));
    
    % When processing an oversampled signal (conf.os_factor_preamb>1), the following is important:
    % Do not simply return the index where T exceeds the threshold for the first time. Since the signal is oversampled, so will be the
    % peak in the correlator output. So once we have detected a peak, we keep on processing the next conf.os_factor_preamb samples and return the index
    % where the test statistic takes on the maximum value.
    % The following two variables exist for exactly this purpose.
    current_peak_value = 0;
    samples_after_threshold = conf.os_factor_preamb;
    
    for i = conf.os_factor_preamb * conf.preamble_length + 1 : length(rx_signal)
        r = rx_signal(i - conf.os_factor_preamb * conf.preamble_length : conf.os_factor_preamb : i - conf.os_factor_preamb); % The part of the received signal that is currently inside the correlator.
        c = frame_sync_sequence' * r;
        T = abs(c)^2 / abs(r' * r);
        
        if (T > detection_threshold || samples_after_threshold < conf.os_factor_preamb)
            samples_after_threshold = samples_after_threshold - 1;
            if (T > current_peak_value)
                beginning_of_data = i;
                
                current_peak_value = T;
            end
            if (samples_after_threshold == 0)
                return;
            end
        end
        
    end
    
    error('No synchronization sequence found.');

return