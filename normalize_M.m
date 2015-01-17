function data = normalize_M(data)
  data = arrayfun(@norm, data);
end


function d = norm(d)
  m = sqrt(sum(d.M.^2,3));
  d.M = d.M ./ repmat(m + eps,[1 1 3 1]);
end
