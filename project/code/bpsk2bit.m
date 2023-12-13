%BPSK2BIT Converts BPSK symbols to bitstream
%   This function takes a vector of BPSK symbols and converts them to a
%   bitstream by comparing each symbol to zero. Symbols greater than zero
%   are considered as 1, while symbols less than or equal to zero are
%   considered as 0.
%
%   Inputs:
%   - bpsk_symbols: A vector of BPSK symbols
%
%   Output:
%   - bitstream: The resulting bitstream
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [bitstream] = bpsk2bit(bpsk_symbols)

    bitstream = bpsk_symbols > 0;
    bitstream = double(bitstream);
end