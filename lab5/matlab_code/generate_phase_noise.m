function theta_n = generate_phase_noise(length_of_noise, sigmaDeltaTheta)
    % Create phase noise
    theta_n = zeros(length_of_noise, 1);
    %% TODO
    theta_n(1) = 2*pi*rand();
    for i = 2:length_of_noise
        theta_n(i) = mod(theta_n(i-1) + sigmaDeltaTheta * randn(), 2*pi);
    end
end
