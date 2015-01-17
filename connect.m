function F = connect(f)
  % odds stay the same, evens get reversed and prepended
  F = map(@(o,e) [e(:,end:-1:2) o], f(1:2:end), f(2:2:end));
end
