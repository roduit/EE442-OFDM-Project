function [qpsk_symbols] = bit2qpsk(bitstream)
%BIT2QPSK Summary of this function goes here
%   Detailed explanation goes here
    GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
    reshaped_bitstream = reshape(bitstream, 2, length(bitstream)/2)';
    qpsk_symbols = GrayMap(bi2de(reshaped_bitstream, 'left-msb')+1).';
end

