% preamble_gen generates a preamble sequence based on a given polynomial.
% The preamble sequence is generated using a linear feedback shift register (LFSR) algorithm.
%
% Inputs:
%   - preamble_length: the length of the preamble sequence to generate
%
% Output:
%   - preamble: the generated preamble sequence
%
% Example usage:
%   preamble = preamble_gen(10);
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [preamble] = preamble_gen(preamble_length)
    % Polynomial used for the LFSR algorithm
    polynomial = [1 0 1 1 1 0 0 0]';

    % All memories are initialized with ones
    state = ones(size(polynomial));

    % Initialize the preamble sequence
    preamble = zeros(preamble_length, 1);

    % Generate the preamble sequence
    for i = 1:preamble_length
        preamble(i) = state(1);
        feedback = mod(sum(state .* polynomial), 2);
        state = circshift(state, -1);
        state(end) = feedback;
    end
end

