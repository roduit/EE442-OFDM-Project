function [c, c_norm] = correlator(p,r)
    % Input:  p: preamble (shape = (Np, 1)), r: received signal (shape = (Nr, 1))
    % output: c: correlated signal (shape = (Nr-Np+1, 1)), c_norm: normalized correlated signal (shape = (Nr-Np+1, 1))
    Np = size(p,1);
    Nr = size(r,1);
    c = zeros(Nr-Np+1, 1);
    c_norm = zeros(Nr-Np+1, 1);
    %% TODO:
    p_conj = conj(p);
    for i = 1:Nr-Np+1
        c(i) = dot(p_conj,r(i:i+Np-1));
        c_norm(i) = abs(c(i))^2 / sum(abs(r(i:i+Np-1)).^2);
    end
end



