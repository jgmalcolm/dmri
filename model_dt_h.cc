#include <mex.h>
#include <math.h>

#include "vec3.h"
#include "mat3.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0])) mexErrMsgTxt("expects double-precision tensor");
    if (!mxIsDouble(prhs[1])) mexErrMsgTxt("expects double-precision gradients");
    double *D = mxGetPr(prhs[0]);
    const int *D_dims = mxGetDimensions(prhs[0]);
    if (D_dims[0] != 3 || D_dims[1] != 3) mexErrMsgTxt("expects D is 3x3");
    double *u = mxGetPr(prhs[1]);
    const int *u_dims = mxGetDimensions(prhs[1]);
    double b = mxGetScalar(prhs[2]);

    /* form diffusion tensor */
    mat_t T = make_mat(D[0], D[3], D[6],
                       D[1], D[4], D[7],
                       D[2], D[5], D[8]);

    /* reconstruct signal */
    int n = u_dims[0];
    mxArray *m_s = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    double *s = mxGetPr(m_s);
    for (int i = 0; i < n; i++) {
        vec_t u_ = make_vec(u[i], u[n+i], u[2*n+i]);
        s[i] = exp(-b * dot(u_, T * u_));
    }
}
