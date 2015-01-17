function [f_fn h_fn] = model_3tensor(u, b)
  f_fn = @model_3tensor_f; % identity, but fix up state
  h_fn = @(X) model_3tensor_h(X,u,b);
end
