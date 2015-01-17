#include <mex.h>
#include <math.h>

#define SIGMA  .5

inline int clamp(int x, int min, int max)
{
    return x < min ? min : x > max ? max : x;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsLogical(prhs[0]))
        mexErrMsgTxt("interp3scalar: logical volume required");
    
    mxLogical *D = mxGetLogicals(prhs[0]);
    double *p = mxGetPr(prhs[1]);
    double sigma = nrhs==3 ? mxGetScalar(prhs[2]) : (SIGMA);

    const int *dims = mxGetDimensions(prhs[0]);
    int nx = dims[0], ny = dims[1], nz = dims[2];

    double val = 0, w_sum = mxGetEps();
    for (int xx = -1; xx <= 1; xx++) {
        for (int yy = -1; yy <= 1; yy++) {
            for (int zz = -1; zz <= 1; zz++) {
                #ifdef __sun__
                int x = floor(p[0] + 0.5) + xx;
                int y = floor(p[1] + 0.5) + yy;
                int z = floor(p[2] + 0.5) + zz;
                #else
                int x = round(p[0]) + xx;
                int y = round(p[1]) + yy;
                int z = round(p[2]) + zz;
                #endif
                double dx = x-p[0], dy = y-p[1], dz = z-p[2];
                double w = exp( -(dx*dx + dy*dy + dz*dz)/sigma );
                x = clamp(x, 1, nx) - 1;
                y = clamp(y, 1, ny) - 1;
                z = clamp(z, 1, nz) - 1;
                double d = D[nx*ny*z + nx*y + x];
                val   += w * d;
                w_sum += w;
            }
        }
    }
    
    plhs[0] = mxCreateDoubleScalar(val / w_sum);
}
