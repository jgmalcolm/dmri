#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]))
        mexErrMsgTxt("expects double precision");

    double *u = mxGetPr(prhs[0]);
    const int *u_dims = mxGetDimensions(prhs[0]);
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

    /* reconstruct ODF */
    int n = u_dims[0];
    mxArray *m_f = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    double *f = mxGetPr(m_f), f_sum = mxGetEps();
    for (int i = 0; i < n; i++) {
        double dot = u[i]*m[0] + u[n+i]*m[1] + u[2*n+i]*m[2];
        double eta = sin(acos(dot));
        f[i] = exp(-k * eta * eta);
        f_sum += f[i];
    }
    for (int i = 0; i < n; i++)
        f[i] /= f_sum;
}
