
XML = """<?xml version="1.0" encoding="utf-8"?>

<executable>

  <category>Python Modules</category>
  <title>Tensor Streamline Tractography</title>
  <description>Python module
  </description>
  <version>0.1.0.$Revision: 1892 $(alpha)</version>
  <documentation-url></documentation-url>
  <contributor>Madeleine Seeland</contributor>
  
  <parameters>

    <label>IO</label>
    <description>Input/output parameters</description>

    <image type="tensor">
      <name>inputVolume</name>
      <label>Input Tensor Volume</label>
      <channel>input</channel>
      <index>0</index>
      <description>Input Tensor volume</description>
    </image>

    <image type ="label">
      <name>inputROI</name>
      <label>Input ROI</label>
      <channel>input</channel>
      <index>1</index>
      <description>Label map with seeding ROIs</description>
    </image>

    <geometry>
      <name>outputFibers</name>
      <label>Output Fiber bundle</label>
      <longflag>outputFibers</longflag>
      <channel>output</channel>
      <description>Tractography result</description>
    </geometry> 

  </parameters>


</executable>

"""

import sys
sys.path.append('/projects/lmi/people/mseeland/Eclipse/Workspace/SlicerTrunk/Slicer3-lib/teem-wrap/')
import teem
import ctypes
import numpy
import math as M

def Execute (inputVolume,inputROI, outputFibers=""):

	Slicer = __import__ ( "Slicer" )
	slicer = Slicer.slicer
#	Set up the slicer environment	
	scene = slicer.MRMLScene
	
#	Get the input volume node from the MRML tree	
        inputVolumeNode = scene.GetNodeByID(inputVolume)
#	Get input ROI from the MRML tree
	inputROI = scene.GetNodeByID(inputROI)
# 	Set output node
	outputFiberBundleNode = scene.GetNodeByID(outputFibers)

	# get pointer to tensor image data
	data = inputVolumeNode.GetImageData().ToArray()
	tensorData = inputVolumeNode.GetImageData().GetPointData().GetTensors().ToArray()
	tensor_p = ctypes.cast(tensorData.__array_interface__['data'][0], ctypes.POINTER(ctypes.c_float))

	######################################## 1) create nrrd #########################################
	print "############################## create nrrd ###############################################"
	n = teem.nrrdNew()

	# get image information
	inputVolumeType = inputVolumeNode.GetImageData().ToArray().dtype.type
	inputVolumeDim = inputVolumeNode.GetImageData().ToArray().ndim

	# axes size
	sz = (ctypes.c_size_t * inputVolumeDim)()
#	Get dimensions of axes x,y,z
	dims = inputVolumeNode.GetImageData().GetDimensions() 
#	Get number of scalar components (for tensor volumes it returns 9, since tensor volumes in Slicer consists of 9-tensor components)
	tenComp = inputVolumeNode.GetImageData().GetNumberOfScalarComponents()
	sz[:] = [tenComp,dims[0],dims[1],dims[2]]


	###################### 2) wrap N around the existing 9-component tensor data array ##################################
	print "############################## wrap N around tensor data ###############################################"

	teem.nrrdWrap_nva(n, tensor_p, typeCodeToTeemType(inputVolumeType)[2], inputVolumeDim, sz)

#	Test
#	ni = teem.nrrdIterNew()
#	teem.nrrdIterSetNrrd(ni, n)
#	print teem.nrrdIterValue(ni)
#	print teem.nrrdIterValue(ni)
#	print teem.nrrdIterValue(ni)
#	print teem.nrrdIterValue(ni)
#	print teem.nrrdIterValue(ni)



	# cast the pointer to the image sample data
	data_out = ctypes.cast(n.contents.data, ctypes.POINTER(nrrdToCType(n.contents.type))) 
	print "data_out:", data_out, "\n"


	###################### 2) set other image information ##################################
	print "############################## set other image information ###############################################"

#	set space field
	teem.nrrdSpaceSet(n, teem.nrrdSpace3DRightHanded) 

#	Sets the topological dimension of the data 
#	n.contents.spaceDim = inputVolumeNode.GetImageData().GetDataDimension()
	
#	get/set measurement frame matrix
	mat = slicer.vtkMatrix4x4()
	inputVolumeNode.GetMeasurementFrameMatrix(mat)
#	BE careful: columns and rows are interchanged between Teem and Slicer
	m0=[1,0,0]
	m1=[0,1,0]
	m2=[0,0,1]
	for i in range (0,3):
		m0[i]=mat.GetElement(i,0)
		m1[i]=mat.GetElement(i,1)
		m2[i]=mat.GetElement(i,2)

	n.contents.measurementFrame[0][:3] =m0
	n.contents.measurementFrame[1][:3] =m1
	n.contents.measurementFrame[2][:3] =m2
#	print n.contents.measurementFrame[0][:3]
#	print n.contents.measurementFrame[1][:3]
#	print n.contents.measurementFrame[2][:3]
	
#	set space directions
	mat2 = slicer.vtkMatrix4x4()
	inputVolumeNode.GetIJKToRASMatrix(mat2)
#	print mat2.GetElement(0,0)
#	print mat2.GetElement(1,0)
#	print mat2.GetElement(0,1)
#	print mat2.GetElement(1,2)
	for i in range (1,inputVolumeNode.GetImageData().GetDimensions().__len__()+1):
		for j in range (inputVolumeNode.GetImageData().GetDimensions().__len__()):
			n.contents.axis[i].spaceDirection[j] = mat2.GetElement(j,i-1)

#	set space origin
	for k in range (inputVolumeNode.GetImageData().GetDimensions().__len__()):
		n.contents.spaceOrigin[:3] = inputVolumeNode.GetOrigin()

#	Test	
#	print "axis space direction", n.contents.axis[1].spaceDirection[0]
#	print "axis space direction", n.contents.axis[1].spaceDirection[1]
#	print "axis space direction", n.contents.axis[1].spaceDirection[2]
#	print "axis space direction", n.contents.axis[2].spaceDirection[0]
#	print "axis space direction", n.contents.axis[2].spaceDirection[1]
#	print "axis space direction", n.contents.axis[2].spaceDirection[2]
#	print "axis space direction", n.contents.axis[3].spaceDirection[0]
#	print "axis space direction", n.contents.axis[3].spaceDirection[1]
#	print "axis space direction", n.contents.axis[3].spaceDirection[2]	
#	print n.contents.spaceOrigin[:3]
	
#	set axis kind information
	n.contents.axis[0].kind = teem.nrrdKind3DMatrix
	n.contents.axis[1].kind = teem.nrrdKindSpace
	n.contents.axis[2].kind = teem.nrrdKindSpace
	n.contents.axis[3].kind = teem.nrrdKindSpace
#	err2 = teem.biffGetDone("nrrd")
#	print "ERROR: ", err2

	print teem.nrrdSave("val_Tensor.nhdr", n, None)
	
	############### 4) shrink n (from 9-tensor component to 7-tensor component) ########################################################
	print "############################## shrink n ###############################################"
	s = teem.nrrdNew()
	print teem.tenShrink(s, None, n)

#	Teem tractography currently doesn't handle the measurement frame
#	so it has to be reduced to the identity transform first
	teem.tenMeasurementFrameReduce(s,s)
	s.contents.axis[0].kind = teem.nrrdKind3DMaskedSymMatrix
	s.contents.axis[1].kind = teem.nrrdKindSpace
	s.contents.axis[2].kind = teem.nrrdKindSpace
	s.contents.axis[3].kind = teem.nrrdKindSpace	
		
	print teem.nrrdSave("shrink-ten.nhdr", s, None) 

#	print "##############TEST s###############################"
#	ns = teem.nrrdIterNew()
#	teem.nrrdIterSetNrrd(ns, s)
#	print teem.nrrdIterValue(ns)
#	print teem.nrrdIterValue(ns)
#	print teem.nrrdIterValue(ns)
#	print teem.nrrdIterValue(ns)
#	print teem.nrrdIterValue(ns)

#	print "##############TEST n###############################"
#	nn = teem.nrrdIterNew()
#	teem.nrrdIterSetNrrd(nn, n)
#	print teem.nrrdIterValue(nn)
#	print teem.nrrdIterValue(nn)
#	print teem.nrrdIterValue(nn)
#	print teem.nrrdIterValue(nn)
#	print teem.nrrdIterValue(nn)

	############### 5) ROI seeding #####################################################################
	print "####################################### ROI seeding #######################################"
#	see /Slicer3/Libs/vtkTeem/vtkSeedTracts.cxx

#	get whole extent of ROI
	inExt = inputROI.GetImageData().GetWholeExtent()
	print "inExt: ", inExt

	maxX = inExt[1] - inExt[0]
 	maxY = inExt[3] - inExt[2]
	maxZ = inExt[5] - inExt[4]	
	print "maxX, maxY, maxZ: ", maxX, " ", maxY, " ", maxZ

#	seed spacing
	isotropicSeedingResolution=1
	isotropicSeeding = 1
	spacing = inputVolumeNode.GetImageData().GetSpacing()
	print "inputVolume spacing: ", spacing
	if (isotropicSeeding):
		gridIncX = isotropicSeedingResolution/spacing[0]
		gridIncY = isotropicSeedingResolution/spacing[1]
		gridIncZ = isotropicSeedingResolution/spacing[2]
	    
	else: 
		gridIncX = 1
		gridIncY = 1
		gridIncZ = 1

	numberPoints= maxX*maxY*maxZ
	roiType = inputROI.GetImageData().ToArray().dtype
#	create vtkIntArray instance -> will contain the seeding points; 3-by-N array
	ptsROI = slicer.vtkFloatArray()
#	set number of components of array
	ptsROI.SetNumberOfComponents(3)
	numTup = 0
	point=[0,0,0]
	point2=[0,0,0]
	transPoint = slicer.vtkMatrix4x4()
	ijk2 = slicer.vtkMatrix4x4()
	inputVolumeNode.GetIJKToRASMatrix(ijk2)
	transPoint.DeepCopy(ijk2)

	seeding_array = inputROI.GetImageData().ToArray()
#	print "seeding array: ", seeding_array
#	get all the seed points
	pointsToProcess = numpy.where( seeding_array == 1 )
#	order of seed points indices needs to be reversed
	pointsToProcess=numpy.array([pointsToProcess[2],pointsToProcess[1],pointsToProcess[0]]) 
	pointsToProcess=numpy.transpose(pointsToProcess)
	for i in range(pointsToProcess.shape[0]):
		ijkPoint=[pointsToProcess[i][0],pointsToProcess[i][1],pointsToProcess[i][2],1.0]
		# transform seed points to world space
		worldPoint = transPoint.MultiplyPoint(pointsToProcess[i][0],pointsToProcess[i][1],pointsToProcess[i][2],1.0)
		worldPoint2 = [worldPoint[0], worldPoint[1], worldPoint[2]]
		# check if ijk point is within tensor volume
		if (PointWithinTensorData(pointsToProcess[i],point2,inputVolumeNode)):
			ptsROI.InsertTuple3(numTup,worldPoint2[0],worldPoint2[1],worldPoint2[2])
#			print "point: ", pointsToProcess[i], "worldPoint2: ", worldPoint2
			numTup = numTup+1

#	Test
#	print "number of ROI tuples: ", numTup, ptsROI.GetNumberOfTuples()	       
#	print "##### Points of ROI ##########"
#	print ptsROI.ToArray()

#	cast the pointer to the ROI seed point data
	roi_p = ctypes.cast(ptsROI.ToArray().__array_interface__['data'][0], ctypes.POINTER(ctypes.c_float))

#	get axes sizes of ROI
	szROI = (ctypes.c_size_t * 2)()
	szROI[:] = [3,numTup]
	szROI2=[3,numTup]
	roiNrrd = teem.nrrdNew()
	print teem.nrrdWrap_nva(roiNrrd, roi_p, teem.nrrdTypeFloat, 2, szROI)
	
	# cast the pointer to the roi image data
	data_out_roi = ctypes.cast(roiNrrd.contents.data, ctypes.POINTER(nrrdToCType(roiNrrd.contents.type))) 

	print teem.nrrdSave("roi.nhdr", roiNrrd, None)
#	nir = teem.nrrdIterNew()
#	teem.nrrdIterSetNrrd(nir, roiNrrd)
#	for i in range(szROI2[1]):
#		print teem.nrrdIterValue(nir)

	############## 6) pass s to tenFiberContextNew and start doing tractography #############
	print "############################## Tractography ###############################################"
#	create the fiber context around the tensor volume 
	tfx = teem.tenFiberContextNew(s)
	if (tfx):
		err = teem.biffGetDone("ten")
		print "tenFiberContextNew: ", tfx

#	set the type of tractography (here one-tensor)
	teem.tenFiberTypeSet(tfx, teem.tenFiberTypeEvec0)



#	set up stopping criteria 

# 	possible values for anisotropy:
#	"FA": teem.tenAniso_FA

#	Westin's linear (first version)
#	"Cl1": teem.tenAniso_Cl1

#	Westin's planar (first version)
#	"Cp1": teem.tenAniso_Cp1

#	Westin's linear + planar (first version)
#	"Ca1":teem.tenAniso_Ca1

#	minimum of Cl and Cp (first version)
#	"Clpmin1": teem.tenAniso_Clpmin1

#	Westin's linear (second version)
#	"Cl2": teem.tenAniso_Cl2

#	Westin's planar (second version)
#	"Cp2": teem.tenAniso_Cp2

#	Westin's linear + planar (second version)
#	"Ca2": teem.tenAniso_Ca2

#	minimum of Cl and Cp (second version)
#	"Clpmin2": teem.tenAniso_Clpmin2
	teem.tenFiberStopAnisoSet(tfx, teem.tenAniso_Cl1, 0.1) #Cl1, 0.1
#	other possibilities include:
#	teem.tenFiberStopDoubleSet(tfx, tenFiberStopLength, len)
#	teem.tenFiberStopDoubleSet(tfx, tenFiberStopMinLength, len)
#	teem.tenFiberStopDoubleSet(tfx, tenFiberStopConfidence, conf)
#	teem.tenFiberStopDoubleSet(tfx, tenFiberStopRadius, rad)
#	teem.tenFiberStopUIntSet(tfx, teem.tenFiberStopNumSteps, numsteps)
#	teem.tenFiberStopUIntSet(tfx, tenFiberStopMinNumSteps, numsteps) 

#	kernel for reconstructing tensor field
	ksp = teem.nrrdKernelSpecNew()
	teem.nrrdKernelSpecParse(ksp, "cubic:0,0.5")
	teem.tenFiberKernelSet(tfx, ksp.contents.kernel, ksp.contents.parm)

#	set path integration & step size 
#	the different integration styles supported
#	tenFiberIntgUnknown,   /* 0: nobody knows */
#	tenFiberIntgEuler,     /* 1: dumb but fast */
#	tenFiberIntgMidpoint,  /* 2: 2nd order Runge-Kutta */
#	tenFiberIntgRK4,       /* 3: 4rth order Runge-Kutta */
#	tenFiberIntgLast
	teem.tenFiberIntgSet(tfx, teem.tenFiberIntgMidpoint) 
#	base step size
	teem.tenFiberParmSet(tfx, teem.tenFiberParmStepSize, 0.4)
#	tractograph happens in world-space (0 == false)
#	define seedpoint and output path in worldspace.  Otherwise, if 1: everything is in index space
	teem.tenFiberParmSet(tfx, teem.tenFiberParmUseIndexSpace, 0)

	teem.tenFiberUpdate(tfx)

	teem.tenFiberVerboseSet(tfx, 0)

#	tfbs = teem.tenFiberSingleNew()
	tfml = teem.tenFiberMultiNew() 

	fiberPld = teem.limnPolyDataNew()

#	does tractography for a list of seedpoints 
	E = teem.tenFiberMultiTrace(tfx, tfml ,roiNrrd)
	if (E):
		err = teem.biffGetDone("ten")
		print "tenFiberMultiTrace: ", E

#	converts tenFiberMulti to polydata
	teem.tenFiberMultiPolyData(tfx, fiberPld, tfml)

#	THIS SAVES limnPolyData to disk, 
#	save polydata output to Teem's LMPD format 
	teem.limnPolyDataSave("fibers_tensor.lmpd", fiberPld) 
#	save individual fibers to txt files 
#	for vi in range(tfml.contents.fiberNum): 
#		teem.nrrdSave('vert-%d.txt' % (vi), 
#		tfml.contents.fiber[vi].nvert, None)

	print "############################## results Tractography ###############################################"
	fiberPldCon = fiberPld.contents

	print "Number of fibers: ", fiberPldCon.primNum, "\n"
	print "Number of vertices for all fibers: \n"
	print [fiberPldCon.icnt[i] for i in range(fiberPldCon.primNum)] 

	print "length of fiber array (tfml.contents.fiber): ", tfml.contents.fiberNum
	print tfml.contents.fiber.contents
	

	pts = slicer.vtkPoints()
	rect = slicer.vtkCellArray()
#	numVert = (ctypes.c_uint * fiberPldCon.primNum)()
	numVert = [fiberPldCon.icnt[i] for i in range(fiberPldCon.primNum -1)] 
#	"primNum" is the number of fibers
	indexP=0
	for numFib in range (fiberPldCon.primNum):	
		rect.InsertNextCell(fiberPldCon.icnt[numFib])
#		icnt[i] will be the number of vertices in line i
		for i in range(fiberPldCon.icnt[numFib]):
			pts.InsertNextPoint(float(fiberPldCon.xyzw[0+4*indexP]),float(fiberPldCon.xyzw[1+4*indexP]),float(fiberPldCon.xyzw[2+4*(indexP)]))
			rect.InsertCellPoint(indexP)
			indexP=indexP+1
#			print pts.GetPoint(i)
#		rect.UpdateCellCount(i+1)
#	for k in range(pts.GetNumberOfPoints()):
#		rect.InsertCellPoint(k)
#		print rect.GetNumberOfCells()

#	setup the output node
	outputFiberBundleNode.SetAndObservePolyData(slicer.vtkPolyData())
	outputPolyData = outputFiberBundleNode.GetPolyData()

	outputPolyData.SetPoints(pts)
	print outputPolyData.GetPoints()
	outputPolyData.SetLines(rect)
	print outputPolyData.GetLines()
	print outputPolyData.GetPoints().GetData().ToArray()
	print outputPolyData.GetLines().GetData().ToArray().squeeze()
	outputPolyData.Update()

#	pdf = slicer.vtkTransformPolyDataFilter()
#	ijk = slicer.vtkMatrix4x4()
#	t = slicer.vtkTransform()
#	inputVolumeNode.GetIJKToRASMatrix(ijk)
#	t.SetMatrix(ijk)
#	pdf.SetTransform(t)
	
#	pdf.SetInput(outputFiberBundleNode.GetPolyData())
#	pdf.Update()
#	outputFiberBundleNode.SetAndObservePolyData(pdf.GetOutput())
	
#	outputFiberBundleNode.Modified()
		
#	frees the nrrd; does nothing with the array data inside
#	teem.nrrdNix(n)
#	blows away the nrrd and everything inside
#	teem.nrrdNuke(s)
#	teem.nrrdNuke(roiNrrd)
	return
def typeCodeToPythonType( typecode ):
    """For a gived nrrd type, return a typle with the corresponding ctypes type, array typecode and numpy type"""
    typeTable = {
        teem.nrrdTypeChar : ( ctypes.c_byte, 'b', numpy.int8 ),
        teem.nrrdTypeUChar     : ( ctypes.c_ubyte, 'B', numpy.uint8 ),
        teem.nrrdTypeShort     : ( ctypes.c_short, 'h', numpy.int16 ),
        teem.nrrdTypeUShort     : ( ctypes.c_ushort, 'H', numpy.uint8 ),
        teem.nrrdTypeInt     : ( ctypes.c_int, 'l' , numpy.int),
        teem.nrrdTypeUInt     : ( ctypes.c_uint, 'L' , numpy.uint),
        teem.nrrdTypeFloat     : ( ctypes.c_float, 'f' , numpy.float ),
        teem.nrrdTypeDouble     : ( ctypes.c_double, 'd' , numpy.double ) }

    # no python array types are available for the following nrrd types:

    #teem.nrrdTypeLLong     : ( ctypes.c_char, 'c' ),
    #teem.nrrdTypeULLong     : ( ctypes.c_char, 'c' ) }

    return typeTable[typecode]

def typeCodeToTeemType( typecode ):
    """For a gived nrrd type, return a typle with the corresponding ctypes type, array typecode and numpy type"""
    typeTable = {
        numpy.int8 : ( ctypes.c_byte, 'b', teem.nrrdTypeChar),
        numpy.uint8     : ( ctypes.c_ubyte, 'B', teem.nrrdTypeUChar ),
        numpy.int16     : ( ctypes.c_short, 'h', teem.nrrdTypeShort ),
        numpy.uint16     : ( ctypes.c_ushort, 'H', teem.nrrdTypeUShort ),
        numpy.int     : ( ctypes.c_int, 'l' , teem.nrrdTypeInt ),
        numpy.uint     : ( ctypes.c_uint, 'L' , teem.nrrdTypeUInt ),
        numpy.float     : ( ctypes.c_float, 'f' , teem.nrrdTypeFloat ),
        numpy.float32     : ( ctypes.c_float, 'f' , teem.nrrdTypeFloat ),
        numpy.double     : ( ctypes.c_double, 'd' , teem.nrrdTypeDouble ) }

    # no python array types are available for the following nrrd types:

    #teem.nrrdTypeLLong     : ( ctypes.c_char, 'c' ),
    #teem.nrrdTypeULLong     : ( ctypes.c_char, 'c' ) }

    return typeTable[typecode]

def nrrdToCType( ntype ):
    """For a gived nrrd type, return a typle with the corresponding ctypes type, array typecode and numpy type"""
    typeTable = {
        teem.nrrdTypeChar : ctypes.c_byte,
        teem.nrrdTypeUChar : ctypes.c_ubyte,
        teem.nrrdTypeShort : ctypes.c_short,
        teem.nrrdTypeUShort : ctypes.c_ushort,
        teem.nrrdTypeInt : ctypes.c_int,
        teem.nrrdTypeUInt : ctypes.c_uint,
        teem.nrrdTypeLLong : ctypes.c_longlong,
        teem.nrrdTypeULLong : ctypes.c_ulonglong,
        teem.nrrdTypeFloat : ctypes.c_float,
        teem.nrrdTypeDouble : ctypes.c_double
    }
    return typeTable[ntype] 

def setupTheOutputNode( outputFiberBundleNode ):
  if ( outputFiberBundleNode.GetPolyData()==[] ):
    outputFiberBundleNode.SetAndObservePolyData(slicer.vtkPolyData())

  outputPolyData = outputFiberBundleNode.GetPolyData()
  outputPolyData.Update()

  return clusters


def PointWithinTensorData(point, pointw,inputVolumeNode):
  bounds = inputVolumeNode.GetImageData().GetBounds()

  
  inbounds=1
  if (point[0] < bounds[0]):
    inbounds = 0
  if (point[0] > bounds[1]): 
    inbounds = 0
  if (point[1] < bounds[2]): 
    inbounds = 0
  if (point[1] > bounds[3]): 
    inbounds = 0
  if (point[2] < bounds[4]):
    inbounds = 0
  if (point[2] > bounds[5]):
    inbounds = 0

  if (inbounds ==0):
    print "point ", pointw, " outside of tensor dataset \n"

  return(inbounds)


def myfrange(start, stop, n):
    L = [0.0] * n
    nm1 = n - 1
    nm1inv = 1.0 / nm1
    for i in range(n):
        L[i] = nm1inv * (start*(nm1 - i) + stop*i)
    return L


def qrange(start, stop=None, step=1):
#"""if start is missing it defaults to zero, somewhat tricky"""
	if stop == None:
		stop = start
		start = 0
# allow for decrement
	if step < 0:
		while start > stop:
			yield start 
			# makes this a generator for new start value
			start += step
	else:
		while start < stop:
			yield start
			start += step



def frange(limit1, limit2 = None, increment = 1.):
  """
  Range function that accepts floats (and integers).

  Usage:
  frange(-2, 2, 0.1)
  frange(10)
  frange(10, increment = 0.5)

  The returned value is an iterator.  Use list(frange) for a list.
  """

  if limit2 is None:
    limit2, limit1 = limit1, 0.
  else:
    limit1 = float(limit1)

  count = int(M.ceil((limit2 - limit1)/increment))
  return (limit1 + n*increment for n in range(0,count))
