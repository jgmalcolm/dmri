function trim_cortical(seeds)
  ff = {};
  for i = 1:2
    f = loadsome(['f_' int2str(i)], 'f');
    ff = {ff{:} f{:}};
  end

  is_L = seeds==1024;
  is_R = seeds==2024;

  f_cortical = connecting(ff, is_L, is_R);

  ijk2vtk(fiber2ijk(f_cortical), 'cortical');
  save('cortical', 'f_cortical');
end
