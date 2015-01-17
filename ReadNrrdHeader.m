function worldToScaledIJK = ReadNrrdHeader()

  nx = 144;
  ny  =144;
  nz = 85;

  spacex = 1.6667;
  spacey = 1.6667;
  spacez = -1.7;

  dispx = -0.5 * nx * spacex;
  dispy = -0.5 * ny * spacey;
  dispz = -0.5 * nz * spacez;
  worldToScaledIJK = [-spacex 0 0 ; 0 -spacey 0 ; 0 0 spacez ; -dispx -dispy dispz ];
