#include <mex.h>
#include <math.h>
#include "vec3.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        
mexErrMsgTxt("double precision required");

    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);
    const int *X_dims = mxGetDimensions(prhs[0]);

    for (int i = 0; i < X_dims[1]; i++) {
        double *o1 = X, *o2 = X+4;

        /* unpack */
        double l11 = o1[2], l12 = o1[3];
        double l21 = o2[2], l22 = o2[3];
    
        /* ensure: lambda >= L */
        double L = 100;
        if (l11 < L)   l11 = L;
        if (l12 < L)   l12 = L;
        if (l21 < L)   l21 = L;
        if (l22 < L)   l22 = L;

        /* write back */
        o1[2] = l11; o2[2] = l21;
        o1[3] = l12; o2[3] = l22;

        /* prepare for next */
        X += X_dims[0];
    }
}
