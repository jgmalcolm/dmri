function ff = repackage(X, counts)
  ff = map(@unpack, X, counts);
end

function f = unpack(x, c)
  c_ = [0 cumsum(c)];
  idx = arrayfun(@colon, c_(1:end-1)+1, c_(2:end), 'Un', 0);
  f = map(@(i) x(:,i), idx);
end
