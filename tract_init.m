function q = tract_init(p)
  q.cur = 0;
  q.list = single([]);
  if nargin
    q = tract_push(q, p);
  end
end
