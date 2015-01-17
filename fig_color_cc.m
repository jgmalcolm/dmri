function fig_color_cc(m)
  
  disp = false;
  
  prnt = @(fn) print('-dpng', '-r100', fn);

  n = size(m,3);
  
  % adjust colormap so background is white
  jet_ = jet;
  jet_(end+1,:) = [1 1 1];
  colormap(jet_);

  for i = 1:n
    img = m(:,:,i);
    img(img == 1) = max(img(:)) + 1;
    fn = sprintf('figs/ap/cc_2t/cc_%02d_%02d', i, numel(unique(img))-1)
    
    if disp, sp(1,n,i); else, clf, end
    imagesc(img);
    if ~disp, set(gca, 'Position', [0 0 1 1]); end
    axis image off
    set(gca, 'YLim', [26 44], 'XLim', [49 96]);

    if ~disp, prnt(fn); end
  end
end
