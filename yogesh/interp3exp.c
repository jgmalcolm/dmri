#include <mex.h>
#include <math.h>

#define SIGMA  .5

inline int clamp(int x, int min, int max)
{
    return x < min ? min : x > max ? max : x;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsSingle(prhs[0]))
        mexErrMsgTxt("interp3exp: single precision volume required");

    float *D = mxGetData(prhs[0]);
    double *p = mxGetPr(prhs[1]);
    double sigma = nrhs==3 ? mxGetScalar(prhs[2]) : (SIGMA);
    double *v = nrhs == 3 ? mxGetPr(prhs[2]) : NULL;
    v = NULL;
    const int *dims = mxGetDimensions(prhs[0]);

    int nx = dims[0], ny = dims[1], nz = dims[2], n = dims[3];

    mxArray *m_val = plhs[0] = mxCreateDoubleMatrix(2*n,1,mxREAL);
    double *val = mxGetPr(m_val), w_sum = 0;
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
                if (v) {
                    dx *= v[0]; dy *= v[1]; dz *= v[2]; /* scale voxel */
                }
                double w = exp( -(dx*dx + dy*dy + dz*dz)/sigma );
                
                x = clamp(x, 1, nx) - 1;
                y = clamp(y, 1, ny) - 1;
                z = clamp(z, 1, nz) - 1;
                for (int i = 0; i < n; i++) {
                    double d = D[nx*(ny*(nz*i + z) + y) + x];
                    val[i  ] += w * d;
                    val[i+n] += w * d;
                }
                w_sum += w;
            }
        }
    }

    /* normalize by weight */
    w_sum *= 2; /* double each occurance */
    for (int i = 0; i < 2*n; i++)
        val[i] /= w_sum;
}
