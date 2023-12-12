function [bpsk_symbols] = bit2bpsk(bitstream)
%BIT2BPSK Summary of this function goes here
%   Detailed explanation goes here
    bpsk_symbols = bitstream .* 2 - 1;
end

