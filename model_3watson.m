function [f_fn h_fn] = model_3watson(u)
  f_fn = @model_3watson_f; % identity, but fix up state
  h_fn = @(X) model_3watson_h(X,u);
end
