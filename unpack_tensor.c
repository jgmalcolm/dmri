#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *o = mxGetPr(prhs[0]);

    /* m */
    mxArray *m_m = plhs[0] = mxCreateDoubleMatrix(3, 1, mxREAL);
    double *m = mxGetPr(m_m), norm = mxGetEps();
    for (int i = 0; i < 3; i++) {
        m[i] = o[i];
        norm += m[i]*m[i];
    }
    norm = sqrt(norm);
    for (int i = 0; i < 3; i++)
        m[i] /= norm;

    /* lambda */
    plhs[1] = mxCreateDoubleMatrix(2,1,mxREAL);
    double *lambda = mxGetPr(plhs[1]);
    lambda[0] = o[3];
    lambda[1] = o[4];
}
