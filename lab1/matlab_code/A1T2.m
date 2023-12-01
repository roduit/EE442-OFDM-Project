const_blue = [-6-6i, -3i, 3i, -3, 3, 6+6i];
const_red  = [-3-3i,-3+3i,3-3i,3+3i];
% Calculate here:



average_energy_blue = mean(abs(const_blue).^2)
 

average_energy_red = mean(abs(const_red).^2)

%normalized the constellation (we expect value with size(1, 6))
const_blue_norm = const_blue ./ sqrt(average_energy_blue);
    
const_red_norm = const_red ./ sqrt(average_energy_red);
%plot normalized constellations

% Separate real and imaginary components
real_blue = real(const_blue_norm);
imag_blue = imag(const_blue_norm);

real_red = real(const_red_norm);
imag_red = imag(const_red_norm);

% Create a figure
figure;

% Plot const_blue as dots
scatter(real_blue, imag_blue, 'b', 'filled');
hold on;

% Plot const_red as dots
scatter(real_red, imag_red, 'r', 'filled');

% Set axis labels and title
xlabel('Real');
ylabel('Imaginary');
title('Constellation Diagram for ');

% Add a legend
legend('const\_blue', 'const\_red');

% Display the plot
grid on;

% 3.2 observations
%