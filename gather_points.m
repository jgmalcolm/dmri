function gather_points
  
  base = '/projects/schiz/pi/malcolm/fa';

  patients = read_group('all');
  labels = [03 24 28];

  X = cell(numel(patients), numel(labels));
  for i = 1:numel(patients)
    p = patients(i);
    for j = 1:numel(labels)
      lb = labels(j);

      fn = sprintf('%s/%05d_%02d_3.mat', base, p, lb);
      if ~exist(fn), continue, end
      
      disp(fn)
      if     lb == 03,  len = 90;
      elseif lb == 24,  len = 95;
      elseif lb == 28,  len = 95; end

      ff = loadsome(fn, 'ff');
      ff = map(@(f) single(f(1:3,:)), ff);

      ff = {ff{cellfun(@(f) 25 < size(f,2) && size(f,2) < len, ff)}};
      if numel(ff) < 5, continue, end
      
      counts{i,j} = cellfun(@(x) size(x,2), ff);
      %X{i,j} = [ff{:}];

    end
  end
  disp('saving...')
  %save([base '/points_03_24_28'], 'X', 'patients', 'labels');
  save([base '/points_03_24_28_counts'], 'counts');
end
