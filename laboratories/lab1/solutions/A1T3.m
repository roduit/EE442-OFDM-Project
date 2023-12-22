SNR_range = -6:2:12;
L = 1e4;

rng(123)

% Initialize
BER_list_Gray = zeros(size(SNR_range));
BER_list_NonGray = zeros(size(SNR_range));
    
for ii = 1:numel(SNR_range) 
    % Convert SNR from dB to linear
    SNRlin = 10^(SNR_range(ii)/10);
    
    % Generate source bitstream
    source = randi([0 1],L,2);
       
    % Map input bitstream using Gray mapping
    mappedGray = mapGrayfunc(source);
    if ii == 1
        mappedGray_record = mappedGray;
    end
      
    % Add AWGN
    mappedGrayNoisy = add_awgn_solution(mappedGray, SNRlin);
        
    % Demap
    
    demappedGray = demapGrayfunc(mappedGrayNoisy);
    if ii == 1
        demappedGray_record = demappedGray;
        mappedGrayNoisy_record = mappedGrayNoisy;
    end
        
    % BER calculation for Gray mapping
    BER_list_Gray(ii) = mean(source(:) ~= demappedGray(:));
        
    % Map input bitstream using non-Gray mapping
    mappedNonGray = mapNonGrayfunc(source);
    if ii == 1
        mappedNonGray_record = mappedNonGray;
    end
          
          
    % Add AWGN
    mappedNonGrayNoisy = add_awgn_solution(mappedNonGray, SNRlin);
        
    % Demap
    
    demappedNonGray = demapNonGrayfunc(mappedNonGrayNoisy);
    if ii == 1
        demappedNonGray_record = demappedNonGray;
    end
        
    % BER calculation for Gray mapping
    BER_list_NonGray(ii) = mean(source(:) ~= demappedNonGray(:));
end


%% uncomment this part for plot
%% graphical ouput
figure;
semilogy(SNR_range, BER_list_Gray, 'bx-' ,'LineWidth',3)

hold on
semilogy(SNR_range, BER_list_NonGray, 'r*--','LineWidth',3);

xlabel('SNR (dB)')
ylabel('BER')
legend('Gray Mapping', 'Non-Gray Mapping')
grid on


%% Functions
% Map Gray Function
function output = mapGrayfunc(input)
    output = zeros(size(input,1),1);
    for i = 1:size(input, 1)
        if isequal(input(i,:), [0,0])
            output(i) = -1 - 1i;
        end
        if isequal(input(i,:), [0,1])
            output(i) = -1 + 1i;
        end
        if isequal(input(i,:), [1,0])
            output(i) = 1 - 1i;
        end
        if isequal(input(i,:), [1,1])
            output(i) = 1 + 1i;
        end
    end
    output = output ./sqrt(2);
end

% Map Non Gray Function
function output = mapNonGrayfunc(input)
    output = zeros(size(input,1),1);
    for i = 1:size(input, 1)
        if isequal(input(i,:), [0,0])
            output(i) = 1 - 1i;
        end
        if isequal(input(i,:), [0,1])
            output(i) = 1 + 1i;
        end
        if isequal(input(i,:), [1,0])
            output(i) = -1 + 1i;
        end
        if isequal(input(i,:), [1,1])
            output(i) = -1 - 1i;
        end
    end
    output = output ./sqrt(2);
end

% Demap Gray function
function output = demapGrayfunc(input)
    output = zeros(size(input, 1), 2);
    input = input .* sqrt(2);
    for ii = 1:size(input, 1)
        point = input(ii);
        
        % Define the reference points
        ref_points = [(1 + 1i), (1 - 1i), (-1 - 1i), (-1 + 1i)];
        
        % Calculate distances to reference points
        distances = abs(point - ref_points);
        
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
function output = demapNonGrayfunc(input)
    output = zeros(size(input, 1), 2);
    input = input .* sqrt(2);
    for ii = 1:size(input, 1)
        point = input(ii);
        
        % Define the reference points
        ref_points = [(1 + 1i), (1 - 1i), (-1 - 1i), (-1 + 1i)];
        
        % Calculate distances to reference points
        distances = abs(point - ref_points);
        
        % Find the index of the closest reference point
        [~, closest_index] = min(distances);
        
        % Determine the output based on the closest reference point
        switch closest_index
            case 1
                output(ii,:) = [0,1] ;
            case 2
                output(ii,:) = [0,0] ;
            case 3
                output(ii,:) = [1,1] ;
            case 4
                output(ii,:) = [1,0] ;
        end
    end
end
