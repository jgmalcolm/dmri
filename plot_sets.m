function plot_sets(sets)
  clf; hold on;
  colors = 'bgrcmy';
  for i = 1:numel(sets)
    X = sets{i};
    for j = 1:numel(X)
      xx = mean(X{j}(:,1));
      yy = mean(X{j}(:,2));
      zz = mean(X{j}(:,3));
      plot3(xx,yy,zz,[colors(j) '.']);
    end
  end
  hold off;
end
