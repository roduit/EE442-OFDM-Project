function [bitstream] = bpsk2bit(bpsk_symbols)
%BPSK2BIT Summary of this function goes here
%   Detailed explanation goes here
    bitstream = bpsk_symbols > 0;
    bitstream = double(bitstream);
end

