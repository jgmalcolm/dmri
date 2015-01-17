
XML = """<?xml version="1.0" encoding="utf-8"?>

<executable>

  <category>Diffusion</category>
  <title>Probe Scalar Volume With Tractography Model</title>
  <description>Python module for coloring tractography with a scalar volume.
  </description>
  <contributor>Peter Savadjiev, with inspiration from Lauren O'Donnell's 
  older version of this module. This module takes fiber tracts, adds tubes 
  around them and colors them based on the input scalar volume.</contributor>
  
  <parameters>

    <label>IO</label>
    <description>Input/output parameters</description>

    <image type="scalar">
      <name>scalarVol</name>
      <label>Scalar Volume</label>
      <channel>input</channel>
      <index>0</index>
      <description>Scalar volume used to color the tractography model</description>
    </image>

    <geometry>
      <name>inputModel</name>
      <label>Input Model</label>
      <channel>input</channel>
      <index>1</index>
      <description>Input tractography model to be colored</description>
    </geometry>

    <geometry>
      <name>outputModel</name>
      <label>Output Model</label>
      <channel>output</channel>
      <index>2</index>
      <description>Result</description>
    </geometry> 

  </parameters>


</executable>

"""


def Execute (scalarVol,inputModel,outputModel):

	Slicer = __import__ ( "Slicer" )
	slicer = Slicer.slicer
#	Set up the slicer environment	
	scene = slicer.MRMLScene
	


        inputScalarVol = scene.GetNodeByID(scalarVol)
        model = scene.GetNodeByID(inputModel)

# 	Set output node
	output = scene.GetNodeByID(outputModel)



        outputPolyData = model.GetPolyData()

        spacing_o = inputScalarVol.GetSpacing()

        mat3 = slicer.vtkMatrix4x4()
        inputScalarVol.GetRASToIJKMatrix(mat3)

        trans = slicer.vtkTransform()
        trans.Identity()
        trans.PreMultiply()
        trans.SetMatrix(mat3)

        
        transfilt = slicer.vtkTransformPolyDataFilter()
        transfilt.SetTransform(trans)
        transfilt.SetInput(outputPolyData)
        transfilt.Update()


        origin = inputScalarVol.GetOrigin()

        inputScalarVol.SetSpacing(1,1,1)
        inputScalarVol.SetOrigin(0,0,0)

        probe = slicer.vtkProbeFilter()
        probe.SetInput(transfilt.GetOutput())
        probe.SetSource(inputScalarVol.GetImageData())
        probe.Update()



        trans2 = slicer.vtkTransform()
        trans2.DeepCopy(trans)
        trans2.Inverse()

        transfilt2 = slicer.vtkTransformPolyDataFilter()
        transfilt2.SetTransform(trans2)
        transfilt2.SetInput(probe.GetOutput())

        transfilt2.Update()


        tuber = slicer.vtkTubeFilter()
        tuber.SetInput(transfilt2.GetOutput())
        tuber.SetRadius(0.3) #0.5
        tuber.SetNumberOfSides(6) #8
        tuber.Update()
        tuber.GetOutput().GetPointData().GetScalars().SetName("Probed Scalars")
        #transfilt2.GetOutput().GetPointData().GetScalars().SetName("Probed Scalars")

        inputScalarVol.SetSpacing(spacing_o[0],spacing_o[1],spacing_o[2])
        inputScalarVol.SetOrigin(origin[0],origin[1],origin[2])

        output.SetAndObservePolyData(tuber.GetOutput())    #transfilt2.GetOutput()#(outputPolyData)

	return
