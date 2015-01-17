function ff = fiber_lm(S, is_cross, est, param)
  if islogical(is_cross)
    [X(1,:) X(2,:)] = find(is_cross);
    S = reshape(S, [], size(S,3)); % collapse first two dimensions
    S = S(is_cross,:)';  % columns == signals
  else
    X = is_cross;
    for i = 1:size(X,2)
      S_(:,i) = interp2exp(S, X(:,i));
    end
    S = S_;
  end

  n = size(S,2);
  for i = 1:n
    ff(:,i) = est(S(:,i));
    if ~param.display, fprintf('.'), end
  end
  ff = {ff};
end
