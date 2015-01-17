function [f_fn h_fn] = model_3tw(u, b)
  f_fn = @model_3tw_f; % identity, but fix up state
  h_fn = @(X) model_3tw_h(X,u,b);
end
