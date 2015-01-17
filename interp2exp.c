#include <mex.h>
#include <math.h>

#define SIGMA  .3

inline int clamp(int x, int min, int max)
{
    return x < min ? min : x > max ? max : x;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("interp2exp: double precision volume required");

    double *D = mxGetData(prhs[0]);
    double *p = mxGetPr(prhs[1]);
    double sigma = nrhs==3 ? mxGetScalar(prhs[2]) : (SIGMA);

    const int *dims = mxGetDimensions(prhs[0]);

    int nx = dims[0], ny = dims[1], n = dims[2];

    mxArray *m_val = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    double *val = mxGetPr(m_val), w_sum = mxGetEps();
    for (int xx = -1; xx <= 1; xx++) {
        for (int yy = -1; yy <= 1; yy++) {
            #ifdef __sun__
            int x = floor(p[0] + 0.5) + xx;
            int y = floor(p[1] + 0.5) + yy;
            #else
            int x = round(p[0]) + xx;
            int y = round(p[1]) + yy;
            #endif

            double dx = x-p[0], dy = y-p[1];
            double w = exp( -(dx*dx + dy*dy)/sigma );
            x = clamp(x, 1, nx) - 1;
            y = clamp(y, 1, ny) - 1;
            for (int i = 0; i < n; i++)
                val[i] += w * D[nx*ny*i + nx*y + x];
            w_sum += w;
        }
    }

    /* normalize by weight */
    for (int i = 0; i < n; i++)
        val[i] /= w_sum;
}
