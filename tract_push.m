function q = tract_push(q, p)
  inc = 30;
  if q.cur == size(q.list,2)
    q.list(numel(p),q.cur + inc) = 0; % expand
  end
  q.cur = q.cur + 1;
  q.list(:,q.cur) = p;
end
