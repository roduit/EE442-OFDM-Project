function [bit_out, noisy_signal] = awgn_channel(signal, image_size, SNR)
    
    % Convert SNR from dB to linear
    SNRlin = 10 ^ (SNR/10);
    
    % Add AWGN
    %noisy_signal = signal + 1/sqrt(2*SNRlin)*randn(size(signal))+1j*1/sqrt(2*SNRlin)*randn(size(signal));
    noise = 1/sqrt(2*SNRlin)*randn(size(signal));
    noisy_signal = signal + noise + 1j*noise ;
    % Demap
    bit_out = demapper(noisy_signal);
    
    % Decode and shown image
    image = image_decoder(bit_out, image_size);
    
end
