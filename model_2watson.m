function [f_fn h_fn] = model_2watson(u)
  f_fn = @model_2watson_f; % identity, but fix up state
  h_fn = @(X) model_2watson_h(X,u);
end
