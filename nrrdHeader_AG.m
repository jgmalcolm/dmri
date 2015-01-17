function T = nrrdHeader_AG()

  nx = 256;
  ny = 256;
  nz = 45;

  spacex = -1;
  spacey = -1;
  spacez = -2.6;

  dispx = -(nx-1) * spacex / 2;
  dispy = -(ny-1) * spacey / 2;
  dispz = -(nz-1) * spacez / 2;
  
  T = diag([spacex  spacey spacez]);
  T(4,:) = [dispx dispy dispz];
end
