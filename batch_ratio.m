function ratio = batch_ratio
  paths
  
  id = read_group('all');
  
  for id = id
    [S m u b wm gm] = load_patient(id);
    
    % white matter distance
    [x1 y1 z1] = ind2sub(size(wm), find(wm==26));
    [x2 y2 z2] = ind2sub(size(wm), find(wm==25));
    wm_dist = norm(mean([x1 y1 z1]) - mean([x2 y2 z2]));
    
    % gray matter distance
    [x1 y1 z1] = ind2sub(size(gm), find(gm==2024));
    [x2 y2 z2] = ind2sub(size(gm), find(gm==1024));
    gm_dist = norm(mean([x1 y1 z1]) - mean([x2 y2 z2]));

    ratio(id) = gm_dist/wm_dist;
    fprintf('case%05d  %f\n', id, ratio(id));
  end
end
