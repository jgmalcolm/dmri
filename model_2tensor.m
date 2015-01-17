function [f_fn h_fn] = model_2tensor(u, b)
  f_fn = @model_2tensor_f; % identity, but fix up state
  h_fn = @(X) model_2tensor_h(X,u,b);
end
