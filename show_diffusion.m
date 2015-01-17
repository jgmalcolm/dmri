function show_diffusion(M)
% note: only shows 2D field
  cla;
  hold on;
  [nx ny d n] = size(M);
  colors = 'rbm';
  for i = 1:n
    quiver(M(:,:,2,i), M(:,:,1,i), colors(i), 'ShowArrowHead', 'off');
  end
  axis ij image off
  set(gca, 'YLim', [0 nx]+.5, 'XLim', [0 ny]+.5);
  hold off
end
