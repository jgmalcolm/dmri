function ga = signal2ga(S)
% generalized anisotropy
  rms = sqrt(mean(S.^2, ndims(S)));
  ga = std(S, 0, ndims(S)) ./ (rms + eps);
end
