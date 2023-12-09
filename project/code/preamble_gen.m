function [preamble] = preamble_gen(preamble_length)
%PREAMBLE_GEN Summary of this function goes here
%   Detailed explanation goes here
polynomial = [1 0 1 1 1 0 0 0]';

% All memories are initialized with ones
state = ones(size(polynomial));

preamble = zeros(preamble_length, 1);

for i = 1:preamble_length
    preamble(i) = state(1);
    feedback = mod(sum(state .* polynomial), 2);
    state = circshift(state, -1);
    state(end) = feedback;
end

preamble = bit2bpsk(preamble);

end

