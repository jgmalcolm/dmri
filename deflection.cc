#include <mex.h>
#include "vec3.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (!mxIsStruct(prhs[0]))
        mexErrMsgTxt("expects struct");
    mxArray *m_list = mxGetField(prhs[0], 0, "list");
    mxArray *m_cur  = mxGetField(prhs[0], 0, "cur");
    if (!m_list || !m_cur)
        mexErrMsgTxt("expects field 'list' and 'cur'");
    int cur = mxGetScalar(m_cur);
    if (cur < 3) {
        plhs[0] = mxCreateDoubleScalar(1);
        return;
    }

    const mwSize *dims = mxGetDimensions(m_list);
    int n = dims[0];
    if (!mxIsSingle(m_list)) mexErrMsgTxt("expects single-precision list");
    float *list = (float *)mxGetData(m_list);
    float *a = list + n*(cur-1-2), *b = a + n, *c = b + n;

    vec_t ab = make_vec(b[0]-a[0], b[1]-a[1], b[2]-a[2]); ab /= norm(ab);
    vec_t bc = make_vec(c[0]-b[0], c[1]-b[1], c[2]-b[2]); bc /= norm(bc);

    plhs[0] = mxCreateDoubleScalar(dot(ab,bc));
   
}
