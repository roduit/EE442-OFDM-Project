% Generate random bitstream
bitstream_length = 100; % Specify the length of the bitstream
bitstream = randi([0, 1], bitstream_length, 1); % Generate random bits (0 or 1)

% Display the generated bitstream
bpsk_bitstream = bit2qpsk(bitstream);
bit_recovered = qpsk2bit(bpsk_bitstream);

disp(sum(bitstream ~= bit_recovered));
