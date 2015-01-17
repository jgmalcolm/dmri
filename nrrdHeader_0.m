function T = nrrdHeader_0()

  nx = 128;
  ny = 128;
  nz = 68;

  spacex = -2;
  spacey = -2;
  spacez = -2;

  dispx = -(nx-1) * spacex / 2;
  dispy = -(ny-1) * spacey / 2;
  dispz = -(nz-1) * spacez / 2;
  
  T = diag([spacex  spacey spacez]);
  T(4,:) = [dispx dispy dispz];
end
