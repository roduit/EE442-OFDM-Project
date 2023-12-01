function [bitstream] = qpsk2bit(qpsk_symbols)
%QPSK2BIT Summary of this function goes here
%   Detailed explanation goes here
    bit1 = real(qpsk_symbols) > 0;
    bit2 = imag(qpsk_symbols) > 0;

    % b is a two colomn vector col1: real, col2: imag
    bitstream = [bit1 bit2];
    bitstream = bitstream';
    bitstream = bitstream(:);
end

