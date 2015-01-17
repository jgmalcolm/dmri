function fig_field(s,u)
  fcs = convhulln(u);
  
  h = 1.5;
  
  clf;
  for r = 1:size(s,1);
    for c = 1:size(s,2);
      odf(flat(s(r,c,:)), u, fcs, h*[r c 0]');
    end
  end
  axis image off;
end
