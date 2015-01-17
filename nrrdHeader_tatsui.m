function T = nrrdHeader_tatsui()

  nx = 220;
  ny = 220;
  nz = 185;

  spacex = -1;
  spacey = -1;
  spacez = -1;

  dispx = -(nx-1) * spacex / 2;
  dispy = -(ny-1) * spacey / 2;
  dispz = -(nz-1) * spacez / 2;
  
  T = diag([spacex  spacey spacez]);
  T(4,:) = [dispx dispy dispz];
end
