#include <mex.h>

struct param_t {
    void *x, *y, *z;
    int n, inc, inc_y, inc_z;
};

template <class tx, class ty>
void center(struct param_t p)
{
    tx *z = (tx *)p.z, *x = (tx *)p.x;
    ty *y = (ty *)p.y;
    while (p.n--) {
        z[0]       = x[0]       - y[0];
        z[p.inc_y] = x[p.inc_y] - y[1];
        z[p.inc_z] = x[p.inc_z] - y[2];

        x += p.inc; z += p.inc;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *m_X = prhs[0], *m_Y = prhs[1];

    const int *X_dims = mxGetDimensions(m_X);
    const int *Y_dims = mxGetDimensions(m_Y);
    if (!((X_dims[0] == 3 && Y_dims[0] == 3 && Y_dims[1] == 1) ||
          (X_dims[1] == 3 && Y_dims[1] == 3 && Y_dims[0] == 1)))
        mexErrMsgTxt("requires X as size=[3 n] and Y as size=[3 1], or transposed");

    /* determine element step */
    int inc, inc_y, inc_z, n;
    if (X_dims[0] == 3) {
        n = X_dims[1]; inc = 3; inc_y = 1;
    } else {
        n = X_dims[0]; inc = 1; inc_y = X_dims[0];
    }
    inc_z = 2*inc_y;

    mxArray *m_Z = plhs[0] = mxDuplicateArray(m_X);
    void *x = mxGetData(m_X), *y = mxGetData(m_Y), *z = mxGetData(m_Z);

    struct param_t p = {x, y, z, n, inc, inc_y, inc_z};
    
    /* center */
    if (mxIsDouble(m_X) && mxIsDouble(m_Y))       center<double,double>(p);
    else if (mxIsDouble(m_X) && mxIsSingle(m_Y))  center<double,float>(p);
    else if (mxIsSingle(m_X) && mxIsDouble(m_Y))  center<float,double>(p);
    else if (mxIsSingle(m_X) && mxIsSingle(m_Y))  center<float,float>(p);
    else mexErrMsgTxt("requires X as single or double precision");
}
