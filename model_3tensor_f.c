#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *m_X = plhs[0] = mxDuplicateArray(prhs[0]);
    double *X = mxGetPr(m_X);
    const int *X_dims = mxGetDimensions(prhs[0]);

    for (int i = 0; i < X_dims[1]; i++) {

        double *m1 = X,    *l11 = m1 + 3, *l12 = l11 + 1;
        double *m2 = X+5,  *l21 = m2 + 3, *l22 = l21 + 1;
        double *m3 = X+10, *l31 = m3 + 3, *l32 = l31 + 1;
    
        /* ensure: lambda >= L */
        double L = 100;
        if (*l11 < L)   *l11 = L;
        if (*l12 < L)   *l12 = L;
        if (*l21 < L)   *l21 = L;
        if (*l22 < L)   *l22 = L;
        if (*l31 < L)   *l31 = L;
        if (*l32 < L)   *l32 = L;

        /* normalize M */
        double m1_ = mxGetEps(), m2_ = m1_, m3_ = m1_;
        for (int i = 0; i < 3; i++) {
            m1_ += m1[i]*m1[i];
            m2_ += m2[i]*m2[i];
            m3_ += m3[i]*m3[i];
        }
        m1_ = sqrt(m1_);
        m2_ = sqrt(m2_);
        m3_ = sqrt(m3_);
        for (int i = 0; i < 3; i++) {
            m1[i] /= m1_;
            m2[i] /= m2_;
            m3[i] /= m3_;
        }

        /* prepare for next */
        X += X_dims[0];
    }
}
