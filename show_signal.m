function show_signal(S, u, fcs)
  cla
  [nx ny n] = size(S);
  
  if nargin == 2
    fcs = convhulln(u);
  end

  for x = 1:nx
    for y = 1:ny
      s = flat(S(x,y,:));
      odf(s, u, fcs, [x y 0]);
    end
  end
  axis ij image
  box on
  set(gca, 'YLim', [0 nx]+.5, 'XLim', [0 ny]+.5);
end
