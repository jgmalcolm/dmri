XML = """<?xml version="1.0" encoding="utf-8"?>
<executable>

  <category>Tractography</category>
  <title>Python Streamline</title>
  <description>Streamline tractography.</description>

  <parameters>
    <label>IO</label>
    <description>Input/output parameters</description>

    <geometry>
      <name>ff</name> <channel>output</channel> <index>0</index>
      <label>Output Fiber bundle</label>
    </geometry>

  </parameters>
</executable>
"""

from Slicer import slicer

def Execute(ff):
    scene = slicer.MRMLScene

    pts = slicer.vtkPoints()
    lines = slicer.vtkCellArray()

    # build in numpy --> toarray
    lines.InsertNextCell(3)
    lines.InsertCellPoint(0);  pts.InsertNextPoint( 1, 1, 1)
    lines.InsertCellPoint(1);  pts.InsertNextPoint( 0, 0, 0)
    lines.InsertCellPoint(2);  pts.InsertNextPoint(-1,-1,-1)

    pd = slicer.vtkPolyData()
    pd.SetPoints(pts)
    pd.SetLines(lines)
    pd.Update()

    ff = scene.GetNodeByID(ff)
    ff.SetAndObservePolyData(pd)

    return
