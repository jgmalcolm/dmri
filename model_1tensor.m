function [f_fn h_fn] = model_1tensor(u, b)
  f_fn = @model_1tensor_f; % identity, but fix up state
  h_fn = @(X) model_1tensor_h(X,u,b);
end
