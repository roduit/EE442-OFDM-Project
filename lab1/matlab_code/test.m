function output = test(input)
    output = zeros(size(input, 1), 2);
    input = input .* sqrt(2)
    for ii = 1:size(input, 1)
        point = input(ii);
        
        % Define the reference points
        ref_points = [(1 + 1i), (1 - 1i), (-1 - 1i), (-1 + 1i)];
        
        % Calculate distances to reference points
        distances = abs(point - ref_points)
        
        % Find the index of the closest reference point
        [~, closest_index] = min(distances);
        
        % Determine the output based on the closest reference point
        switch closest_index
            case 1
                output(ii,:) = [1,1] ;
            case 2
                output(ii,:) = [1,0] ;
            case 3
                output(ii,:) = [0,0] ;
            case 4
                output(ii,:) = [0,1] ;
        end
    end
end
