#include <mex.h>
#include <math.h>

template<class ty>
void s2ga(ty *s, int m, int n, ty *ga)
{
    for (int i = 0; i < n; i++) {

        /* compute mean of signal and squared signal */
        double mu = 0, mu_sq = 0;
        for (int j = 0; j < m; j++) {
            double s_ = s[n*j];
            mu += s_;
            mu_sq += s_*s_;
        }
        mu    /= m;
        mu_sq /= m;

        /* compute GA */
        double sigma = sqrt(mu_sq - mu*mu);
        ga[i] = sigma / sqrt(mu_sq);

        /* prepare for next */
        s++;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *m_s = prhs[0];
    const int *s_dims = mxGetDimensions(m_s);
    int s_ndims = mxGetNumberOfDimensions(m_s);
    int n = s_dims[0];
    for (int i = 1; i < s_ndims-1; i++)
        n *= s_dims[i];
    int m = s_dims[s_ndims-1];

    mxClassID id = mxUNKNOWN_CLASS;
    if (mxIsSingle(m_s))       id = mxSINGLE_CLASS;
    else if (mxIsDouble(m_s))  id = mxDOUBLE_CLASS;
    else  mexErrMsgTxt("requires single or double precision");

    mxArray *m_ga = plhs[0] = mxCreateNumericArray(s_ndims-1,s_dims,id,mxREAL);

    void *s = mxGetData(m_s), *ga = mxGetData(m_ga);

    if (mxIsSingle(m_s))   s2ga((float  *)s,m,n,(float  *)ga);
    else                   s2ga((double *)s,m,n,(double *)ga);
}
