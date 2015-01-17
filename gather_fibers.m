function gather_fibers
  
  base = '/projects/schiz/pi/malcolm/fa';
  
  label = 24;
  d = dir(sprintf('%s/*_%02d_3.mat', base, label));
  
  n = numel(d);
  for i = 1:n
    id = str2num(d(i).name(1:5))
    fn = sprintf('%s/%s', base, d(i).name);
    f = loadsome(fn, 'ff');
    f = map(@(x) single(x(1:3,:)), f);

    f = f(cellfun(@(f) 25 < size(f,2) && size(f,2) < 90, f));
    if numel(f) < 5, continue, end
      
    ff{i} = f;
    patients(i) = id;
  end
  disp('saving...')
  save([base '/fibers_24'], 'ff', 'patients');
end
