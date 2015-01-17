#include <mex.h>
#include <math.h>
#include "vec3.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("expects double precision state");
    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);
    const int *X_dims = mxGetDimensions(prhs[0]);

    for (int i = 0; i < X_dims[1]; i++) {
        double *o1 = X, *o2 = X + 5;

        /* unpack and normalize orientations */
        vec_t m1 = make_vec(o1[0], o1[1], o1[2]); m1 = m1 / norm(m1);
        vec_t m2 = make_vec(o2[0], o2[1], o2[2]); m2 = m2 / norm(m2);
        double l11 = o1[3], l12 = o1[4];
        double l21 = o2[3], l22 = o2[4];
    
        /* ensure: lambda >= L */
        double L = 100;
        if (l11 < L)   l11 = L;
        if (l12 < L)   l12 = L;
        if (l21 < L)   l21 = L;
        if (l22 < L)   l22 = L;

        /* write back */
        vec2mem(m1, o1);  vec2mem(m2, o2);
        o1[3] = l11; o2[3] = l21;
        o1[4] = l12; o2[4] = l22;

        /* prepare for next */
        X += X_dims[0];
    }
}
