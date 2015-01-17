function n = count_branches(fibers, param)
  n = cellfun(@(f) count(f,param), fibers);
end


function n = count(X, param)
  n = 0;
  if size(X,2) < 2, return, end
  for X = X(4:end,2:end)
    [m1 l1 w1 m2 l2 w2] = state2tensorW(X);
    is_two = l1(1) > l1(2) && l2(1) > l2(2);
    is_two = is_two && l2fa(l1) > param.FA_min && l2fa(l2) > param.FA_min;
    is_two = is_two && w1 > param.w_min && w2 > param.w_min;
    th = abs(m1'*m2);
    is_branching = th < param.theta_min && th > param.theta_max;
    if is_two && is_branching
      n = n + 1;
    end     
  end
end
