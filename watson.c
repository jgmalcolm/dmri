#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const int *u_dims = mxGetDimensions(prhs[0]);
    if (u_dims[1] != 3)
        mexErrMsgTxt("u must be [n 3] matrix");
    double *u = mxGetPr(prhs[0]);

    if (mxGetNumberOfElements(prhs[1]) != 4)
        mexErrMsgTxt("X must have 4 elements");
    double *o = mxGetPr(prhs[1]);

    /* unpack and normalize orientation */
    double k = o[3];
    double m[] = {o[0], o[1], o[2]};
    double m_norm = mxGetEps();
    for (int i = 0; i < 3; i++)
        m_norm += m[i]*m[i];
    m_norm = sqrt(m_norm);
    for (int i = 0; i < 3; i++)
        m[i] /= m_norm;

    /* reconstruct signal */
    int n = u_dims[0];
    mxArray *m_s = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    double *s = mxGetPr(m_s), s_norm = mxGetEps();
    for (int i = 0; i < n; i++) {
        double dot = u[i]*m[0] + u[n+i]*m[1] + u[2*n+i]*m[2];
        s[i] = exp(-k * dot * dot);
        s_norm += s[i]*s[i];
    }
    s_norm = sqrt(s_norm);
    for (int i = 0; i < n; i++)
        s[i] /= s_norm;
}
