function batch_lbl1t(id, lbl, S,m,u,b,wm,gm)
  fn = sprintf('/projects/schiz/pi/malcolm/fa/%05d_%02d_3', id, lbl);

  fprintf('case%05d %02d\n', id, lbl);
  [S m u b wm gm] = load_patient(id);
  ff = loadsome(fn, 'ff');
  ff = fiber2t(ff, u, b, S);
  
  mm = gm==1000+lbl | gm==2000+lbl;

  save([fn '_1t'], 'ff', 'mm');
end
