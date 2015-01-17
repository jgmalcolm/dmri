function ff = fiber_1t(S, is_cross, u, b)
  
  S = reshape(S, [], size(S,3));
  S = S(is_cross,:);
  
  D = direct_1T(u, b, S');
  
  ff = {D};
end
