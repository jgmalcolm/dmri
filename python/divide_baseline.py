XML = """<?xml version="1.0" encoding="utf-8"?>
<executable>

  <category>Diffusion Weighted</category>
  <title>Divide Averaged Baseline</title>
  <description>Divide out averaged baseline image.</description>

  <parameters>
    <label>IO</label>
    <description>Input/output parameters</description>

    <image type="diffusion-weighted">
      <name>in_node</name> <channel>input</channel> <index>0</index>
      <label>Input diffusion signal</label>
    </image>
    <image type="diffusion-weighted">
      <name>out_node</name> <channel>output</channel> <index>1</index>
      <label>Output normalized diffusion signal</label>
    </image>

  </parameters>
</executable>
"""

from Slicer import slicer
import numpy

def Execute(in_node, out_node) :
    for i in range(5) : print '\n'

    scene = slicer.MRMLScene
    in_node  = scene.GetNodeByID(in_node)
    out_node = scene.GetNodeByID(out_node)

    dwi = in_node.GetImageData()
    dwi_ = out_node.GetImageData()
    if not dwi_ : dwi_ = slicer.vtkImageData() # create if necessary
    out_node.SetAndObserveImageData(dwi_)

    # grab diffusion weighted signal and b-values
    S = in_node.GetImageData().ToArray()
    u = in_node.GetDiffusionGradients().ToArray()
    b = in_node.GetBValues().ToArray().ravel()

    first_nzero = 0;
    for i in range(len(b)) :
        if b[i] : break
        first_nzero += 1
    last_zero = first_nzero - 1
    print first_nzero
    print last_zero

    u_ = u[first_nzero:,:]
    b_ = b[first_nzero:]

    dwi_.SetDimensions(*dwi.GetDimensions())
    dwi_.SetOrigin(0,0,0)
    dwi_.SetSpacing(1,1,1)
    dwi_.SetScalarTypeToFloat()
    dwi_.SetNumberOfScalarComponents(len(b_))
    dwi_.AllocateScalars()

    S_ = dwi_.ToArray()
    b0 = S[...,1:last_zero].mean(-1)
    print type(S)
    print type(b0)
    S_[:] = S[...,first_nzero:].astype('float') / b0[...,numpy.newaxis].astype('float')

    out_node.SetNumberOfGradients(nnz)

    uu = out_node.GetDiffusionGradients().ToArray()
    uu[:] = u_;
    bb = out_node.GetBValues().ToArray().ravel()
    bb[:] = b_;

    m = slicer.vtkMatrix4x4()
    in_node.GetIJKToRASMatrix(m)
    out_node.SetIJKToRASMatrix(m)
    in_node.GetMeasurementFrameMatrix(m)
    out_node.SetMeasurementFrameMatrix(m)

    out_node.Modified()

    asdf

    return
