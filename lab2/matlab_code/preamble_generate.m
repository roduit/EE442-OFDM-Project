function preamble = preamble_generate(length)
    % preamble_generate()
    % input: desired_length - a scalar value, desired length of preamble.
    % output: preamble - preamble bits
    preamble = zeros(length, 1);
    lfsr_array = ones(8,1);
    for i = 1:length
        newValue = xor(xor(xor(lfsr_array(8), lfsr_array(6)), lfsr_array(5)), lfsr_array(4));
        lfsr_array(end) = newValue;
        lfsr_array = circshift(lfsr_array,1);
        preamble(i) = lfsr_array(end);
    end
end