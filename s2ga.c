#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("requires double precision");

    double *s = mxGetPr(prhs[0]);
    const int *s_dims = mxGetDimensions(prhs[0]);
    int n = s_dims[0], m = s_dims[1];

    mxArray *m_ga = plhs[0] = mxCreateDoubleMatrix(1,m,mxREAL);
    double *ga = mxGetPr(m_ga);

    for (int i = 0; i < m; i++, ga++) {
        /* compute mean of signal and squared signal */
        double mu = 0, mu_sq = 0;
        for (int i = 0; i < n; i++, s++) {
            mu    += *s;
            mu_sq += *s * *s;
        }
        mu    /= n;
        mu_sq /= n;

        *ga = sqrt(mu_sq - mu*mu) / sqrt(mu_sq);
    }
}
