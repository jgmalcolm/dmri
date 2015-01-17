#include <mex.h>
#include <math.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const int *X_dims = mxGetDimensions(prhs[0]);
    int m = X_dims[1];
    if (X_dims[0] == 1 && X_dims[1] > 1)
        mexErrMsgTxt("expects column vectors");
    double *X = mxGetPr(prhs[0]);

    double *u = mxGetPr(prhs[1]);
    const int *u_dims = mxGetDimensions(prhs[1]);
    int n = u_dims[0];

    mxArray *m_s = plhs[0] = mxCreateDoubleMatrix(n,m,mxREAL);
    double *s = mxGetPr(m_s);

    const double eps = mxGetEps();

    for (int i = 0; i < m; i++) {
        double *o1 = X, *o2 = o1 + 4, *o3 = o2 + 4;

        /* unpack and normalize orientations */
        double m1[] = {o1[0], o1[1], o1[2]};
        double m2[] = {o2[0], o2[1], o2[2]};
        double m3[] = {o3[0], o3[1], o3[2]};
        double k1 = o1[3], k2 = o2[3], k3 = o3[3];
        double m1_ = eps, m2_ = eps, m3_ = eps;
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

        /* reconstruct signal */
        double s_ = eps;
        for (int i = 0; i < n; i++) {
            double dot1 = u[i]*m1[0] + u[n+i]*m1[1] + u[2*n+i]*m1[2];
            double dot2 = u[i]*m2[0] + u[n+i]*m2[1] + u[2*n+i]*m2[2];
            double dot3 = u[i]*m3[0] + u[n+i]*m3[1] + u[2*n+i]*m3[2];
            s[i] = exp(-k1*dot1*dot1)
                 + exp(-k2*dot2*dot2)
                 + exp(-k3*dot3*dot3);
            s_ += s[i]*s[i];
        }
        s_ = sqrt(s_);
        for (int i = 0; i < n; i++)
            s[i] /= s_;

        /* prepare for next */
        X += X_dims[0];
        s += u_dims[0];
    }
}
