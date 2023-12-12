function [bitstream] = image2bitstream(conf, image)
    % Reshape the image matrix to a column vector
    image_vector = reshape(image, [], 1);
    
    % Convert the values to a binary representation
    binary_stream = de2bi(image_vector,"left-msb")';
    binary_stream = binary_stream(:);
    % Reshape the binary stream to a column vector% Determine the number of rows needed for 16 columns
    num_rows = numel(binary_stream) / conf.nb_frames;
    
    % Reshape the binary stream to have 16 columns
    bitstream = reshape(binary_stream, num_rows, conf.nb_frames);
end
