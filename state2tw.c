#include <mex.h>
#include <math.h>

static inline double dot(double *x, double *y)
{
    double s = 0;
    for (int i = 0; i < 3; i++)
        s += x[i] * y[i];
    return s;
}

static void unpack(double *o,
                   mxArray **m_m, mxArray **m_l, mxArray **m_w,
                   double *y)
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

    /* lambda */
    *m_l = mxCreateDoubleMatrix(2,1,mxREAL);
    double *l = mxGetPr(*m_l);
    l[0] = o[3];
    l[1] = o[4];

    /* weight */
    *m_w = mxCreateDoubleScalar(o[5]);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("requires double precision X");
    if (nrhs == 2 && !mxIsDouble(prhs[1]))
        mexErrMsgTxt("requires double precision m");

    double *o = mxGetPr(prhs[0]);
    double *m = nrhs==2 ? mxGetPr(prhs[1]) : NULL;

                    unpack(o   , plhs+0, plhs+1, plhs+2, m);
    if (nlhs > 3)   unpack(o+ 6, plhs+3, plhs+4, plhs+5, m);
    if (nlhs > 6)   unpack(o+12, plhs+6, plhs+7, plhs+8, m);
}
