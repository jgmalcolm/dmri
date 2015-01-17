#include <mex.h>
#include <math.h>
#include "vec3.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("expects double precision input");
    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);
    const int *X_dims = mxGetDimensions(prhs[0]);

    for (int i = 0; i < X_dims[1]; i++) {
        /* unpack and normalize orientations */
        vec_t m1 = make_vec(X[0], X[1], X[2]); m1 = m1 / norm(m1);
        double l11 = X[3], l12 = X[4];
    
        /* ensure: lambda >= L */
        double L = 100;
        if (l11 < L)   l11 = L;
        if (l12 < L)   l12 = L;

        /* write back */
        vec2mem(m1, X);
        X[3] = l11; X[4] = l12;

        /* prepare for next */
        X += X_dims[0];
    }
}
