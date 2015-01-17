function curv = FindCurvature(ff)
  
  if ff.cur < 3
    curv = 0;
    return;
  end
  
  a = ff.list(:,ff.cur-0);
  b = ff.list(:,ff.cur-1);
  c = ff.list(:,ff.cur-2);

  v2 = a - b;
  v1 = b - c;
  
  u2 = v2/norm(v2);
  u1 = v1/norm(v1);
  
  2*(u2-u1)/(norm(v2) + norm(v1));
  curv = (norm(2*(u2-u1)/(norm(v2)+norm(v1))));
  if isnan(curv)
    curv = 0;
  end
end
