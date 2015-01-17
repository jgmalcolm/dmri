function e = mse_error(fibers, S, u, b, signals)
  if exist('signals')
    fn = @(f,S_) signal2e(f,S,S_);
    args = {fibers signals};
  else
    fn = @(f) state2e(f,S,u,b);
    args = {fibers};
  end
  e = cellfun(fn, args{:}, 'Un', false);
  e = [e{:}];
end

function e = signal2e(f, S, S_)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(1,n);
  for i = 1:n
    s  = interp2exp(S, f(1:2,i));
    s_ = S_(:,i);
    %s = s / norm(s); s_ = s_ / norm(s_);
    e(i) = (norm(s - s_)/norm(s))^2;
  end
end

function e = state2e(f, S, u, b)
  if isempty(f), e = []; return; end
  n = size(f,2);
  e = zeros(1,n);
  for i = 1:n
    x = f(1:2,i);
    X = f(3:end,i);
    s  = interp2exp(S, x);
    %s_ = model_2tensorW_h(X, u, b);
    s_ = model_2tensor_h(X, u, b);
    %s_ = model_2watson_h(X, u); s = s / norm(s);
    e(i) = (norm(s - s_)/norm(s))^2;
  end
end
