function show_seed(ff, baseline, seeds, id, T)
  colormap gray
  clf; imagesc(baseline(:,:,2)'); axis image xy
  hold on;
  
  show(1, [.9 .3 .3], 671);
  show(2, [.2 .8 .2], 553);
  show(3, [.2 .2 .8], 915);
  show(4, [.8 .8 .2], 548);
  show(5, 'c', 6991);
  show(6, [.7 0 .6], 2770);
  show(7, [1 .5 0], 1803);
  show(8, [.5 1 .5], 1878);
  show(9, [.6 0 .5], 3733);
  show(10, [.8 .8 .2], 1827);
  show(11, [.7 .9 .9], 212);
  show(12, [.8 .2 .2], 3347);
  show(13, [0 .7 0], 449);
  show(14, [.3 .2 .8], 439);
  show(15, [.8 .8 .2], 197);
  show(16, 'c', 1212);
  
  return
  
  hold off;
  
  set(gca, 'YLim', [1 57], 'XTick', [], 'YTick', [], 'Position', [0 0 1 1]);
  print('-r200', '-dpng', 'figs/fc/phantom_3mm');
  return

  [x(1,1) x(2,1) x(3,1)] = ind2sub(size(seeds), find(seeds == id));
  
  plot(x(1),x(2),'yo','MarkerSize',15);

  ind = find(cellfun(@(xx)is_near(xx,x), ff))
  ff_ = ff(ind);
  cycle(ind, ff);
%   ff_ = {};
 
  map(@(x) plot(x(1,:), x(2,:), 'r'), ff_);
  plot(x(1),x(2),'yo','MarkerSize',15);
  hold off

  function show(seed_id, c, idx)
    [x(1,1) x(2,1) x(3,1)] = ind2sub(size(seeds), find(seeds == seed_id));
    xx = ff{idx};
    plot(x(1),x(2),'wo','MarkerSize',10,'LineWidth',2);
    plot(xx(1,:),xx(2,:), 'Color',c, 'LineWidth',2);
    fid = fopen(sprintf('results/fc/Fiber%d.txt',seed_id),'w');
    xx = xx - 1;
    xx(3,:) = 1;
    xx(4,:) = 1;
    xx_ = T * xx;
    fprintf(fid, '%6.1f %6.1f %6.1f\n', xx_(1:3,:));
    fclose(fid);
  end

end

function r = is_near(xx, x)
  xx_ = center(xx, x);
  r = any(sum(xx_.^2) < .5);

%   r = r && all(xx(2,:) < 40);
%   r = r && any(xx(2,:) < 17);
%   r = r && all(xx(1,:) > 12);
%   r = r && all(xx(1,:) > 19);
%   r = r && any(xx(2,:) < 18);
%   r = r && any(xx(2,:) > 40);
end


function cycle(ind, ff)
  for ind = ind
    ind
    ff_ = ff(ind);
    h = plot(ff{ind}(1,:), ff{ind}(2,:), 'r');
    pause
    delete(h)
  end
end
