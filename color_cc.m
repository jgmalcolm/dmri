function img = color_cc(mask, xx, cc, k)
% k -- search window (try: k=20 or k=100 ...)
  img = zeros(size(mask));
  
  for i = find(mask)'
    [x y z] = ind2sub(size(mask), i);
    c = find_class([x y z], xx, cc, k);
    img(i) = c;
  end
  
end


function c = find_class(x, ff, cc, k)
  d = cellfun(@(y) min((y(1,:)-x(1)).^2 + ...
                       (y(2,:)-x(2)).^2 + ...
                       (y(3,:)-x(3)).^2), ff);
  [d ind] = sort(d);
  ind = ind(1:min(k,end));
  c = mode(cc(ind));
end
