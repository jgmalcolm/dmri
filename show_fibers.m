function show_fibers(fibers, c)
  if nargin ~= 2,  c = 'b'; end
  hold on;
  cellfun(@(f) plot(f(2,:), f(1,:), c, 'LineWidth', 1.5), fibers);
  hold off;
end

function plot_fiber(f,c)
  if isempty(f), return, end
  plot(f(2,:), f(1,:), c, 'LineWidth', 1.5);
end
