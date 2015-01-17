#include <mex.h>
#include <math.h>

static inline double dot(double *x, double *y)
{
    double s = 0;
    for (int i = 0; i < 3; i++)
        s += x[i] * y[i];
    return s;
}

static void unpack(double *o, mxArray **m_m, mxArray **m_k, double *y)
{
    /* m */
    *m_m = mxCreateDoubleMatrix(3,1,mxREAL);
    double *m = mxGetPr(*m_m), m_norm = mxGetEps();
    for (int i = 0; i < 3; i++) {
        m[i] = o[i];
        m_norm += m[i]*m[i];
    }
    /* normalize */
    m_norm = sqrt(m_norm);
    for (int i = 0; i < 3; i++)
        m[i] /= m_norm;

    /* flip orientation? */
    if (y && dot(m,y) < 0) {
        for (int i = 0; i < 3; i++)
            m[i] = -m[i];
    }

    /* k */
    *m_k = mxCreateDoubleMatrix(1,1,mxREAL);
    double *k = mxGetPr(*m_k);
    *k = o[3];
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("requires double precision X");
    if (nrhs == 2 && !mxIsDouble(prhs[1]))
        mexErrMsgTxt("requires double precision m");

    double *o = mxGetPr(prhs[0]);
    double *m = nrhs==2? mxGetPr(prhs[1]) : NULL;

                    unpack(o  , plhs+0, plhs+1, m);
    if (nlhs > 2)   unpack(o+4, plhs+2, plhs+3, m);
    if (nlhs > 4)   unpack(o+8, plhs+4, plhs+5, m);
}
