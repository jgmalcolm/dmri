#include <mex.h>
#include <math.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("expects double precision");
    mwSize n = mxGetNumberOfElements(prhs[0]);
    if (n % 2 != 0) /* even */
        mexErrMsgTxt("expects lambda=[l1 l2] or lambda=[l11 l12 l21 l22 ...]");

    double *ll = mxGetPr(prhs[0]);
    plhs[0] = mxCreateDoubleMatrix(1, n/2, mxREAL);
    double *fa = mxGetPr(plhs[0]);

    for (int i = 0; i < n/2; i++) {
        double a = ll[2*i+0], b = ll[2*i+1];
        fa[i] = abs(a - b)/sqrt(a*a + 2*b*b);
    }
}
