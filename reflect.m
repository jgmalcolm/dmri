function xx = reflect(xx, ref)
  xx = map(@(x) [abs(x(1,:)-ref)+ref;x(2:3,:)], xx);
end
