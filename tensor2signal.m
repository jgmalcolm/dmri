function [S F M] = tensor2signal(D, u, b)

  n = size(D, 1);
  S = zeros(n, length(u));
  F = zeros(n, length(u));
  M = zeros(n, 3);
  
  for i = 1:n
    d = reshape(D(i,:), [3 3]);
    % ADC signal
    S(i,:) = exp(-b*sum((u * d) .* u, 2)); % S0=1
    % ODF
    f = sqrt((pi*b)./sum((u * inv(d)) .* u, 2));
    F(i,:) = f / sum(f);  % unit mass
    % principle diffusion
    [V U] = svd(d);
    M(i,:) = U(1)*V(:,1); % principle eigenvector
  end
end
