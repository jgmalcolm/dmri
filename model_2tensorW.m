function [f_fn h_fn] = model_2tensorW(u, b)
  f_fn = @model_2tensorW_f; % identity, but fix up state
  h_fn = @(X) model_2tensorW_h(X,u,b);
end
