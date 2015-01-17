function XX = separate_clusters(xx, cc)
  
  XX = {};
  for i = unique(cc)
    XX{end+1} = xx(cc == i);
  end
end
