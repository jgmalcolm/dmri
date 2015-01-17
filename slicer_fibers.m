function h_ = slicer_fibers(ha, fibers, c)
  if nargin ~= 3, c = 'r'; end
  
  fibers = empty(fibers);

  % gather plot data
  n = numel(fibers);
  f_ = cell(1,4*n);
  [f_{4:4:end}] = deal(c);
  for i = 1:n
    f = fibers{i};
    f_{4*(i-1)+1} = f(2,:);
    f_{4*(i-1)+2} = f(1,:);
    f_{4*(i-1)+3} = f(3,:);
  end
  
  % plot
  hold(ha,'on');
  h = plot3(ha,f_{:});
  hold(ha, 'off');

  if nargout, h_ = h; end
end
