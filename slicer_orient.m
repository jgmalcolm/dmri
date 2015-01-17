function ho = slicer_orient(h, m)
  [xx yy zz] = ind2sub(size(m), find(m));
  D = cov([xx yy zz]);
  [U V] = svd(D);
  
  o = size(m)/2;
  
  fx = 30;
  X = cell(1, 3*4);
  c = 'rgb';
  for i = 1:3
    for j = 1:3
      X{4*(i-1)+j} = o(j) + [0 U(j,i)]*fx;
    end
    X{4*(i-1)+4} = c(i);
  end
  
  % swap X-Y for plot3
  for i = 1:3
    [X{4*(i-1)+1} X{4*(i-1)+2}] = deal(X{4*(i-1)+2}, X{4*(i-1)+1});
  end

  hold(h,'on');
  ho = plot3(h, X{:});
  hold(h,'off');
end
