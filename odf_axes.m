function odf_axes(F, u, m, origin, c)
% put axes indicators centered at point
  
  if nargin < 4
    origin = [0 0 0]';
  end
  if nargin < 5
    c = 'k';
  end

  odf(F, u, convhulln(u), origin);
  
  m = m * diag(1./sqrt(sum(m.^2))) * max(F) * 1.15;

  hold on;
  for m = m
    X = origin(:,[1 1]) + m*[1 -1];
    plot3(X(2,:),X(1,:),X(3,:), c, 'LineWidth', 3);
  end
  hold off
end
